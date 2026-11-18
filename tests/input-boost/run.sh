#!/bin/bash
# The touch boost daemon (samsung-gtactive3-common gtactive3wifi-input-boost)
# against fake cpufreq policies and a FIFO standing in for the touchscreen:
# resting floors at start, the boost on touch events, the cap at
# scaling_max_freq, back to rest after the tail, the old floors on SIGTERM.
# Needs a C compiler (CC, default cc); no device, no root.
#
#   tests/input-boost/run.sh       KEEP=1 keeps the work directory
# Work directory: build/test-input-boost (gitignored).
set -euo pipefail
HERE=$(cd "$(dirname "$0")" && pwd)
REPO=$(cd "$HERE/../.." && pwd)
SRC=$REPO/pmos/aports/device/testing/samsung-gtactive3-common/gtactive3wifi-input-boost.c
RUN=$REPO/build/test-input-boost
rm -rf "$RUN"
mkdir -p "$RUN"
pid=
cleanup() {
	[ -n "$pid" ] && kill "$pid" 2>/dev/null || :
	[ "${KEEP:-0}" = 1 ] || rm -rf "$RUN"
}
trap cleanup EXIT

pass=0
ok() { pass=$((pass + 1)); echo "ok $pass - $*"; }
fail() { echo "FAIL - $*" >&2; cat "$RUN/log" >&2 || :; exit 1; }

${CC:-cc} -O2 -Wall -Wextra -Werror -o "$RUN/input-boost" "$SRC"
ok "builds without warnings"

# policy0 like the A55s, policy4 like the M3s with a lowered cap (a power
# profile), policy8 missing (a cluster that did not come up)
P=$RUN/cpufreq
mkdir -p "$P/policy0" "$P/policy4"
echo 208000 >"$P/policy0/scaling_min_freq"
echo 1950000 >"$P/policy0/scaling_max_freq"
echo 598000 >"$P/policy4/scaling_min_freq"
echo 1000000 >"$P/policy4/scaling_max_freq"
mkfifo "$RUN/touch"

floors() { echo "$(cat "$P/policy0/scaling_min_freq") $(cat "$P/policy4/scaling_min_freq")"; }
# wait up to 2 s for the floors to read $1
expect() {
	local _
	for _ in $(seq 40); do
		[ "$(floors)" = "$1" ] && return 0
		sleep 0.05
	done
	fail "$2: floors $(floors), expected $1"
}
# one touch: ABS_MT_POSITION_X then SYN_REPORT, struct input_event of this ABI
touch_once() {
	python3 -I -c '
import struct, sys
ev = lambda t, c, v: struct.pack("@llHHi", 0, 0, t, c, v)
sys.stdout.buffer.write(ev(3, 53, 100) + ev(0, 0, 0))' >"$1"
}

"$RUN/input-boost" -t 300 -d "$RUN/touch" \
	"$P/policy0:455000:832000" "$P/policy4:650000:1066000" \
	"$P/policy8:650000:1066000" >"$RUN/log" 2>&1 &
pid=$!

expect "455000 650000" "resting floors at start"
ok "resting floors at start, a missing policy is skipped"

# keep the FIFO open for writing across both touches
exec 3>"$RUN/touch"
touch_once /dev/fd/3
expect "832000 1000000" "boost on touch"
ok "touch raises the floors, capped at scaling_max_freq"

sleep 0.2
touch_once /dev/fd/3
sleep 0.2
[ "$(floors)" = "832000 1000000" ] || fail "boost ended within the tail of the second touch"
ok "every event extends the tail"

expect "455000 650000" "back to rest after the tail"
ok "back to the resting floors after the tail"

# the writer goes away like an unplugged or re-probed device; real event
# devices come back through the /dev/input watch, which needs no -d
exec 3>&-
for _ in $(seq 40); do
	grep -q "touch is gone" "$RUN/log" && break
	sleep 0.05
done
grep -q "touch is gone" "$RUN/log" || fail "the closed device was not dropped"
kill -0 "$pid" || fail "the daemon stopped when the device went away"
[ "$(floors)" = "455000 650000" ] || fail "floors $(floors) after the device went away"
ok "a closed device is dropped without stopping the daemon"

kill -TERM "$pid"
wait "$pid" || fail "exit status $? on SIGTERM"
pid=
[ "$(floors)" = "208000 598000" ] || fail "floors $(floors) after SIGTERM, expected 208000 598000"
ok "SIGTERM restores the floors found at start"

echo "all $pass passed"
