# SM-T570 → postmarketOS Duranium: plan

Goal: postmarketOS **Duranium** (immutable, systemd, UKI + systemd-boot, A/B
systemd-sysupdate) with a complete GUI and every piece of hardware working, plus a
USB debug layer (NCM gadget + root console) that is on by default for development
and can be disabled.

Work is split into layers. Each layer is built by parallel agents in their own
branches (`drv/<track>` in src/linux, worktrees under build/wt/), reviewed by an
independent agent, then integrated and tested live on the device, one layer at a
time, through the USB console. A layer is only merged into `gtactive3wifi` after
its live test passes.

Rule for every test: a failure must come back to the USB console without anyone
touching the tablet (reset → Download mode → automatic reflash, or watchdog reset
→ BOOT). No boot stages on RECOVERY.

## Next three steps (2026-11-20)

1. The dev images build again. The registry 403 is fixed (duranium-build
   0046). Run 44652303985 then failed in mkosi's base install with
   "systemd-262.2-r0: failed to commit usr/sbin/init: No such file or
   directory" (and udevadm). Cause, reproduced here 2026-11-20 with clean
   upstream duranium-build (`device-qemu-amd64 ui-phosh`): an upstream
   regression, not our packages. mkosi's tools tree takes apk-tools
   3.0.10 (built 2026-11-19, after upstream's last green build on 11-17);
   with the container's apk 3.0.9 (`--tools-tree=`) the same base installs
   without errors (that route then fails at the initrd for lack of GNU
   cpio). apk 3.0.10's "db: adopt only real directories" / "fs: resolve
   fsdir paths within the destination root" are the likely changes, with
   Nura's bin-merge (postmarketos-base 79). Upstream's next scheduled
   build will hit it too. Fix (owner's OK, 2026-11-20): duranium-build
   0047 overlays Alpine's static apk 3.0.9 (sha256 checked) through a
   mkosi sandbox tree; with it the upstream qemu-amd64 build installs
   systemd, its base, initrd and extensions. `APK_PIN=` turns it off once
   a fixed apk or systemd is out (mkosi.tools.conf scripts are ignored by
   mkosi; a local tools package directory needs openssl in the container).
   Draft upstream report for the owner: docs/upstream/apk-3.0.10-systemd-binmerge.md.
   Then TESTPLAN V1, V4 and D12/D13 with the dev image, and D14.7
   (battery care on after the first boot: kernel r27 +
   samsung-gtactive3-common r54, merged 2026-11-20).
2. Ship USB debug security and responsiveness in one image (common r53,
   duranium-usb-debug r7, both on main): shipped, live in 26112002~test2
   (checked 2026-11-20 21:23, STATUS). Left: D13's open items (Turn off button, off
   across a boot, open mode via the boot menu) and D12 (touch with the
   interrupts moved, power-saver, the D12.3 baseline).
3. Cairn OS on the SM-T570 (workstream 5 of `~/Projects/cairn-os/ROADMAP.md`;
   Cairn stays on Nura with apk, owner's correction 2026-11-20): the
   kernel, firmware and device packages stay apks as here, wired into the
   Cairn image with the images session; flash a Cairn image only after its QEMU pass,
   Duranium kept recoverable. First flash 2026-11-21 (2026.11.3 into p3, slot
   bundle): it fell back to Duranium after 3 Download-mode resets. Cairn's chooser
   reboots on every first boot and Cairn lacked the reboot-param tmpfiles
   (handoff 2026-11-21). Next: images' 2026.11.5 with both fixes, debug addon on. The 2026-10-25 work (r25 counted boots and
   `scripts/pmos-verify`, r26, the boot hang, C2, deep sleep) and the LTE
   first boot stay queued behind these.

The layer lists below are the original bring-up plan; docs/STATUS.md says
what is verified today.

## Done
- [x] Bootloader unlock, KnoxGuard cleared, stock firmware T570XXSFEYI1 downloaded
- [x] S-Boot → uniLoader (BOOT) → mainline Linux 7.3, automated flash/boot loop (~33 s)
- [x] USB NCM gadget + debug console with the cable never unplugged (MAX77705 switch)
- [x] UFS HS-G3 x2, simple-framebuffer console, gpio-keys, pstore
- [x] Cluster-0 watchdog reset measured (PMU 0x408/0x40c bit 24); WDT reset boots BOOT

## Layer 0: safety net
- [x] Linux watchdog (s3c2410_wdt Exynos 9810 variant), kicked by init — track `wdt`
      (docs/STATUS.md Hang recovery; the r24 hang it did not reset is open, step 3)
- [x] uniLoader dual payload: U-Boot primary, bring-up Linux fallback on watchdog
      reset or Volume Down — track `chainload`

## Layer 1: boot chain and storage
- [x] U-Boot as uniLoader payload: UFS, blkmap over userdata, EFI, systemd-boot — `chainload`
- [x] Nested GPT in userdata (sda31) visible to Linux / systemd in the initrd — `duranium`
- [x] (2026-10-21) Android wiped by UFS discard: metadata, super, cache, userdata (approved 2026-10-21: userdata + Android OS partitions; never
      efs, sec_efs, param, up_param, persistent, bootloader partitions, RPMB)

## Layer 2: Duranium image
- [x] device-samsung-gtactive3wifi + linux-postmarketos-exynos9810 packages — `pmos`
- [x] mkosi device support, UKI with embedded DTB, Phosh and GNOME images — `duranium`
- [x] `duranium-usb-debug` package/sysext: NCM gadget, root console, SSH, initrd too
- [x] Vendor firmware extracted from the stock package (never committed) — `firmware`

## Layer 3: what the GUI needs
- [x] Display (exynos9810-dpu KMS driver), rotation, auto-rotate — `display`
      (owner 2026-10-24 and 2026-10-25)
- [ ] Backlight brightness slider — `display`
- [x] Touch: SPI controller + Himax HX83102E — `touch`
- [ ] I2C buses (HSI2C/USI) — `hsi2c`; Wacom pen — `misc`

## Layer 4: power and CPU
- [ ] S2MPS18 (SPEEDY), MAX77705 charger + fuel gauge, TMU thermal — `power`
- [x] Big cores, clock driver, then cpufreq — `cpu` (all eight cores, owner
      2026-10-25); left: big-core C2. M3 above 1794 MHz is not planned:
      stock caps the M3 there too (docs/BATTERY.md), so it would be an
      overclock
- [ ] CPU idle C2 (off by default since r25) — `cpu`

## Layer 5: acceleration and connectivity
- [x] Mali-G72 Panfrost — `gpu` (owner 2026-10-25); left: AFBC fault count, MIF floor
- [ ] Wi-Fi (Exynos PCIe + brcmfmac), Bluetooth (UART, hci_bcm) — `wifi`

## Variants: the LTE SM-T575 (docs/VARIANTS.md)

- [x] Config schema `[[variant]]`, CI matrix per variant, family names
  (boot chain, installer, build tree `contrib/samsung-gtactive3`)
- [x] Board DT split: `exynos9810-gtactive3-common.dtsi` + one file per
  variant; LTE DTS with the CP carveouts reserved, Wi-Fi firmware names
- [x] Packages: `samsung-gtactive3-common`, thin `device-samsung-gtactive3wifi`
  / `device-samsung-gtactive3`, per-variant DTB subpackages of the kernel
- [x] U-Boot board entry (T575) and both DTs; per-variant bring-up loaders
- [x] Installer: variant from the model, `--bring-up` for the LTE variant
- [x] Modem: facts and a driver plan (docs/re/modem.md), remoteproc sketch
  (patches/linux/0154, not enabled)
- [x] Merged into main (2026-11-11, owner)
- [ ] Images build green; TESTPLAN V1 on the SM-T570 with that dev image
- [x] Repository rename (docs/RELEASES.md): exynos-linux/samsung-gtactive3
  (2026-11-11); the org site's record waits for the owner
- [ ] With a T575: stock DT/PIT facts, V2 bring-up Linux, V3 chained boot,
  a local Duranium image, then `images = true`
- [ ] Speaker amp by board revision (TAS2562 on EUR rev >= 5, both variants)
- [ ] Second grip (SAR) sensor; Bluetooth firmware name on the LTE variant
- [ ] Modem P1 (vendor-style module + vendor cbd, needs the EFS read
  decision), P2 userspace, P3 mainline driver (docs/re/modem.md)

## Layer 6: the rest
- [ ] Audio (ABOX, RT5665, RT5510) — `audio`: speaker, internal mic and jack detection fixed live on r24 (2026-10-24), permanent in r25 (drv/audio-fix 7e3507579, device r48); plug passed (owner 2026-10-24); left: unplug, then TESTPLAN D11 on r25 as booted
- [ ] MUIC SM5504, hall sensor, jack, vibrator, keys, NFC (S3FWRN5), grip sensor,
      accelerometer/light sensors — `misc` (2026-10-24: accel/light/
      proximity through the BCM4775 hub verified live, Phosh auto-rotate
      works; the sensor rails (drv/shub3) are in kernel r24, D8 passed:
      docs/STATUS.md)
- [x] Cameras: rear S5K3L6 and front GC5035 on stock libcamera, fixed focus
      (owner 2026-10-24 and 2026-10-25); autofocus is step 2
- [ ] Fingerprint (TrustZone-owned), GPS: research first

## Layer 7: responsiveness (2026-11-19, docs/STATUS.md "Responsiveness")

- [ ] Touch boost: CPU floors on touch and resting floors at stock's lowest
      levels, samsung-gtactive3-common r51 (built, offline test 7/7) —
      TESTPLAN D12.1
- [ ] Device interrupts off CPU0: irqbalance on CPU0-3, r51 — D12.2
- [ ] Baseline on the tablet: boot time, swiotlb use under storage load,
      GPU load while animating, loglevel=7 console cost — D12.3, D12.4;
      the items below are ranked by what it shows
- [ ] AFBC: the Mesa fix for Bifrost v6 upstream, then drop `noafbc`
- [ ] Storage: the SysMMU in front of UFS, so I/O above 4 GiB is no longer
      bounced through swiotlb (only if D12.3 shows a real cost)
- [ ] App-launch boost like stock's Hyper HAL (0.7 s): needs a launch
      signal from the shell (none today)
- [ ] Rotation: the phoc MR upstream (Auto-rotate row)
- [ ] MIF devfreq: battery, not speed (docs/BATTERY.md item 8)

## Layer 8: battery care and power saver (2026-11-20, docs/BATTERY.md)

- [x] Charge limit in the kernel: `charge_control_{start,end}_threshold`
      and `charge_behaviour` on the battery (max77705_charger, kernel r27),
      tested live with the module (TESTPLAN D14.1-D14.4)
- [x] Battery care on by default at 80-85 % through upower (CHARGE_LIMIT
      rule + upower state default, samsung-gtactive3-common r54); the rule
      and the upower path tested live (D14.4, D14.5)
- [x] Power saver: tuned `powersave` with CPU/GPU caps and a 5 ms schedutil
      rate limit, touch boost kept, measured (D14.6): equal to balanced
      when quiet, -13 to -19 % under sustained load
- [ ] In an image: r27 + r54 booted (26112001), D14.7 partly done
      2026-11-20: upower 80/85, on/off, the re-apply and a reboot pass;
      the r27 limit does not stop the current (CNFG_09 bit 7; D14.8, D14.9):
      **kernel r29** gates on the CNFG_00 CHG bit and freezes the poll in
      suspend. r29 in image 26112002~test2 (2026-11-20): the hold stops the
      current (2 mA, D14.9 ✔). Next: the pause at 85 % while charging,
      resume below 80, s2idle without -108; Noru's tile (shell/noru 86932638) in a Noru image
- [x] Screen-off drain with suspend (D14.8, 2026-11-20): ~171 mA in s2idle
- [ ] The remaining big items:
      panel/DSIM power-off, MIF devfreq, C2/SICD (roadmap above)
- [ ] Cairn OS: the same design in cairn/core and Noru's quick settings
      (handed to the images and noru sessions, 2026-11-20)
