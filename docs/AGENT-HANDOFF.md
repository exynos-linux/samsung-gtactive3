# Agent handoff: SM-T570 → postmarketOS Duranium (read this first)

Written 2026-10-21 ~19:50 AEDT by the lead agent before a context compaction.
If you are the agent reading this after compaction: **you are the lead**. You
coordinate, integrate, flash the tablet and test every change on the device
yourself, autonomously, overnight. Keep going until the mission is met.

## State 2026-11-22 16:20 AEDT (session "tablet-lab"): T570 on Cairn 11.15

- The owner said yes in tablet-lab. I removed the dead 11.13 entry and its
  UKI from the ESP.
  - New loader.conf: `default samsung-gtactive3*`, `timeout 1`,
    `preferred bootc_*`.
  - Duranium's copy of the old one: `loader/loader.conf.duranium-20261122`.
- 11.14 booted and was blessed. 11.15 was staged once and booted.
  - bootc: booted 2026.11.15, rollback 2026.11.14, nothing staged.
  - The system is running with no failed units.
- Passed on 11.15:
  - The greeter r4 Users screen, the PIN pad, the keyboard pill and the
    password entry with the eye icon.
  - The OSK opens and hides on the greeter without a crash.
  - Screenshots: the shared notes folder's `tablet-lab-shots-2026-11-22/`.
- Defects sent to their owners (details in
  ~/Projects/cairn-os/out/t570/report.txt):
  - images, defect 21 still open: the staged-entry counter. cairn-bless-esp
    looks for the ESP by the entry name from before systemd-bless-boot
    renamed it, so 11.15 booted with no +3 counter.
  - images, defect 22: the offline flatpak stamp. No apps are installed.
  - images2: the UFS LUNs, including the cpefs EFS partition, are still
    visible in udisks.
  - osk: the wallpaper pebbles show through the greeter form.
- Test overrides on the tablet:
  - The /etc udisks rule is moved aside to `.t570-aside`. Undo: move it
    back.
  - The touch helper runs as the transient unit `t570-touchd`. Stop it with
    `systemctl stop t570-touchd`.
  - The dconf no-lock override is unchanged; undo as before.
- The device lock stays with tablet-lab. The hold keeper runs until about
  18:00 PC time. After that, the debug return timer brings the tablet back
  to Duranium within 30 min.
- Next:
  - When the owner logs in at the greeter:
    - the lock screen r9, including hiding the keyboard there without a
      crash;
    - the dock r8 and edge swipe;
    - udiskie prompts;
    - rotation, which needs the owner to turn the tablet.
  - bootc rollback and roll forward.
  - A Duranium image with r57 and 439583b8 (the owner's own yes).
- Waits for the owner:
  - logging in with their PIN;
  - the dock choice: "keep as is" or "swipe only".

## State 2026-11-21 23:00 AEDT (session "tablet-lab"): Cairn 11.11 session probed, owner on the tablet

- The session was unlocked with `loginctl unlock-session c3` (no PIN
  typed). Touches were injected with a volatile uinput device (a test helper
  in /run, now stopped). Screenshots came from the DRM scanout.
- The dconf test override works: idle-delay is 0.
- The OSK (cairn-osk r3) comes up docked-bottom in a text field. Switching
  to floating and back over os.cairn.Osk1 works.
- With noru r7, the dock jumps above a docked keyboard. noru r8 fixes that.
- The grey and orange "ellipses" seen through the keyboard are the Cairn
  wallpaper's pebbles behind the see-through r3 keyboard (glass 0.6), not a
  bug (noru, 2026-11-21 23:45). cairn-osk r4 makes the keyboard less
  see-through.
- The keyboard opened on the symbol layer in a plain search field.
- Rotation turns the screen. The owner reports a broken animation; phoc
  r104 is the fix, in 11.13.
- The second greeter (noru-switch-greeter) took the screen twice, 10:11 and
  10:52 tablet time. It was most likely a finger on "Switch user" next to
  Unlock. `systemctl stop noru-switch-greeter.service` brings back the
  session.
- The owner asked for these lock-screen changes, which noru (greeter r4,
  38342dea, lock screen uncommitted) and osk (a88ea2c) are building:
  - a Users pill with a users screen;
  - Unlock down and right of the pad;
  - a libadwaita password row with an eye icon;
  - an N/123 pill for the pad;
  - letters and numbers on the password keyboard.
- Evidence: the shared notes folder's tablet-lab-shots-2026-11-21/ and
  ~/Projects/cairn-os/out/t570/report.txt (defect 23).
- 11.13 (cef96f05) is staged with bootc upgrade (fixed boot-count unit in
  /run). The reboot waits for the owner's yes.
- The owner is now using the tablet by hand: touch injection is stopped.
  The device lock stays with tablet-lab for the 11.13 update.
- Next:
  - On 11.13: +N boot counters, /var/lib/flatpak/repo, the udisks check
    (move the /etc rule aside first), rotation with phoc r104 and
    G_MESSAGES_DEBUG, the noru r8 dock and edge swipe, the r4 lock and
    greeter, and a bootc rollback and roll forward.
  - A Duranium image with r57 and the boot-default fix 439583b8 (the
    owner's own yes).

## State 2026-11-21 22:00 AEDT (session "tablet-lab"): Cairn updated 11.9 → 11.11 with bootc

- The ESP's loader/ was backed up first (tablet-lab scratchpad, not in git).
  Then cairn-ports' adopt (11.9 bundle) and the stock `just update` through
  the ssh -R SOCKS proxy. 11.11 (sha256:42b659f7…) booted first try with
  initramfs r57. bootc status: booted 11.11, rollback 11.9.
- Adopt was not allowed to bless the stock 11.9 entry: that UKI resets on
  the T570 (initrd deadline, before r57). Both 11.9 entries are set to +0-3
  (used up), so the fallback after 11.11 is Duranium (loader default).
- Cairn defects found and sent to images:
  - Staged entries get no boot counter: cairn-boot-count-staged's stop job
    is dropped by an ordering cycle with bootc-finalize-staged (default
    dependencies).
  - The Flathub preinstall loops: tmpfiles refuses /var/lib/flatpak owned by
    flatpak with root-owned children, so the repo stays half made.
  Evidence: ~/Projects/cairn-os/out/t570/report.txt, defects 21 and 22 (copy
  in logs/test-runs/2026-11-21-cairn-2026.11.9/, gitignored).
- Test-only state on the tablet, in /etc so it persists:
  - the udisks ignore rule for the shared disk (until 11.12);
  - a dconf system database t570test: no idle blank, lock or suspend (undo
    in the report);
  - the return timer to Duranium (20 min unless held).
- Waits for the owner:
  - the greeter keyboard icon tap;
  - login with their PIN;
  - the lock-screen keyboard icon;
  - turning the tablet for the rotation test.
- Next:
  - those owner checks;
  - the 11.12 udisks check for images2;
  - a Duranium image with r57 and the boot-default fix 439583b8.

## State 2026-11-21 19:10 AEDT (session "tablet-lab"): Cairn 11.9 logged in, hardware checks, r57 handed off

- The owner logged in on 11.9 (phosh session, system running). udiskie opened
  LUKS dialogs for Duranium's data (loop0p6), and stopping it asked polkit to
  unmount Cairn's root. Fixed by images2 in 9bb0c66 for 11.10: never stop
  udiskie on the tablet, mask it.
- Cameras on Cairn: kernel and PipeWire work (csis x2, s5k3l6 + dw9807,
  gc5035, both listed by wireplumber). Missing for 11.11: an app (snapshot)
  and the SoftISP yaml. Only the -initramfs subpackage is in Cairn's image,
  so about 30 main-package files are absent (side-session note
  tablet-lab-cairn-camera-and-device-files.md).
- Vibrator: feedbackd drives gpio-vibrator, proved by ftrace gpio_value. The
  motor is on/off, so short pulses (button-pressed is 7 ms) are likely not
  felt; noru got the device-theme suggestion.
- r57 (cb3fd9d0, eeeaec39, 8541bd1a) was built by CI run 44880926681. The
  initramfs apk went to images at ~/cairn-handoff/gtactive3-r57/apks (sha256
  5de8594e…) for 11.10. Not yet in a Duranium image.
- Wi-Fi firmware for Cairn: none on the PC. The owner was asked once for the
  T570XXSFEYI1 stock zip in firmware/stock/ and a yes to extract it.
- The 11.10 checklist (side-session note tablet-lab-11.10-checklist.md) now
  includes hands-off UX checks: touch injection, rotation, haptics, apps,
  udisks.
- ESP is unchanged: nodl preferred until 11.10 (backup loader.conf
  .tablet-lab-bak).
- Waits for the owner: a 10-min USB unplug for the drain test; the stock
  firmware zip and a yes.
- Next: 11.10 test with the checklist; Wi-Fi firmware once the zip is here;
  a Duranium image with r57 to confirm the deadline still fires there.

## State 2026-11-21 18:45 AEDT (session "tablet-lab"): Cairn 2026.11.9 boots once our deadline is off

- Root cause of the 2026.11.9 reset found: gtactive3wifi-initrd-deadline.service
  (samsung-gtactive3-common) ticks with `sleep 5`; Cairn's initrd has busybox
  without applet links and no sleep, so each tick failed at once (rc 127), the
  600 s ran out in milliseconds and it rebooted to Download mode at ~1.7 s
  (pstore: "Restarting system with command 'download'"). The cairn-dbg entry had
  gtactive3wifi.initrd_deadline=0 and booted; the watchdog and panic settings
  were ruled out. usb-prep's ExecStartPost failed the same way (mkdir/touch),
  printing a red FAILED over the splash.
- Fixed and pushed: cb3fd9d0 + eeeaec39 (deadline falls back to busybox sleep,
  turns itself off with no sleep), 8541bd1a (usb-prep marker without coreutils);
  samsung-gtactive3-common pkgrel 57. Not yet built into a Duranium image or
  tested on the device; Duranium's behaviour is unchanged where sleep exists.
- Verified on the device: cairn-nodl-2026.11.9.efi (the shipped UKI, .cmdline +
  gtactive3wifi.initrd_deadline=0, sha 9d7fe5c5…) booted twice, chooser (4
  entries, "failed 3x" marker, countdown), splash, greetd -> phrog greeter with
  Cairn branding, bless-boot good, system running. 32.4 s to userspace done
  (firmware 16.0 s). Camera recording of boot 2 (Galaxy Tab Active5 facing the
  tablet, camera app only): logs/test-runs/2026-11-21-cairn-2026.11.9/
  nodl-boot2.mp4 (local, logs/ is gitignored); ~8 s black between the splash
  and the greeter. Report and stills: ~/Projects/cairn-os/out/t570/report.txt,
  cam-0*.png.
- Told images/images2: initrd busybox applets, /var/lib/firmware (no Wi-Fi/BT
  on Cairn yet), splash until phoc takes DRM master, KillMode=none, no RTC time.
- ESP now: cairn-nodl-2026.11.9.efi (blessed) preferred (loader.conf
  `preferred cairn-nodl-*`, backup loader/loader.conf.tablet-lab-bak with
  `preferred cairn-[0-9]*`), cairn-dbg (blessed), cairn-2026.11.9+0-3
  (exhausted), Duranium 26112002~test2 default fallback.
- Next: images' 2026.11.10 with r57; the owner logs in with the PIN, then noru's
  checks (noru-tablet-tests.md, GTK 4 dock); a Duranium image with r57 to
  confirm the deadline still fires there.
- Waits for the owner: the PIN login on the tablet.
- 18:40 login check: the owner's "Login failed" was one wrong PIN (first nodl
  boot, 220 s: unix_chkpwd failed for cairn, pam AUTH_ERR). The private file's
  PIN matches the tablet's hash (offline check, match/mismatch only). After the
  failure phrog's greetd CancelSession got "Connection refused", so the greeter
  takes no second try until it restarts (told images). 2026.11.9 has no
  first-boot wizard (no ESP file = no user), so the cairn user was kept; the
  owner was told to log in as cairn with the PIN from the private file.
  Dropping the ESP firstboot-user file waits for the wizard in the image.

## State 2026-11-21 17:55 AEDT (session "tablet-lab"): Cairn 2026.11.9 resets, diag build armed

- 2026.11.9 flashed into p3 from Duranium (ports' bundle-3; logs/test-runs/
  2026-11-21-cairn-2026.11.9/: root sha256 8149de7c…, PARTUUID a6a602c8, ESP entry
  cairn-2026.11.9+3.efi + cairn-dbg (menu only), preferred cairn-[0-9]*, timeout 1).
  Its first try reset into Download mode 30 s after a clean reboot (16:23:32 ->
  16:24:02), no Cairn USB gadget. Its initrd now has the board modules (221 .ko,
  max77705/max17042/sec-core/s2mps11/acpm/cpufreq-dt), so that is not the cause.
- Left vs modtest3 (which booted): oops=panic + hung_task_panic=1 + panic=10 and
  the SoC watchdog's reset (modtest3: panic=0, s3c2410_wdt.soft_noboot=1), plus
  quiet, chooser show:3, splash, systemd-battery-check (images: unlikely, its
  failure is a power-off, not a reset).
- Armed: cairn-diag-2026.11.9.efi (~/Projects/cairn-os/out/t570/, sha bd971bfe…),
  the normal UKI with .cmdline only changed (-quiet, loglevel=7, panic=0,
  s3c2410_wdt.soft_noboot=1, cairn.splash=no); installs as +1 (one try) with
  preferred cairn-diag-* as soon as Duranium's ssh is up (scratchpad
  diag-install.sh, background). Reboot into it by hand after the checks.
