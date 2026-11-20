# Duranium images fail to build with apk-tools 3.0.10 (draft upstream report)

Written 2026-11-20 for the owner to file with Nura (duranium-build) or
Alpine (apk-tools) if they want to. Nothing has been sent upstream: the
project's rule is that agents never post to Nura/postmarketOS.

## Symptom

Since apk-tools 3.0.10-r0 reached Alpine edge (built 2026-11-19), every
duranium-build image fails in mkosi's base image install:

```
( 72/1206) Installing systemd (262.2-r0)
ERROR: systemd-262.2-r0: failed to commit usr/sbin/init: No such file or directory
( 73/1206) Installing calls-systemd (51.1-r0)
ERROR: systemd-udevd-262.2-r0: failed to commit usr/bin/udevadm: No such file or directory
...
2 errors; ... packages
```

Upstream duranium-build's scheduled pipeline of 2026-11-17 passed, before
3.0.10 existed; the next one will run with 3.0.10.

## Versions

| | works | fails |
|---|---|---|
| apk-tools (mkosi tools tree / sandbox) | 3.0.9-r0 | 3.0.10-r0 |
| systemd (Nura extra-repos/systemd) | 262.2-r0 (built 2026-11-06) | same |
| postmarketos-base / -baselayout | 79-r0 ("enact bin-merge in core", 2026-11-15) | same |
| mkosi | 28~devel (gitlab.nura.eco:5050/nura/nura-oci/mkosi:edge) | same |

Likely related apk 3.0.10 changes (v3.0.9..v3.0.10): "db: adopt only real
directories" (76326268) and "fs: resolve fsdir paths within the
destination root" (27ec1aab), together with Nura's bin-merge, where
/usr/sbin is not a real directory.

## Minimal reproduction (clean upstream, no changes)

On an x86_64 host with podman:

```sh
git clone https://gitlab.nura.eco/nura/duranium-build.git && cd duranium-build
export MKOSI=./scripts/mkosi-container
./scripts/build-image.py device-qemu-amd64 ui-phosh
```

The tools tree installs `apk-tools (3.0.10-r0)`; the base install then
fails with the two errors above (upstream commit 3048ba0, 2026-11-20).

Notes: build-image.py sources APKBUILDs with `sh`; on hosts where `sh` is
dash it stops earlier with "Bad substitution" in
extra-repos/systemd/phosh/APKBUILD (a bash-ism), so run it with `sh`
pointing at bash. A plain `apk --root ... add postmarketos-duranium
postmarketos-ui-phosh` outside mkosi does not fail with either version;
the failure needs mkosi's build root.

## Workaround that works

The same build passes completely (base, initrd, extensions, 6.4 GB disk
image, 336 s) when mkosi uses apk 3.0.9:

```sh
# Alpine's signed static apk 3.0.9, put in front of the tools tree's apk
curl -fLO https://cdn.alpinelinux.org/edge/main/x86_64/apk-tools-static-3.0.9-r0.apk
# sha256 677dddb435ca7d621ce9f8a1a404a4cedc631651fd025893c548c34a4ceecb19
mkdir -p x sandbox-apk/usr/bin sandbox-apk/usr/sbin
tar -xzf apk-tools-static-3.0.9-r0.apk -C x sbin/apk.static
install -m755 x/sbin/apk.static sandbox-apk/usr/bin/apk
install -m755 x/sbin/apk.static sandbox-apk/usr/sbin/apk
./scripts/build-image.py device-qemu-amd64 ui-phosh --sandbox-tree=/src/sandbox-apk
```

`--tools-tree=` (the container's own apk 3.0.9) also gets past the base
install but then fails building the initrd (the container's busybox cpio
lacks GNU options). Scripts in mkosi.tools.conf are not run for the tools
tree, and a tools-tree package directory needs openssl in the container,
so neither can pin the version.

This port carries the workaround as duranium-build patch 0047
(`pmos/duranium-build/`, `APK_PIN=` turns it off). Evidence:
logs/test-runs/2026-11-20-apk-pin (local, not in git).
