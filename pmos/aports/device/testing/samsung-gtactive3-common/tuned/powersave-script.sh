#!/bin/sh
# TuneD script for this device's "powersave" (tuned.conf [script]): system
# services run on the A55 cores only while the saver is on, as stock
# Android confines its background and system-background cpusets to the
# little cores (docs/BATTERY.md "Scheduler, cpufreq, boosts"). The session
# (user.slice: the shell, the apps and their services) keeps every core, so
# interaction and heavy foreground work still get the M3s. --runtime: the
# setting goes away with a reboot or "stop", never left behind in /etc.
set -u

case ${1:-} in
start) systemctl set-property --runtime system.slice AllowedCPUs=0-3 ;;
stop) systemctl set-property --runtime system.slice AllowedCPUs= ;;
esac
exit 0
