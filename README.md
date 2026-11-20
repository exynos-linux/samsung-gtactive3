# Mainline Linux / postmarketOS on the Samsung Galaxy Tab Active3

Mainline Linux on the Galaxy Tab Active3 (Exynos 9810), running
postmarketOS Duranium (immutable, A/B updates) with Phosh or GNOME. The
kernel and drivers are ours; the rest of the OS is unmodified postmarketOS.

| Variant | Models | State |
|---|---|---|
| Wi-Fi (`gtactive3wifi`) | SM-T570 | in daily use: the table below |
| LTE (`gtactive3`) | SM-T575, SM-T575N | bring-up: device tree, boot chain and packages ready, not booted yet; the modem has a driver plan ([docs/re/modem.md](docs/re/modem.md)) |

One repository for the family: what the variants share and what differs is
in [docs/VARIANTS.md](docs/VARIANTS.md). The US SM-T577U is not supported
(no confirmed bootloader unlock).

## Status

SM-T570 in postmarketOS Duranium (Phosh). Hardware results below are from
the tests through 2026-10-25; the connected tablet was checked on
2026-11-19 and was running image 26102701. The strict, per-block table
with sources and test runs is [docs/STATUS.md](docs/STATUS.md).

| Area | State |
|---|---|
| Boot chain (S-Boot → uniLoader → U-Boot → systemd-boot → UKI), signed A/B updates with rollback | ✅ |
| CPU: all 8 cores (4× Cortex-A55 + 4× Mongoose M3), frequency scaling | ✅ |
| GPU Mali-G72 (Panfrost): Phosh renders on the GPU | ✅ |
| Display (our DPU KMS driver), touch | ✅ |
| Rotation, manual and automatic (accelerometer through the sensor hub) | ✅ |
| Cameras: 8 MP rear, 5 MP front, on stock libcamera | ✅ fixed focus; autofocus in progress |
| Storage (UFS), RAM, power and volume-up keys, suspend to idle | ✅ |
| Wi-Fi (BCM4375) | ⚠️ connects at boot; the firmware hangs now and then, automatic recovery is being tested |
| Audio: speaker, microphone, headphone jack | ⚠️ speaker, mic and plug-in pass; unplug untested |
| Battery and charging | ⚠️ charges; temperature-based limits not booted yet |
| CPU idle (C2) | ❌ off by default: it hangs or slows the system |
| Responsiveness | ⚠️ touch boost (held contacts included) and interrupt spreading pass live trials on the tablet (2026-11-20, device package r52); not yet in a published image |
| Bluetooth, S Pen, microSD, NFC, Home/Recent keys, flash LED | ❔ drivers load; not tested in the UI yet |
| Volume-down and Active keys, GPS, fingerprint | ❌ |

What comes next: [PLAN.md](PLAN.md).

## Layout

- `patches/linux`: our kernel commits as a patch series (base in `BASE`)
- `patches/libcamera`: libcamera patches meant for upstream (the images use
  stock postmarketOS libcamera)
- `bootchain/`: the boot chain the installer flashes (vendored U-Boot and
  uniLoader from exynos-linux/device-template, `build.sh`)
- `configs/`: kernel config fragment and initramfs list template
- `initramfs/init.c`: bring-up init (kernel nolibc): USB gadget, debug console
- `scripts/`: build, package, flash loop (`devd.sh`), console client (`tab`)
- `pmos/`: what we maintain for postmarketOS Duranium (aports incl. the kernel,
  duranium-build patches, the image signing key), exported by `scripts/pmos-export`
- `ci/`, `.github/workflows/images.yml`: builds the images when postmarketOS
  publishes or `pmos/` changes, publishes them as GitHub releases, which is where
  the tablets update from: see [docs/RELEASES.md](docs/RELEASES.md)
- `HARDWARE.md`: hardware map from the stock firmware, `PLAN.md`: roadmap

## Install

On a Linux PC, with the tablet on USB:

```
./setup.sh --stock-ap AP_<your firmware>.tar.md5
```

It first only puts our Linux into BOOT (Android stays as it is, `./setup.sh
undo` brings it back), then offers a full Android backup and the install.
Step by step, requirements and the way back to Android:
[docs/INSTALL.md](docs/INSTALL.md).

## Downloads and updates

Images (Phosh, GNOME) are in the
[releases](https://github.com/exynos-linux/samsung-gtactive3/releases). The
build is intended to follow postmarketOS publishes; image builds failed
from 2026-11-11 to 2026-11-19 (the builder image moved to Nura's
registry, fixed 2026-11-20), so the latest published image can be old. On 2026-11-19
the connected Phosh tablet verified its update manifest: 26102701 was both
installed and the newest version on its development channel. The local
responsiveness changes are not in that image. Development channels have
builds; release channels require an export to pass on the device
(`scripts/pmos-verify`). Installed tablets update with `updatectl update`
(A/B, signed, automatic rollback). Vendor firmware is not included.
[docs/RELEASES.md](docs/RELEASES.md) explains the channels and checks.

## Development loop

```
scripts/build.sh            # init + kernel + modules → build/images/boot-mainline.img
scripts/devd.sh &           # flashes BOOT whenever the tablet is in Download mode
scripts/tab reboot download # tablet reboots, gets flashed, boots, USB is back in ~35 s
scripts/tab dmesg           # debug console over IPv6 link-local (fe80::57:aff:fe00:1)
```

Stock firmware, keys and decrypted images are never committed.
