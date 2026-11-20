# Working on the SM-T570 with several sessions at once

One tablet (the owner's daily device), one PC, several Claude sessions.
These rules keep them from breaking each other's work or the owner's data.

**Coordinator (since 2026-11-20): the session "tablet-lab"**, which owns the
tablet and this repository. The bring-up era sessions named in older
handoff entries are gone. Sessions that may ask for tablet time today: the
Cairn OS sessions (images, noru, osk, ports, battery care) and Godnotic.
Message tablet-lab before anything in section 1 beyond read-only use.

## 1. The tablet

- **Access:** `scripts/tab-ssh '<cmd>'` (key-only ssh over the USB cable;
  `~/Projects/cairn-os/.scaffold/tablet/tsh` wraps the same). A new
  computer or key pairs once with `scripts/tab-ssh --pair` and a tap on
  "Allow" on the tablet. The unauthenticated shell (2323), the register
  console (23, `scripts/tab`, `tab-put`, `tab-get`, `tab-shot`,
  `tab-unlock`) and adb exist only in open mode (`duranium.usb_debug=open`,
  bring-up images); image 26102701 still has them until its next update.
  Screenshots: Phosh's D-Bus API (`org.gnome.Shell.Screenshot`) over ssh.
- **Log every disruptive action** in `~/Projects/cairn-os/.scaffold/tablet/LOG.md`
  (one line: time, session, action, result) and hold the device lock for
  the whole action: `flock build/device.lock <command>` (or
  `exec 9>build/device.lock; flock 9` in a script). Disruptive: reboot,
  Download mode, flashing, `scripts/duranium-update`, service changes,
  `duranium-usb-debug off`, rmmod/insmod of a loaded driver, register pokes,
  installs, long tests. Read-only use needs neither.
- **Every test comes back without a human:** know the return path first
  (boot counting, a timer that undoes the change, Download mode). Turning
  USB debug off on a running tablet needs a timer that turns it on again
  (2026-11-20: an untested "on" left debug unreachable until a reboot).
- **Never full-reinstall Duranium** (`scripts/duranium-boot --wipe-user-data`,
  install-to-userdata.sh): it erases the owner's encrypted root. Deliver
  images with `scripts/duranium-update` (A/B slots, hash-checked,
  boot-counted; the booted version stays as fallback).
- **Flashing a Cairn OS image** is allowed by the owner (2026-11-20), only
  after the image passed its QEMU tests, with Duranium kept recoverable
  (A/B or a documented way back) and anything in /home not yet backed up
  copied off first (Pictures: `~/Backups/tablet-sm-t570/`). Ask tablet-lab
  first; it schedules the window.
- The owner types the disk passphrase at every boot (remote unlock needs
  open mode): batch reboots and say before one. Ask the owner only for
  physical actions, one at a time, saying what to do and for how long.

## 2. Builds (one PC; it crashed from memory exhaustion on 2026-11-20)

- Every build, test suite, emulator, image build or VM goes through
  `agent-heavy --mem <GB> --label <what> -- <command>` (at most 2 jobs
  machine wide, a hard memory cap). Podman jobs also pass
  `--memory=<N>g --memory-swap=<N>g` and a CPU limit. `make -j8` at most;
  one kernel build at a time. Never leave emulators, VMs, dev servers or
  JVMs running when idle.
- Builds in this repo still take `build/kbuild.lock` (scripts do), QEMU VMs
  `build/vm.lock` (tests/virt).
- Kernel work on your own branch and worktree
  (`git -C src/linux worktree add ../../build/wt/<name> -b drv/<name> integ`);
  tablet-lab merges after an on-device test.
- The main checkout is shared: when a push is rejected, `git pull
  --rebase`, never `git reset` to origin/main (a reset dropped another
  session's commits on 2026-10-24). Aport changes: commit right away, bump
  pkgrel.

## 3. Reporting

- To test something on the tablet or to merge: message tablet-lab with the
  branch, commits, what to test and how to recover if it fails.
- Proprietary material (firmware/, extracted blobs, decompiled code, keys,
  serials, MACs) is never committed.