- Tablet now: Download mode since 16:24, waiting for the owner's keys
  (Vol-Down+Power ~7 s, then only Power at "Hold Power to start"); the normal
  entry's tries 2-3 come first, then Duranium. device.lock held by tablet-lab.
- Next: diag try -> an oops on screen names the driver; boots -> dmesg for
  watchdog/oops/hung; still resets -> retry with cairn.chooser=no. images folds
  the fix into 2026.11.10 (with phoc r102, Noru r5); then the splash/chooser/
  bless/login checks and noru's device list (noru-tablet-tests.md, incl. the
  GTK 4 dock).
- Waits for the owner: the key presses above; later, logging in with the PIN
  from the private file.

## State 2026-11-21 15:10 AEDT (session "tablet-lab"): Cairn boots on the T570

- 2026.11.5 (ports' bundle-2, into p3 again; write-slot log in
  logs/test-runs/2026-11-21-cairn-2026.11.5/) still reset into Download mode about
  10 s into the kernel: the normal UKI, a debug entry (no splash/chooser, panic=0,
  loglevel 7) and dbg2 alike. pstore kept nothing (RAM is not kept across Download
  mode). Cause: Cairn's initrd lacked this board's modules (max77705 and its
  charger/usbc psy, max17042_battery, sec_core, sec_acpm, acpm_protocol, clk_acpm,
  exynos_mailbox, exynos9810_tmu, s2mps11, extcon_sm5502 ...). Proof: the same UKI
  with Duranium's 416-module initrd segment appended (cairn-modtest3) booted to
  the phrog greeter on its first try, greetd at 11.8 s.
  Evidence: ~/Projects/cairn-os/out/t570/modtest3/ (journal, dmesg, lsmod,
  systemd-analyze, drain) and modtest3-greeter.png.
- Cairn's first user (made by ports, owner not asked) was created correctly. The
  owner's login failed because they never had the PIN: the tablet's hash is ports'
  bundle-2 hash for the PIN in cairn-os/.private/t570-first-user (checked by
  fingerprint, PIN never read by an agent).
- Bug: Cairn mounts no ESP, so systemd-bless-boot fails ("Couldn't find $BOOT") and
  a working Cairn entry falls back next boot. images' cairn-bless-esp fix passed
  live 15:05 (found loop0p1 by LoaderDevicePartUUID, marked good); the entry was
  renamed back to +0-1 so the next start still falls back to Duranium.
- Drain at the Cairn greeter with USB attached: 12 mA net dimmed, 219 mA bright;
  no blank or suspend at the greeter, so not comparable with Duranium's 171 mA
  s2idle figure (out/t570/modtest3/drain-summary.txt).
- Tablet now: Cairn modtest3 running (unblessed); ESP: cairn-2026.11.5+0-3,
  cairn-modtest3-2026.11.5+0-1, Duranium 26112002~test2 (default). Next start ->
  Duranium. device.lock held by tablet-lab.
- Next: 2026.11.8 (modules + bless fix) via bundle-3 from Duranium
  (restore-default.sh, write-slot.sh into loop0p3, install-esp-entry.sh,
  prefer-cairn.sh); then splash upright, chooser and failure screen, blessing,
  and a fair drain test. Owner's asks forwarded: own background for branding and
  the setup screen (branding), GTK4/libadwaita throughout (noru's plan).
- Waits for the owner: logging in with the PIN from the private file; key presses
  only if a Cairn boot lands in Download mode.

## State 2026-11-21 13:30 AEDT (session "tablet-lab"): first Cairn flash, back on Duranium

- Owner's yes 2026-11-21 12:03 (relayed by branding): Cairn OS 2026.11.3 (Noru,
  image 495a6cd2) into the inactive slot with cairn-ports' slot bundle 0.1.7.
  p3 (was 26112001's /usr, backed up and verified in ~/t570-slot-backup/) is now
  `cairn-root` (PARTUUID ea29dd50-…), p2 `_empty`; the ESP holds the Cairn UKI,
  its root addon and EFI/cairn/firstboot-user; loader.conf has `preferred cairn-*`,
  timeout 1, the default line unchanged. A USB-debug kit (gadget, key-only sshd
  on usb0:2201, a 20-min return timer) was injected into Cairn's /etc. Evidence:
  logs/test-runs/2026-11-21-cairn-slot/ (local, no keys).
- Result: all 3 counted Cairn boots reset into Download mode about 10 s after the
  kernel started. Each needed the owner's Vol-Down+Power. After the third,
  `preferred` skipped the entry (now `cairn-2026.11.3+0-3.efi`) and Duranium
  26112002~test2 booted by itself (13:13:30). Duranium's data was untouched.
- Cause (Cairn, not this port): cairn-chooser in Cairn's initrd counts the boot in
  progress (sd-boot's `+2-1`) as a failed boot. It shows a 10 s countdown and then
  does a one-shot reboot (`cairn.chooser.kexec=0`). Cairn also lacked this
  port's `gtactive3wifi-reboot.tmpfiles` (reboot-param normal), so the reset kept
  uniLoader's INFORM3=download and S-Boot stopped in Download mode. Lesson for any
  OS on this board: without that tmpfiles line every reboot, panic or watchdog
  reset ends in Download mode, and boot counting only works through the owner's
  key presses. The fixes are in Cairn main (bdd09e4 reboot-param; the chooser fix
  with branding) for images' 2026.11.5. Details:
  side-session-notes/local_c3c8e5ce…/t570-cairn-2026.11.3-download-mode.md.
- In flight: device.lock held by tablet-lab for the 2026.11.5 re-flash (ports'
  bundle-2: uninstall-esp-entry.sh first, then write-slot with SLOT=/dev/loop0p3,
  re-inject the kit, first boot with images' debug addon + `cairn.chooser=no`).
  scripts/duranium-update refuses the `cairn-root` slot (a2d3bb9f).
- Next: PLAN.md's next three steps. Waits for the owner: nothing until 2026.11.5;
  heimdall from a container was refused by this session's permissions, so a
  Download-mode stop still needs Vol-Down+Power.

## State 2026-11-20 21:30 AEDT (session "tablet-lab"): read-only checks, osk sysext, r55

- No writes to userdata's nested GPT, the ESP or protected partitions (Cairn flash
  paused by the owner). Everything ran under build/device.lock, logged in
  ~/Projects/cairn-os/.scaffold/tablet/LOG.md.
- 26112002~test2 already carries PLAN step 2: the r52 touch boost (floors 832/1066
  MHz, screen and pen), irqbalance over CPU0-3 and r7's secure USB debug (usb0:22
  key-only, usb0:2324 pairing, no 23/2323, no adbd). STATUS rows updated.
- osk's sysext ran from /run/extensions (logs/test-runs/2026-11-20-osk-sysext):
  cairn-osk shows; its touch tests wait for someone at the tablet. The refresh made
  udiskie pop a polkit "mount /dev/loop3" dialog; samsung-gtactive3-common r55
  hides extension loop devices from udisks (verified with the rule from
  /run/udev/rules.d, which stays there until the next reboot). r55 is not built.
- scripts/tab-shot falls back to the paired ssh (the port-23 console is closed in
  secure mode).
- Finding, not changed: the base system's sshd.service (postmarketOS, enabled)
  listens on 0.0.0.0:22 with PasswordAuthentication yes, and nftables accepts
  port 22 on every interface, so the user's password opens ssh from the Wi-Fi
  (wlan0 has global IPv6 addresses). Turning passwords off or limiting it to
  usb0/tailscale is the owner's call: it may be how they reach the tablet.
- Next: PLAN.md's next three steps. Waits for the owner: nothing physical; the
  sshd decision above whenever they want it.

## State 2026-11-20 18:40 AEDT (session "tablet-lab"): kernel r28 + r29 live, released

- The SM-T570 runs 26112002~test2 (phosh edge, kernel r29 = r28 FS_VERITY +
  battery care's CNFG_00 CHG gate), A/B over 26112001 (kept as the fallback),
  blessed. Live checks, evidence in logs/test-runs/2026-11-20-r28-live/:
  fs-verity and the composefs mount parts ✔ (STATUS Storage), D14.9 ✔ with
  r29 (hold: 2 mA), phosh + osk + audio sinks, no failed units, Bluetooth,
  inputs, updatectl check against the signed feed.
- Seen once: the first brcmfmac probe failed (firmware -2, a __flush_work
  WARNING); wifi-recover brought wlan0 back after 32 s. Not on earlier boots.
- `~test` UKIs give "Invalid loader entry name" (systemd rejects `~`); local
  versions only.
- Export verified (pmos/VERIFIED) and pushed with r28/r29: CI publishes the
  release channels from it.
- Next: PLAN.md's next three steps; for battery care the D14.7 pause at 85 %
  while charging, resume below 80 and s2idle without -108 (the tablet is at
  99 % now). Kernel consolidation into cairn-os waits for Cairn's first boot
  (orchestrator), with IKCONFIG or /boot/config for Cairn's config check.
- Waits for the owner: nothing physical.

## State 2026-11-20 18:10 AEDT (session "battery care"): D14.8 drain, battery care bug, kernel r29

- D14.8 ✔: ~171 mA in s2idle with the screen off (20 min, RTC wake, USB back;
  ~650 mA awake with the screen on). TESTPLAN D14.8, BATTERY.md.
- Bug: the r27/r28 charge limit only changed the status. CNFG_09 bit 7 does not
  stop charging; the CNFG_00 CHG bit does (checked by hand, D14.9). The fix is in
  src/linux 2bbe2395e (gtactive3 and drv/battcare, not pushed). It also makes
  the charger poll freezable, so it cannot hit the suspended I2C bus at
  resume (-108). Kernel aport **r29** on main (local commit, on top of
  tablet-lab's r28 6987697e). It is not built or booted yet.
- Unloading the charger module that came with the image resets the tablet
  (17:47 and 17:56; it came back by itself on 26112001). Test charger fixes
  in an image, not by live swap.
- Next: (1) build r29 and put it in an A/B image (tablet-lab's 26112002~test1
  is r28); (2) in it, run D14.9 (hold at 80/85 → current ≤ ~0) and the D14.7
  pause at 85 % while charging; (3) hand the r29 apks to the images session
  for Cairn (~/cairn-handoff/gtactive3-battery-care/apks/).
- Waits for the owner: nothing physical.

## State 2026-11-20 16:50 AEDT (session "tablet-lab"): 26112001 checked, chooser facts, osk sysext blocked

- Image 26112001 (r53/r52/r54, kernel r27) booted and blessed on the SM-T570.
  V4 ✔ once the frozen /etc/sysupdate.d transfers were moved out (backup in
  /var/lib/tablet-lab-backup/20261120/ on the tablet). D13.7 (Turn off from
  the notification through polkit) and D13.8 (no open-mode ports) ✔. Results
  are in TESTPLAN, commit bbac3327.
- Incident: at 16:08 a second tap on the re-posted USB debugging notification
  turned debug off with nothing armed to bring it back. The owner ran
  `sudo duranium-usb-debug on` at 16:44. The r8 notes for duranium-usb-debug:
  `on` while already on should do nothing, and Turn off should ask first or
  arm a re-enable timer itself.
- Facts for the images session's touch boot chooser (cairn), read-only on the
  device and recorded in the shared note t570-boot-path-for-touch-chooser.md:
  - the UKI initrd already loads KMS (2.40 s), touch (2.94 s), pen (3.05 s),
    gpio-keys and the vibrator, well before switch-root (13.48 s);
  - plymouth runs in the initrd;
  - kexec_load_disabled=0;
  - efivars are readable;
  - the UKI has the profiles main, debug and debug-shell.
  The boot chain is unchanged until images hands over its prototype.
- cairn-osk sysext (osk session): it does not mount here. It is squashfs zstd,
  and our kernel has SQUASHFS_ZLIB/XZ only. Phosh also starts the keyboard
  from mobi.phosh.OSK.service, not from the desktop file. Both are reported to
  osk; nothing stayed on the tablet. Waiting for a rebuilt raw.
- Open: D13 off across a boot, open mode from the boot menu, duranium-update
  over the USB ssh; the Vol- keycode (owner press). Device lock free.
  Next three steps: unchanged (PLAN.md).

## State 2026-11-20 16:50 AEDT (session "battery-care"): D14.7 in image 26112001

- D14.7 partly done on 26112001 (r27 + r54), no reloads, no reboot, under
  the device lock (LOG.md 16:45). The first boot's 100/100 was not a bug:
  upower's state file still held `0` from this session's D14.5 disable
  test at 14:14 (/var survives A/B updates; the tmpfiles default only
  creates a missing file). Enable → 80-85 and "charging paused"; sysfs
  forced to 100/100 + upower restart → 80-85 again; disable → 0-100.
  **Battery care is ON** on the tablet now.
- Left for D14.7: the pause at 85 % while charging (the battery is at
  100 %; needs it below 80 first, then the PC's USB or a wall charger) and
  a real reboot. Noru's tile is in shell/noru 86932638 (next noru release).
- The tablet now runs the stock r27 charger module from the image (the /tmp
  one went with the update). Next three steps: unchanged (PLAN.md).

## State 2026-11-20 14:30 AEDT (session "battery-care"): charge limit and power saver

- Kernel r27 (src/linux `drv/battcare`, 29dc0ef8b on 12b04826f; `gtactive3`
  fast-forwarded to it): max77705_charger adds `charge_control_{start,end}_threshold`
  and `charge_behaviour` (auto, inhibit-charge, force-discharge) to
  max170xx_battery as a power_supply extension. Live-tested with the
  module on the SM-T570 (26102701): TESTPLAN D14.1-D14.5 pass, docs/BATTERY.md
  "Battery care". The tablet still runs that module from /tmp (no limit,
  auto). It is harmless, and a reboot brings back the stock one.
- samsung-gtactive3-common r54 (on top of tablet-lab's r53):
  battery care on by default at 80-85 % (`61-gtactive3wifi-battery-care.rules`
  sets CHARGE_LIMIT after upower's catch-all 75,80; the tmpfiles default
  writes upower's state file once). The tuned power saver adds an M3 cap of
  1261 MHz, a GPU cap of 455 MHz and a 5 ms schedutil rate limit to the A55
  cap. Measured (D14.6): no change on a quiet tablet (~690 mA screen on at
  brightness 65), -13 % / -19 % under a sustained one-core load.
- Incident: 2026-11-20 13:07 kernel panic on the tablet after this session
  unloaded the charger module alone. The gauge's supplied_from kept a
  pointer into it. Rule (TESTPLAN D14): unload the gauge first. The panic
  dump was lost: systemd-pstore archives /sys/fs/pstore while still in the
  initrd, whose /var is a tmpfs (follow-up).
- Builder: the local `gta3-pkgbuilder` image had been removed. Modules are
  now built with `localhost/gta3-kmodbuilder` (Nura edge, Alpine GCC 15.2.0,
  same as the package): out of tree, `O=build/battcare/out
  KERNELRELEASE=7.3.0 M=drivers/power/supply`.
- Cairn OS: the design (core: upower + tuned + tuned-ppd + the state default;
  device apks: the CHARGE_LIMIT rule and tuned overrides; Noru: battery care
  and power saver toggles) went to the images and noru sessions, note
  `battery-power-design.md` in the session notes.
- In flight: none (merged to main). Worktrees build/wt/battery-care (sparse)
  and build/wt/linux-battcare can go.
- Next three steps: as PLAN.md "Next three steps (2026-11-20)" (step 1
  now includes D14.7).
- Waits for the owner: D14.8 (10 min suspended with the screen off, to
  measure screen-off drain); a wall charger for D14.7's pause at 85 %.

## State 2026-11-20 14:35 AEDT (session "tablet-lab"): CI images unblocked

- The dev-image failure ("systemd-262.2-r0: failed to commit
  usr/sbin/init") is upstream's: apk-tools 3.0.10 in mkosi's tools tree
  (edge, 2026-11-19). Reproduced with clean upstream duranium-build
  (qemu-amd64 phosh); with Alpine's static apk 3.0.9 overlaid as a mkosi
  sandbox tree the same full build passes (6.4 GB image, 336 s; logs in
  logs/test-runs/2026-11-20-apk-pin). duranium-build 0047 does that for
  our images (owner's OK); `APK_PIN=` turns it off once apk is fixed.
  Images run 44667263988 is the first with it.
- Battery care (kernel r27, common r54) landed on main from its own
  session; the 13:07 reset was a panic from a charger-only module swap
  (COORDINATION.md has the rule and the unload order).
- Three commits from 13:20-14:00 had not reached origin (pushed from the
  wrong branch); all are on main now (4428b2a6, then c7fdbc3f).

## State 2026-11-20 13:20 AEDT (session "tablet-lab", coordinator): acceleration merged, USB debug secured, popup fixed

- tablet-lab coordinates the SM-T570 and this repo now (docs/COORDINATION.md
  rewritten: access `scripts/tab-ssh`, LOG at
  `~/Projects/cairn-os/.scaffold/tablet/LOG.md`, `agent-heavy` for builds,
  Cairn images allowed after a QEMU pass).
- **Merged to main and pushed:** samsung-gtactive3-common r52 (touch boost
  held while a finger rests; irqbalance with a per-core policy script:
  display/SPI CPU1, UFS CPU2, Wi-Fi/USB CPU3, none on CPU4-7; both live
  on the tablet, TESTPLAN D12) and duranium-build 0046 (builder image from
  `gitlab.nura.eco:5050/nura/nura-oci:edge`: postmarketOS is Nura; the 403
  is gone). Then duranium-usb-debug r7 + common r53 (below).
- **USB debug (r7):** key-only ssh, pairing on TCP 2324 with an on-screen
  Allow, indicator once per connection with Turn off, `duranium-usb-debug
  on|off|status|keys|unpair`; the shell 2323, register console 23, kernel
  log 24 and adbd only with `duranium.usb_debug=open`. Verified on the
  tablet from /run (D13); the open-mode gating and the polkit button need
  an r7 image. Host tools: `scripts/tab-ssh`, installer console.py and
  `scripts/duranium-update` fall back to / prefer the USB ssh; Cairn's
  `tsh` uses ssh, falls back to 2323. `scripts/tab`, `tab-shot`,
  `tab-unlock`, `duranium-check` still need open mode.
- **The USB popup:** Nura's usb-moded-notify looped because usb-signaller
  sees g_debug as the read-only "Netboot" mode. Fixed by a drop-in (in r7;
  live on the tablet in /etc/systemd/user since 12:09, survived a reboot).
- **Tablet state (26102701):** this PC's key in
  /etc/duranium-usb-debug/authorized_keys and /root/.ssh/authorized_keys;
  root's shadow `!` → `*` (no password; OpenSSH without PAM refuses a
  locked account); the usb-moded-notify drop-in in /etc/systemd/user.
  Restarted by the owner at 12:47 after my off/on test left debug
  unreachable (cause fixed, retest passed).
- **CI:** run 44652303985 built all packages; both dev images failed in
  mkosi's base install ("systemd-262.2-r0: failed to commit
  usr/sbin/init"), release images skipped (export unverified). Nothing
  published; PLAN.md step 1. check.yml's installer suite: 7 of 50 fail on
  its first run, the installer files unchanged since the variants merge.
- **Battery care / power saver:** the owner's request (2026-11-20) runs
  in its own session ("Battery care and efficient power saver").
- In flight: nothing running here. Local `build/shots/` has the D13
  screenshots; logs/test-runs/2026-11-20-responsiveness the D12 data.
- Next three steps: as PLAN.md "Next three steps (2026-11-20)".
- Waits for the owner: a NetworkManager profile on this PC for the
  tablet's USB link (link-local IPv6, IPv4 optional; the auto profile
  fails without the tablet's DHCP); the earlier items below (org site
  record, V1, D11 unplug, phoc MR).

## State 2026-11-19 07:05 AEDT (session "accelerate-factcheck"): responsiveness

- The owner found the tablet slow and asked for the facts and a fix, with
  no tablet attached: everything here is built and tested offline only,
  on local branch `accelerate-factcheck` (not pushed, not merged), for
  the owner to test at home (TESTPLAN D12).
- Facts, in docs/STATUS.md "Responsiveness": our CPU ranges already reach
  stock's maximum (stock caps the M3 at 1794 MHz too, so the levels above
  it are an overclock, now off PLAN.md); the memory bus sits at 1794 MHz
  (battery, not speed); what stock has and we lacked is the touch and
  launch boost and stock's higher resting floors; every device interrupt
  is on CPU0; AFBC is off; UFS bounces I/O above 4 GiB through swiotlb
  (about half the RAM); the display path makes no CPU copies. Nothing was
  timed on the device; D12.3 is the baseline.
- Built: samsung-gtactive3-common r51 = `gtactive3wifi-input-boost` (C,
  static; stock input_booster values, resting floors 455/650 MHz, touch
  832/1066 MHz until 500 ms after the last touch or pen event; writes only
  scaling_min_freq, restores on stop) + `gtactive3wifi-irqbalance.service`
  (Alpine irqbalance, CPU4-7 banned). Verified here: tests/input-boost
  7/7 on x86 glibc and in an aarch64 Alpine container (static musl, the
  package's own flags); the APKBUILD's build() and package() run in that
  container (binary, units, wants links); checksums match; shellcheck.
  Not run: abuild with the postmarketOS repositories, any image.
- No kernel change: the drivers are C and not the bottleneck; the
  storage fix (SysMMU for UFS) and AFBC (Mesa) wait for D12.3's numbers.
- CI: every `images` run since 2026-11-11 stops at postmarketOS's
  registry (403 on the token for docker-postmarketos:edge, runs
  43120752012 ... 44203340654). PLAN.md step 1.
- In flight: branch `accelerate-factcheck` only. No builds running.
- Next three steps: as PLAN.md "Next three steps (2026-11-19)".
- Waits for the owner: D12 on the tablet with a local image of the branch
  (👆 touch drags and their judgement of the feel); whether to push the
  branch (check.yml then compiles it); the CI registry fix; earlier items
  below (org site record, V1, D11 unplug, phoc MR).

## State 2026-11-11 (session "Multi-variant port"): image names

- Images have their own names now (`image_id`): `samsung-gtactive3-wifi_*`
  and `samsung-gtactive3-lte_*` (Wi-Fi was `samsung-gtactive3wifi_*`, the
  device id). Legacy routing, owner's choice, to delete later
  (`legacy_image_ids`): CI mirrors each Wi-Fi build under the old tags
  (`ci/publish-legacy`), the images recognise old-named UKIs/extensions
  (duranium-build 0045, tested on postmarketOS's transfers in a fake image
  root), and the tablet scripts match both (common package r50). Not yet
  run in CI (the images build fails at postmarketOS's registry) nor on a
  tablet: TESTPLAN V4. The org site now points at the renamed repo
  (pushed with the owner's consent).

## State 2026-11-11 (session "Multi-variant port"): repository renamed

- The repository is `exynos-linux/samsung-gtactive3` (renamed from
  samsung-gtactive3wifi on the owner's word; description and homepage
  updated). Checked right after: the old release download URL answers 301
  to the new name and the asset downloads (installed tablets keep
  updating); the old Pages URL is 404, the new one serves releases.json.
  References updated here (config.toml project.repo, docs, scripts, aport
  urls, duranium-build 0044), `ci/check-plumbing` now refuses the old name.
  The org site (exynos-linux.github.io) still lists the old repo and Pages
  URL in `site.config.toml`, so its records for this device fail until
  that is changed: the change (repo, pages, name, models) was prepared but
  pushing to the site was not allowed from this session; it waits for the
  owner.
  Never create a repository named samsung-gtactive3wifi again.
- The images build after the merge (run 42956428304) failed before
  building: postmarketOS's container registry refused a token for
  docker-postmarketos:edge, as in the run before the merge. Nothing new
  was published; the tablets stay on 26102403.
- The local folder is still named samsung-gtactive3wifi (only the remote
  moved; `git remote` points at the new URL).

## State 2026-11-11 (session "Multi-variant port"): `variants` merged into main

- Merged into main on the owner's instruction, before TESTPLAN V1: the
  next CI build publishes it to the Wi-Fi dev channels, and tablets on a
  dev channel update to it. Run V1 against that dev image first thing
  (one `.dtb` in the UKI, the initrd's usb-prep and watchdog, the package
  list, B1-B5); the previous version stays in the other A/B slot (boot
  counting). Release channels are unchanged until `scripts/pmos-verify`.
- Two Fable reviews (branch plumbing; setup.sh and the installer) found and
  this session fixed: the installer forgot a T575's variant after the first
  command, update --test on a variant without images, Python 3.11, stale
  test fixtures, the CI container's tools, a check for one .dtb per UKI,
  another model's firmware package refused. check.yml runs only on
  branches and pull requests, so on main the image build is the first
  compile of the device trees; the installer suite has not run anywhere.

## Earlier the same day 10:17 AEDT (branch `variants`, before the merge)

- The repo becomes the port of the whole Galaxy Tab Active3 family: Wi-Fi
  SM-T570 (`gtactive3wifi`, unchanged for installed tablets) and LTE
  SM-T575/T575N (`gtactive3`, bring-up, never booted). Research (three
  agents) in docs/VARIANTS.md and docs/re/modem.md. Found on the way: the
  GPL tree the docs called "T570 family" (`build/ref/gtactive3cs`) is the
  SM-T577U's; HARDWARE.md's Wi-Fi PCIe row was wrong (pcie0, not pcie1).
- A third party forked us for the T575: Forenzo/samsung-gtactive3LTE (live
  FDT facts used here; their branch rewrote uniLoader relocation, not
  taken). Inviting them to contribute here is the owner's call.
- Branch `variants` (local, not pushed): config `[[variant]]` +
  `device.family`, CI matrix per variant (LTE `images = false`), board DT
  split (patches/linux/0153: common dtsi + per-variant DTS) and the Shannon
  CP remoteproc sketch (0154, not enabled), kernel r26 with one DTB
  subpackage per variant, `samsung-gtactive3-common` (all shared device
  files, installed paths unchanged) + thin device packages (Wi-Fi r49, LTE
  r0), duranium-build 0043 (`contrib/samsung-gtactive3`, `DEVICE=`), U-Boot
  `gtactive3_defconfig` with both DTs and a T575 board entry, per-variant
  bring-up loaders, installer variant detection (`--bring-up`), check.yml.
- Not verified: nothing compiled here (this PC is a container without dtc
  or cross compilers; the owner chose CI-only), the installer suite cannot
  run here (no mkbootimg/avbtool/sfdisk/zstd; fails the same on main).
  Passed here: scripts/config check, tests/config (12), tests/firmware (7),
  shellcheck as on main, the regenerated kernel patch reproduces the kernel
  tree exactly, the Wi-Fi DTS preprocesses to the same tree.
- This PC has none of the laptop's worktrees (src/linux drv/* branches,
  build/wt/pmaports-duranium, build/wt/duranium): src/linux here was
  rebuilt from the export (base + gtactive3wifi.patch = r25, byte-exact)
  plus 0153/0154. On the laptop: apply patches/linux/0153-0154 to the
  kernel branch, and rebase any unexported device-package work (the audio
  session's r49 mic slider) onto samsung-gtactive3-common, before the next
  `scripts/pmos-export`.
- Next three steps: as PLAN.md "Next three steps (2026-11-11)".
- Waits for the owner: push the branch / open the PR (CI check.yml); the
  repository rename (docs/RELEASES.md, "Moving the repository");
  TESTPLAN V1 on the tablet before merging; a T575 owner for V2/V3; the
  modem's EFS read decision (docs/re/modem.md).

## State 2026-10-25 17:58 AEDT (session "Docs refresh")

- The owner reports (2026-10-25): rotation works, both cameras work, all
  eight cores and the GPU work. Which image the tablet ran is not recorded
  (the last entry had it on r24 with live modules; 26102403 = r25 is on the
  Phosh dev channel since 2026-10-24).
- Docs only, no code: STATUS.md GPU to ✔; Display and Touch rows no longer
  claim the new driver is unbooted (the DPU is card0 since cand/1025,
  touch passed in Phosh 2026-10-24); "GNOME on the GPU" is now "Desktop on
  the GPU" ✔ for Phosh; Home/Recent keys ? (bindings shipped 2026-10-22,
  not pressed in Phosh). README's status table rewritten (it still said the
  big cores did not come online), PLAN.md's next three steps and layer
  ticks, HARDWARE.md Wi-Fi chip BCM4375, TESTPLAN "Under test now" = r25.
- Nothing in flight from this session.
- Next three steps: as PLAN.md "Next three steps (2026-10-25)".
- Waits for the owner: which image the 2026-10-25 test ran on; headphone
  unplug (D11); proximity "near" test (D8); the phoc MR; Home/Recent key
  presses (D1.7).

## State 2026-10-24 18:45 (session "Mainline boot image testing": r25 integrated and exported)

- r25 = kernel cand/1035 (091acc188) + device r48 + duranium-build as
  before, exported to pmos/ and pushed to main (CI publishes it to the
  dev channels as 26102403). Kernel + DT only, per the user: no image or
  userspace package changes; the libcamera overlay (ci/overlays,
  "Suspend, updates, cores") is parked after review (verification ignored
  pmos/overlays; no local build path), no libcamera fork anywhere.
- cand/1035 = cand/1034 (boot reason logging, csis cacheable buffers +
  error-burst mute) + drv/cam-stock (cacheable buffers asked at
  REQBUFS/CREATE_BUFS, vb2-dma-contig dma-buf CPU sync, rear lens at the
  module's pan focus 592 = EEPROM 296 on the DAC scale, receiver AF opt-in
  af=1, EEPROM read retry) + drv/audio-fix 7e3507579 (RT5665 JD1+JD2 jack
  and buttons, LDO36 mic supply, 150 ms mic delay, jack works serialised;
  all review findings fixed, live-tested). Every branch had a release
  review (independent reviewers); drv/wifi-recover had a crash bug, fixed
  (721862e82) but not live-tested, so it waits for r26.
- Verified before the build: cameras on STOCK libcamera with the cand/1035
  csis/vb2-dc as live modules on r24 (user "good", fixed focus 592),
  audio live (jack, mic, no thump), auto-rotate D8 (r24).
- Packages built locally in 3 min 16 s on the warm ccache (kernel r25,
  device r48). The laptop froze once at ~17:37 (disk 98 % full, 12 GB
  swap, a build and two cleanups at once): one heavy job at a time;
  ~20 GB of stale outputs were removed with the user's OK.
- Tablet: still r24 (26102402~test1) with live modules (cam-stock csis +
  vb2-dc, audio rt5665, af=N, lens 592, PipeWire drop-ins renamed .off).
  USB is unplugged for charging; Tailscale pings but ssh hung. The r25
  update: the local image 26102403~test1 over USB when it is back, or the
  tablet's own sysupdate from the dev channel.
- Next (r26): drv/cam-caf ad4c4689c (autofocus that climbs in small steps
  and holds still, test with the user), standard V4L2 camera controls on
  the lens and sensors (the user wants them adjustable from apps),
  drv/wifi-recover, the audio session's r49 (mic slider). Old uncommitted
  worktrees from 2026-10-21..23 (mfc, power, sensorpwr, shub, wifi) are
  untouched, their owners' to finish.

## State 2026-10-24 17:05 (session "Audio fixes", side session of the coordinator)

- Owner's audio report on r24: phantom headphones (default sink
  Headphones, system sound lost), microphone "a blip, then silence".
  Causes: no jack detection in r24 (jd-src 0) plus a saved Headphones
  default; MICVDD (S2MPS18 LDO36) never switched on: sec-acpm allowed the
  write, but s2mps11.c still gave LDO36 the read-only ops. The blip was a
  ~100 ms power-up thump of the mic path.
- Live on the tablet until the next reboot (logs/test-runs/2026-10-24-audio):
  micldo test module (LDO36 on), live snd-soc-rt5665 (jd_src=2, IRQ gpa2-2,
  amic_delay=150) + new card module, jack UCM bind-mounted over
  /usr/share/alsa/ucm2/conf.d/gtactive3 (all in /var/tmp/audio-fix;
  `systemd-run sh /var/tmp/audio-fix/test.sh restore` undoes the modules and
  the UCM). The owner heard the speaker and recorded their voice.
- Permanent, handed to the coordinator and "Mainline boot image testing"
  for cand/1035 / r25: src/linux drv/audio-fix 7e3507579 (worktree
  build/wt/audio-fix; drv/jack and drv/audio2 superseded) and device r48
  (pmaports a5e035f, UCM JackControl/JackHWMute).
- Waits for the owner: plug and unplug headphones (owner.sh plug/unplug),
  then TESTPLAN D11 on r25 as booted. Follow-up: callaudiod aborts and
  xdg-desktop-portal segfaults whenever PipeWire is restarted (upstream
  behaviour, only seen with test restarts).
- Next three steps: unchanged, see PLAN.md "Next three steps".

## State 2026-10-24 16:50 (session "Animated screen rotation in phoc")

- The black frame on each rotation is phoc's modeset shield (userspace).
  A phoc patch turns the last frame into the new orientation instead
  (fit + darkened backdrop, 280 ms, then a fade): headless phoc on the
  tablet PASS on r24, phoc `meson test` 80/80 (logs/test-runs/
  2026-10-24-phoc-rotate). The user decided no userspace forks in our
  images, so it goes upstream only: MR branch output-shield-rotate in
  build/phoc/phoc-upstream (3 commits on phoc main), text in
  build/phoc/MR.md; nothing posted.
- Unmerged, keep or delete: pmaports branch phoc-rotate (temp/phoc,
  build/wt/pmaports-phoc), repo branch phoc-rotate (ci/build-native + arm64
  job, build/wt/main-phoc). Test files on the tablet in /run/phoctest
  (gone at the next reboot); /usr/bin/phoc not touched.
- Next three steps: unchanged, see PLAN.md "Next three steps".
- Waits for the owner: submit the phoc MR from their gitlab.gnome.org
  account (or say no); whether they want a live trial in their session
  (logs out once).

## State 2026-10-24 15:05 (session "Mainline boot image testing", cameras)

- The user asked for: all cores and both "GPUs" with activity (verified,
  see STATUS; Resources' first "GPU" is the DPU, card0, no render engine,
  so always idle), rotation (manual works, auto via the sensor hub
  session), and better cameras (focus, frame rate, quality).
- Rear camera fixed (missing since r21, DT 3b4f3e2d4 in cand/1033).
- Live test stack on the tablet, survives reboots on purpose:
  /var/lib/gta3-libcamera (libcamera 0.7.2 + aport patches 0001-0009 +
  build/scratch/camera/deliver/libcamera-aport/0010-0012, built in
  localhost/lcbuild-arm64 from build/scratch/camera/lc-src, incremental:
  build/scratch/camera/lcbuild/inc.sh), tuning in .../tuning/simple
  (AGC target 1.8, rear Af block), selected by user systemd drop-ins
  ~ratrad/.config/systemd/user/{pipewire,wireplumber}.service.d/
  gta3-libcamera.conf. Redeploy: build/scratch/camera/redeploy-lc.sh
  (restarts PipeWire and the portals, which die with it). To leave the
  test: remove both drop-ins and restart.
- csis 64de959b7 (cacheable buffers, IRQ burst guard) runs as a live
  module on r23; r24 does not carry it yet (coordinator has the commit).
- Next for cameras: AF/exposure on real scenes with the user, rear CCM/AWB,
  then 0010-0012 into the libcamera aport (pkgrel bump) and the drop-ins
  out (coordinator's condition).
- Never run `cam` while Snapshot streams: both receivers share /dev/media0
  and the second pipeline broke the first stream (front ERR_OVER loop).

## State 2026-10-24 14:02 (session "Auto-rotate: BCM4775 sensor hub accelerometer")

- Auto-rotate works on the tablet (live): r23's bcm4775_shub boots the
  hub, but the hub found no sensors because S2MPS18 LDO35/42/43 (stock
  always-on) were off. A test module (build/dkmod/shubldo, only those three
  LCTRL registers, the user's go, device lock, coordinator told) switched
  them on at 13:48; after `echo 1 > /sys/kernel/debug/spi1.0/boot` and an
  iio-sensor-proxy restart, Phosh rotates when the user turns the tablet
  (~1 s, no animation: iio-sensor-proxy's 700 ms read interval, phoc).
  Evidence: logs/test-runs/2026-10-24-shub; STATUS.md Auto-rotate/Sensors.
- The rails stay on only until the next reboot. Permanent fix: src/linux
  `drv/shub3` 9655ab5e4 on cand/1032 (worktree build/wt/shub3), handed to
  the coordinator for the next export; retest D8 (TESTPLAN.md) after the
  A/B update boots.
- Next three steps: unchanged, see PLAN.md "Next three steps".
- Waits for the owner: proximity "near" test (cover the sensor) when
  convenient.

## State 2026-10-24 14:10 (coordinator)

- Tablet: IMAGE_VERSION 26102401, kernel #24 (r23), all eight CPUs online,
  Wi-Fi up. Auto-rotate works live with LDO35/42/43 switched on by a test
  module (logs/test-runs/2026-10-24-shub); the rear camera EEPROM answered
  with LDO45 (live test by "Mainline boot image testing").
- Kernel candidate cand/1033 (adfe545e7) = cand/1032 + drv/shub3 9655ab5e4
  (sensor rails, stock voltages) + drv/cam 3b4f3e2d4 (EEPROM vcc = LDO45).
  drv/wifi-recover stays out until its live-swap test.
- The user asked for r24 published and installed: "Suspend, updates,
  cores" owns the export (pmos-export, CI publishes) and a local Phosh build
  + scripts/duranium-update over USB; the coordinator asks the user before
  the reboot. After the boot: TESTPLAN D8, rear camera in Snapshot, then
  the suspend/RTC/touch test, the Wi-Fi live-swap (gate "#25"), and phoc's
  step 2 (session restart), one at a time.
- scripts/duranium-update has an uncommitted 3-line change in the main
  checkout from another session.

## State 2026-10-24 17:20 ("Suspend, updates, cores")

- The owner: everything in the kernel and drivers, the Phosh image stays
  unmodified (no forks, no overlays). The libcamera patch overlay is
  PARKED, not pushed: local branch ci/overlays (worktree
  build/wt/ci-overlays): 675d2fbb (ci/overlays, native arm64 job, export
  guards) + WIP 209d6231 (the r25 integrator's review fixes: verification
  covers pmos/overlays, `ci/overlays build` in postmarketOS's arm64
  container with --entrypoint /bin/sh, -F0 proof, check-image, pipefail;
  pmos/overlays/temp/libcamera with 3 patches that fit upstream r4 and
  apply in arm64 abuild prepare). Revive only on the owner's word.
- Kept from that work, already on main: the pkgname check idea is in the
  parked branch only; main's scripts/pmos-export has the sums-order check
  (3481da96) and CI keeps the kernel ccache (2a7c815a).
- Focus now: kernel root causes. (1) The r24 boot hang the watchdog did
  not reset (C2 with eight cores suspected; r25 logs RST_STAT and the PMIC
  on/off sources at boot, drv/bootreason). (2) Deep sleep and battery, in
  drivers.

## State 2026-10-24 16:10 ("Suspend, updates, cores": export owner for r23-r25)

- Tablet: r24 local 26102402~test1 (kernel cand/1033 #25, device r46),
  booted 15:52 and blessed; 26102401 (CI r23) is the fallback. CI also
  published 26102402 (same r24). First r24 boot attempt (15:37) hung, the
  watchdog did not reset it, forced restart: docs/STATUS.md Hang recovery,
  TESTPLAN B5 counter. No pmos-verify for r24.
- Verified on the device today: all eight CPUs + gpu_busy_percent (r23,
  26102401), D8 auto-rotate (r24, user). Not yet: screen-off suspend +
  HX83102E restart after sleep + Active key hold (scripts ready, waits for
  the coordinator after the camera retest).
- In flight for r25: drv/bootreason (build/wt/bootreason, 2 commits on
  cand/1033: PMIC power-on/off sources + RST_STAT logged at boot), device
  r47 (pmaports ece1619: exynos9810_c2=0), plus the camera session's
  drv/cam fix when handed over. CI keeps the kernel ccache now (2a7c815a);
  scripts/pmos-export refuses sums out of source order (3481da96).
- Next three steps: (1) r25 = cand/1034 + device r47, export, local build,
  A/B install, one reboot; (2) suspend/touch/Active-key test on it;
  (3) count clean boots (B5) to 5, then pmos-verify.

## State 2026-10-24 09:45 (coordinator "PostmarketOS duranium bootloader unlock")

- Repo: exynos-linux/samsung-gtactive3wifi, values in config.toml
  (scripts/config), device-template skills and rules (be17aaf).
  scripts/notify-user is silent by default now (0b9a46d; `--sound` only if
  the user asks again).
- Kernel exports since the entry below (pmos/, newest last): cand/1028 r19
  (panel powered down on blank), cand/1029 r20 (all eight CPUs:
  drv/bigcores-b), cand/1030 r21 + device r44 (camera fixes and tuning),
  cand/1031 r22 (panfrost gpu_busy_percent), cand/1032 r23 + device r45
  (suspend on screen off, touch after sleep). Device r39 (Phosh suspend,
  blank 3 min, suspend 10 min), r41 (C2 idle on by default). Local image
  version in build/wt/duranium: 26102219~test4. pmos/VERIFIED does not
  exist yet: release channels get nothing until an on-device pass of an
  export (scripts/pmos-verify).
- Tablet: on the dock, charging (52 %). The BCM4375 firmware crashed at
  08:51 (session "BCM4375 Wi-Fi firmware crash after boot") and the tablet
  was unreachable; at 09:13 it rebooted (a himax touch module swap by
  "Suspend, updates, cores", not the Wi-Fi crash) and the user unlocked it. Booted:
  Phosh 26102304 (CI), kernel #19 (built 2026-10-23 04:42), `maxcpus=4` on
  the command line (big cores unused in this image). Wi-Fi came back by
  itself after the reboot (brcmfmac at 74 s, firmware 18.41.117), USB
  console and Tailscale both up. The user is on the tablet: nothing that
  reboots or may panic it without asking them first.
- In flight: the Wi-Fi session works offline on why the firmware crashed
  and on a recovery path that needs no human; its driver-reload test is on
  hold and gets slotted at a quiet moment (with the next A/B reboot).
  Update 09:55: the user said go; the Wi-Fi session tests its
  gtactive3wifi-wifi-recover.service (stage A brcmfmac-only reload, stage
  B controller remove) under build/device.lock. Next: one A/B update
  straight to r23 (kernel cand/1032 + device r46, CI images run
  40033972155, which replaced 40032957684), skipping r22, so the user
  types the passphrase once; the user runs `sudo updatectl update` and
  reboots. Update 10:30: the Wi-Fi recovery test PASSED (both stages, no
  oops); its service is device r46 (83cea320), in that run. The user
  installed 26102305 into the spare slot and was told not to boot it.
  drv/wifi-recover (bfae8d748) waits for a live test on r23, then
  cand/1033.
- Next three steps (same as PLAN.md): see PLAN.md "Next three steps".
- Waits for the owner: a console route (USB cable to the laptop, or the
  tablet back on Wi-Fi) when the Wi-Fi session needs it; charging current
  3.1 A (stage 2) yes/no; Night Light toggle in Settings -> Displays;
  power-key wake from suspend; battery drain with the cable out.

## State 2026-10-23 00:40 (lead: test campaign session "Camera firmware drivers and OS setup")

- Tablet: slot A = GNOME 26102218 (CI, gnome_edge-dev, installed by the
  tablet's own systemd-sysupdate), slot B = Phosh 26102219~test2 (local,
  kernel r14 cand/1023, device r33), booted and blessed. BOOT = new chain
  (U-Boot drv/bootchain2: wdt_handover=keep 82.6 s, off-mode charging
  screen, fallback-Linux auto-restart); previous chain in
  build/images/boot-chain-prev.img. /etc/modprobe.d/gta3-firstboot-test.conf
  on the tablet is useless (initrd loads those drivers) and can go.
- Kernel candidates: cand/1023 = cand/1022 + drv/suspend + drv/cam +
  drv/hwgaps (tested), cand/1024 = + drv/cam e8606290d (RAW10 in 16-bit
  words, tested as a live module) = aport r15 (building). C2 stays off.
- Device package r35 (pmaports-duranium): suspend gate + Wi-Fi unload hook,
  camera conf, firmware import from the ESP, podman + Alpine, tuning,
  switch-ui, sysupdate retry with vacuum, deadline reboot fix.
- Images: build-image.sh asks for the PipeWire audio backend (pmaports.py
  ignores _pmb_select: images had pulseaudio). Local test builds are
  numbered <newest published+1>~test<N> (mkosi.version); CI publishes
  YYMMDDNN to the -dev channels; nothing is in pmos/VERIFIED yet.
- Results: logs/test-runs/2026102{2,3}-*/results.tsv, docs/STATUS.md,
  docs/TESTPLAN.md. Unattended reboots: scripts/tab-unlock (ClaudeKeys
  DISK_ENCRYPT_AND_USER_PASSWD = disk passphrase; not the login password).
- Waiting for the user (physical): power-key wake from suspend, battery
  drain with the cable out, camera in daylight (Snapshot), microSD card,
  NFC tag, touch/pen/audio/backlight looks, Night Light (needs login).

## State 2026-10-22 afternoon (coordinator)

- Tablet: GNOME 26102209 is the known-good version. 26102210 (kernel r11)
  hung at boot in C2 and was marked bad by boot counting. At ~13:54 the
  "MCT" session's RECOVERY test kernel hung the tablet with no USB: the user
  must force-reset; its RECOVERY backup (sha256 4412b2b8...) is in that
  session's scratchpad (2107732b.../scratchpad/recovery-backup.img).
- Kernel candidate: src/linux `cand/1022` = integ + drv/gpu-ui (AArch64 Mali
  page tables: GPU memory test 0/230 failures, MMU IRQ unmask, DPU refuses
  foreign dma-bufs) + drv/dvfs2 (ACPM DVFS on channel 0, PLL measured
  208-1950 MHz; CPU idle) + drv/blank (backlight off on screen blank) +
  drv/battemp-stage1 (ADC NTC zones, 1.5 A caps) + C2 disabled in the board
  DT. Package r12 (build/wt/duranium-localpkgs); r9-r11 in build/wt/held-apks
  (never use). Merge cand/1022 into integ/gtactive3wifi after r12 boots fine.
- Images: the image session builds GNOME 26102212 + Phosh 26102213 on r12
  with device r23. Deliver with scripts/duranium-update (also works from the
  initrd prompt now; extensions are skipped there).
- Night Light works through the HX83102E panel's own digital gamma (DCS
  0xC1 banks 1-3), NOT the DPU HDR block (that garbled the picture and once
  faulted the panel).
- Open: C2 wake-up (PMU wake events / MCT broadcast; CPU-idle + MCT
  sessions), big cores (cluster powers on via GRP1, core never runs:
  CRP_PM_CC1_0), charging current 3.1 A (waits for the user), cameras
  (drv/cam, first power-up test pending), auto-rotate (sensor-hub session),
  suspend (nobody yet).
- Laptop: 16 GB disk swapfile under zram + vm.min_free_kbytes=131072 after
  an OOM killed the desktop app; heavy jobs hold build/kbuild.lock, -j8.

## Who / what

- Device: Samsung Galaxy Tab Active3 Wi-Fi, **SM-T570** "gtactive3wifi", Exynos 9810
  (4× A55 + 4× Samsung M3 big cores, Mali-G72 MP18), hw_rev 4, bootloader
  T570XXSFEYI1 (unlocked, KnoxGuard cleared). The serial is never published.
- Repo: `/home/borysthebear/Projects/gtactive3-mainline` = public
  github.com/exynos-linux/samsung-gtactive3wifi (moved from dixonSolutions/gtactive3-mainline on
  2026-10-23; git identity: dixonSolutions, repo-local). Its public plumbing
  (repo, update server, Pages, channels, signing key fingerprint, debug tool)
  is in config.toml, read through scripts/config. Commit in small chunks, end messages with
  `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`, push `main`.
- **Mission (user's words, condensed):** postmarketOS **Duranium** (immutable,
  systemd, UKI + systemd-boot, A/B sysupdate) with a **GNOME-family UI**
  (`postmarketos-base-ui-gnome-duranium`; never KDE Plasma; the user only
  excluded Plasma). 2026-10-22: **maintain both a GNOME image (`UI=gnome`,
  the daily system / fallback) and a Phosh image (`UI=phosh`, the one to test
  now)**; the user wants several UI download options later, with releases
  rebuilt automatically on new postmarketOS publishes, so the project only
  maintains drivers and kernel: keep device packages UI-neutral. Every piece of hardware working and verified on the device, drivers
  built from Samsung's GPL kernel + stock DT + the reverse-engineered firmware,
  plus a USB debug layer (on in dev builds, removable for release). Long-horizon:
  don't stop, adjust tactics, commit and merge as you go.

## Standing rules from the user (obey)

1. **Never strand the tablet.** Every boot test must come back to the USB console
   without a human. The only access is the USB cable (never unplugged).
   Volume Up in the bring-up init = reboot to Download mode (escape hatch).
2. If something breaks and you can detect it: **adjust, detect, find out why**,
   don't stop and ask. ("keep testing, if it breaks ... adjust, detect it,
   discover why"; "I don't care about the backups".)
3. Verify the GUI **yourself** (gnome-shell/gdm status, Mutter D-Bus
   `org.gnome.Mutter.DisplayConfig.GetCurrentState`, `org.gnome.Shell.Screenshot`
   pulled back with `scripts/tab-get`). Ask the user only for physical input
   (a finger on the touchscreen, pressing keys).
4. Android is **wiped** (sda24 metadata, sda25 super, sda28 cache, sda31 userdata),
   approved and done. Never touch efs/sec_efs (sda1/2), param/up_param (sda3/4),
   persistent (sda17), bootloader LUNs, vbmeta, RPMB. Never a Samsung "factory
   reset" (re-arms KnoxGuard).
5. Never commit Samsung firmware, decompiled code, keys (firmware/keys), the
   serial or the MAC addresses (firmware/device-snapshot). Raw REA/Ghidra output
   stays in gitignored `firmware/re-targets/`; write our own interface docs to
   `docs/re/`.
6. 2026-10-22 the user asked for parallel sessions/agents. Several Claude
   sessions now share the tablet and the laptop: follow docs/COORDINATION.md
   (device lock, A/B updates only, one image builder, memory rules). The
   coordinator session is "PostmarketOS duranium bootloader unlock".
7. Don't use `pkill -f`/`pgrep -f` with patterns that also match your own shell
   command line (it killed/matched our own shells several times). Use PIDs.
8. Some destructive/remote-write actions get blocked by the auto-mode
   classifier: then explain and ask the user.
9. sudo: the user stored a ClaudeKeys secret named SUDO; feed it to `sudo -S`
   on stdin (here-string), never echo/print it.

## Boot chain today (all automated, ~35 s per flash cycle)

S-Boot (Samsung, stock signed vbmeta) → **BOOT partition** (sda12) =
mkbootimg v2 image whose "kernel" is **uniLoader** (src/uniLoader) →
- bring-up: Linux 7.3 (src/linux branch `gtactive3wifi`) + nolibc init
  (`initramfs/init.c`), built by `scripts/build.sh` → `build/images/boot-mainline.img`.
- RECOVERY (sda13) holds the same bring-up Linux (never put new stages there).

`scripts/devd.sh` runs in the background (check with `ps`): whenever the tablet
is in Download mode (USB 04e8:685d) it flashes `build/images/boot-mainline.img`
to BOOT with heimdall (and a one-shot `build/images/recovery-queue.img` to
RECOVERY if present), logging to `logs/devd.log`. The bring-up init arms "any
reset → Download mode" (PMU INFORM3 0x1406080c = 0x12345671), so crashes come
back to devd automatically. `build/images/boot-good.img` = last known-good
bring-up image (ca1898aec3d8); boot-mainline.img is currently that same image.

Console tools (host): `scripts/tab wait N`, `scripts/tab "<cmd>"`,
`scripts/tab-get REMOTE LOCAL [BYTES]`, `scripts/tab-put LOCAL REMOTE`. Wrap in
`flock build/tab.lock …` if anything else might use the console. Tablet =
IPv6 link-local fe80::57:aff:fe00:1 on the cdc_ncm interface (enp0s20f0u5).
Console commands: dmesg, peek, dump, poke, cat (raw stream), write, put, run
PATH [ARGS], insmod, rmmod, ls, i2cw/i2cr (/dev/i2c-0), ulog (U-Boot RAM log at
0x8ff100000, survives resets), evread, discard (Android partitions only),
reboot [download|recovery|normal]. pstore: `/sys/fs/pstore/console-ramoops-0`.

## Hardware status (live-tested on the device unless noted)

| Block | Status |
|---|---|
| UFS (64 GB Micron, HS-G3 x2) | works, loaded at boot |
| USB gadget (DWC3 + PHY, MAX77705 COM_USB via bit-bang) | works, cable always plugged |
| Watchdog (s3c2410_wdt 9810, cluster 0) | works; init arms 30 s + kicks; WDT reset → S-Boot boots BOOT, RST_STAT 0x14060404 bit 24 |
| HSI2C_40 (exynos-usi + i2c-exynos5 9810) | works (MAX77705 0x66 ID 0x05, SM5504 0x14, USB-C 0x25) |
| simpledrm on the S-Boot framebuffer 0xca000000 | works |
| Backlight (DSIM DCS 0x51, both links) | driver accepts 0..3977; visual confirmation pending |
| TMU thermal (8 zones) | works |
| ACPM + S2MPS18 read-only (45 regulators, PMIC ID 0x09) | works |
| MAX77705 charger + fuel gauge (simple-mfd-i2c) + hwmon | works; **USB-C/BC1.2 input detection** (max77705_usbc_psy, drv/power) feeds the charger's input limit (SDP 475 mA on the laptop port: the battery drains ~50-130 mA under load, watch it); driver caps fast charge at 1.5 A; battery temp 29.5 °C reads |
| Panfrost (Mali-G72 0x6221 r0p1) | probes, runs jobs; GPU power-domain link dropped while CONFIG_PM=n |
| UFS after U-Boot | **root cause of the hung Duranium initrd**: U-Boot's exynos UFS driver makes the FMP SMC that sets DESCTYPE 3 (128-byte PRDT entries, needed for U-Boot's own transfers after its host reset). Linux without inline crypto used 16-byte entries -> every multi-entry PRDT read at the wrong stride -> IS.SBFES bus faults. Fix: CONFIG_SCSI_UFS_CRYPTO=y + BLK_INLINE_ENCRYPTION (Linux sets the same format itself; AES-256-XTS keyslots appear). Also a 32-bit UFS DMA mask like Samsung's (harmless). Asking the SMC for DESCTYPE 0 in U-Boot breaks U-Boot's DMA entirely. |
| Wi-Fi (BCM4375 B1, PCIe ch0) | **works with WPA2-PSK** (user's network): needed brcmfmac to write host_cap (IPC API version) into the shared area, else the 18.41 firmware never consumed RX buffers (no EAPOL). DHCP, DNS, HTTP ok; some loss at -80 dBm. Creds: `scripts/wifi-push-creds --cache` (user ran it) -> build/secrets/{wpa_supplicant.conf,wifi.nmconnection}; tests: `scripts/wifi-test`, /run/wpa.sh + /run/route.sh pattern (console `run` passes few args, use scripts) |
| Bluetooth (BCM4375 on UART_BT) | **works**: hci0, BCM4375B1 SEMCO, patch RAM build 0171 |
| Audio (A-Box + RT5665 + RT5510) | card registers, headset jack input, both PCMs stream (pcm-tone, 48 kHz); audibility not yet confirmed by a human |
| S Pen (Wacom W9019, HSI2C_23) | **works**: input "Wacom W9019 Digitizer" 17222x10764 |
| NFC (S3FWRN5, HSI2C_20) | nfc0 registers (load rfkill first); NCI init untested |
| Vibrator, flash LED (RT8547), hall sensor | drivers bind; vibrator polarity confirmed by the user (low = off); "vibrating like crazy" in GNOME was haptic feedback on bogus touches (fixed by the touch fix); hall polarity correct (open = 1) |
| Grip sensor (A96T3x6, HSI2C_34) | bus now 100 kHz (10 kHz could not be divided); needs S2MPS18 LDO40 (read-only PMIC) |
| SM5504 pogo MUIC | probe fails: no USB role switch on dwc3 yet |
| Touch (SPI21, Himax HX83102E) | **works** (user-tested drags): byte-wide bus access + burst for the ID; event frames sometimes start one byte early (in the dummy byte) -> read it too and pick the alignment with a valid checksum (0 bad frames in 1400); SPI at 10 MHz (at 7 MHz MISO sampled 1 bit late after re-probe) |
| Keys | Home/Back/Recent/Power/Vol+ work. **Vol− and Active: gpa0-4/5 never change level even when held** (user confirmed) → wired elsewhere on hw_rev 4 |
| Big cores, cameras, sensors (BCM4773 hub), GPS, fingerprint | not done (cameras/sensors/FP blocked, see docs/re locally) |

Kernel branches: `src/linux` `gtactive3wifi` = live-tested; `integ` =
integration. Driver worktrees: `build/wt/{touch,power,cpu,wifi,audio,gpu,misc,...}`
(branch `drv/<track>`). Previous agent reports: `build/team/prev-*.json`.

## Boot chain to Duranium

**2026-10-21 20:51: the full chain booted Duranium** (S-Boot -> uniLoader ->
U-Boot -> systemd-boot -> UKI, postmarketOS kernel, verity /usr; the debug
console on port 23 answered inside it). It then hung in the initrd on UFS
DMA above 4 GiB (fixed in the kernel, image rebuild pending at the time of
writing). Loop protection is in place and tested:
- uniLoader: record stage 4 (jumped) on entry -> fallback Linux once; U-Boot
  sets stage 7 in board_quiesce_devices() at the OS handover.
- To leave a hung Duranium: `scripts/tab "poke 0x8ff1ff04c 4"` then
  `scripts/tab "write /proc/sysrq-trigger b"` (console reboot calls sync(),
  which hangs if the disk does). The next run boots the fallback Linux.
- devd.sh: same image back in Download mode 3x in 3 min -> boot-good.img.

(History below.)

uniLoader **dual payload** (`build/wt/uniloader`, branch `drv/chainload`) +
U-Boot (`build/wt/u-boot`, branch `drv/chainload`), packed by
`scripts/mkboot-chain.sh` (MODE=chain|linux|wdt-test →
`build/images/boot-chain*.img`; it never writes boot-mainline.img).
uniLoader: if RST_STAT bit 24 (watchdog reset) → boot the fallback bring-up Linux;
else set INFORM3=download, arm the cluster-0 watchdog (~82 s), jump to U-Boot.

- **wdt-test PASSED** (19:40): armed, reset after ~90 s, fallback Linux came
  back by itself, RST_STAT 0x01000000.
- **Real chain FAILED** (19:42): U-Boot crashed ~3 s in: synchronous abort,
  NULL `gd->jt` in `console_setfile()` (common/console.c), because
  `input_stdio_register()` assigned stdin=button-kbd during `stdio_add_devices()`
  before `jumptable_init()`. With INFORM3=download every crash went to Download
  mode and devd reflashed the same image: a **flash loop** (stopped by copying
  boot-good.img to boot-mainline.img).
  - **Fixed in U-Boot** (commit 382fdf18 on drv/chainload). Not rebuilt/tested yet.
  - **TODO before the next chain test (loop protection):**
    1. devd.sh: if the same image is flashed ≥3 times within ~3 min, flash
       `boot-good.img` instead and log it.
    2. uniLoader: a "chain attempt pending" marker in RAM (the handoff area
       0x8ff1ff000 survives resets and Download mode, as ulog showed); if set on
       entry → boot the fallback and clear it; U-Boot clears it right before
       `bootefi`.
  - Then `MODE=chain scripts/mkboot-chain.sh`, `cp build/images/boot-chain.img
    build/images/boot-mainline.img`, reboot download, watch, read `ulog` from the
    fallback Linux. Restore boot-good.img into boot-mainline.img afterwards.
  - The Volume Down escape in uniLoader does not work (pin dead, see keys).

## Duranium image (in progress)

- Trees: `build/wt/duranium` (duranium-build, branch gtactive3wifi),
  `build/wt/pmaports-duranium` (pmaports, branch duranium-gtactive3).
- Build: `cd build/wt/duranium && UI=gnome sh contrib/samsung-gtactive3wifi/build-image.sh`
  (`SKIP_APKS=1` reuses the packages in `build/wt/duranium-localpkgs`; single
  packages: `sh contrib/samsung-gtactive3wifi/build-apks.sh main/duranium-usb-debug
  device/testing/device-samsung-gtactive3wifi`). Logs: `logs/duranium-build-N.log`.
  After kernel changes: `contrib/.../kernel/refresh-aport.sh` (snapshots src/linux
  gtactive3wifi into the distfiles cache, regenerates the config, rewrites checksums).
- Fixed so far: podman entrypoint override, abuild key trust (-i), target strip,
  static usb-prep helper, kernel from a branch snapshot, local source copy,
  SELinux (`--security-opt label=disable`).
- **Current failure (attempt 8, exit 3):** apk "unable to select packages":
  `device-samsung-gtactive3wifi-bootimg` requires `uniloader-samsung-gtactive3wifi`
  and `firmware-samsung-gtactive3wifi-bootdtb` (not built). Duranium boots via
  EFI/UKI, so stop the -bootimg subpackage from being installed in Duranium (drop
  it or its install_if), or build those two aports (src/pmaports branch gtactive3wifi).
- Debug layer in the image: `duranium-usb-debug` (NCM gadget, same IDs/addresses as
  the bring-up; busybox root shell on **TCP 2323**; ssh; klog; watchdog),
  `duranium-usb-debug-adb` (adbd on FunctionFS: `adb shell`), and the **bring-up
  register console on TCP 23** (`gta3-console`, built from initramfs/init.c with
  `-DCONSOLE_STDIO -include initramfs/console-libc.h`, socket-activated) in the
  device package's -initramfs subpackage, so scripts/tab keeps working in Duranium.
  Off switches: drop the packages (release), `duranium.usb_debug=0` /
  `duranium.usb_debug_adb=0` on the cmdline, disable `duranium-usb-debug.target`.
- Disk: GPT with 4 KiB sectors written at LBA 0 of /dev/sda31 (nested). U-Boot
  exposes it via blkmap; the initrd via a udev rule
  (90-gtactive3wifi-nested-gpt.rules). Installer:
  `contrib/samsung-gtactive3wifi/install-to-userdata.sh` (streams over the console).
- Host cross toolchain for user space: aarch64-linux-gnu-gcc +
  sysroot-aarch64-fc44-glibc (`--sysroot=/usr/aarch64-redhat-linux/sys-root/fc44`,
  needs an empty libatomic_asneeded.a, see build/console/lib).

## Firmware / reverse engineering

- Stock firmware + vendor files: `firmware/extracted/` (INDEX.md),
  `firmware/fs/<part>`. Wi-Fi chip = BCM4375 B1.
- REA (`~/.local/bin/rea`; `source ~/tools/rea-env.sh` for Ghidra 12.1.4 + JDK 21)
  decoded 30 targets (ABOX SRAM/DRAM/IVA, audio HALs, camera HALs, sensor hub
  firmware + HALs, GNSS, fingerprint): `firmware/re-targets/INDEX.md`.
- T570-family GPL kernel: `build/ref/gtactive3cs` (lineage-12.1);
  Galaxy S9 downstream: `src/samsung-9810-ref`.

## Duranium boot status (2026-10-22 00:30)

GNOME initial-setup screens appeared on the panel (user saw them) with
image 14 (kernel r2). Issues found and fixed on the way:
- UFS FMP PRDT format after U-Boot -> SCSI_UFS_CRYPTO=y
- systemd-repart EBUSY mounting the new LUKS root -> BLK_DEV_WRITE_MOUNTED=y
- in the booted system only sshd listened (no key) -> sockets IgnoreOnIsolate
  + duranium-debug-sockets.service; dev key: build/secrets/duranium-dev-ed25519
  (public half via local extra tree build/duranium-extra, never committed),
  `ssh -i build/secrets/duranium-dev-ed25519 root@fe80::57:aff:fe00:1%enp0s20f0u5`
- Wi-Fi profile baked as /usr/lib/NetworkManager/system-connections/wifi-dev.nmconnection
  (local extra tree only). Build with:
  `MKOSI_CONTAINER_ARGS="-v $X:$X:ro" SKIP_APKS=1 UI=gnome sh contrib/samsung-gtactive3wifi/build-image.sh --extra-tree=$X`
- If locked out of a booted Duranium: ask the user for Power+VolDown 10 s, then
  VolUp+VolDown while plugging USB = Download mode (devd flashes boot-mainline.img;
  keep that = boot-good.img while testing).

## Next steps, in order

1. Loop protection (devd + uniLoader marker), rebuild the chain with the U-Boot
   fix, test; iterate with `ulog` until U-Boot reaches `bootefi`.
2. Fix the -bootimg dependency, build the GNOME Duranium image, check its layout.
3. Install into sda31, boot U-Boot → systemd-boot → UKI; verify over the console
   (port 23), adb and ssh; verify GNOME yourself (screenshot).
4. Touch (ID 0), keys (Vol−/Active), GPU acceleration in GNOME, big cores,
   Wi-Fi, audio, the rest: each live-tested, merged into `gtactive3wifi`, patches
   exported (`scripts/export-patches.sh`), pushed.
5. Keep PLAN.md / HARDWARE.md updated. Report to the user in the morning: what
   works (with evidence), what doesn't, and a short list of finger tests.

## Releases and the update server (2026-10-22)

GitHub is the update server: `.github/workflows/images.yml` rebuilds Phosh +
GNOME images (release and `-dev` channels) when postmarketOS publishes a new
Duranium build (checked daily) or `pmos/` changes, and publishes each channel
as a GitHub release with a signed SHA256SUMS. Images point sysupdate there
and trust only `pmos/sysupdate-public-key.asc` (key + revocation cert:
`build/secrets/sysupdate-gnupg`, repo secret `SYSUPDATE_SIGNING_KEY`).
**Release gate:** run `scripts/pmos-export` (then commit + push) only after
an on-device test; CI publishes exactly what is in `pmos/`. Images carry no
vendor firmware: it goes to `/var/lib/firmware` (`scripts/firmware-to-tablet`).
`build-image.sh CHANNEL=dev` (default) = with the USB debug layer;
`CHANNEL=release` = without. Details: docs/RELEASES.md.
