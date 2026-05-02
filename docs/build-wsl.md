# Build WSL Guide

This guide explains how to produce and import an X Linux root filesystem for Windows Subsystem for Linux (WSL).

## Build Scripts

Two scripts are available:

- `xbuildwsl.sh`: outputs a `tar.gz` archive.
- `xbuildwslc.sh`: outputs a `tar.zst` archive with stronger compression.

Both scripts:

- build a root filesystem in `work-wsl/rootfs`;
- install packages from `packages.x86_64`;
- copy `airootfs` content;
- apply permissions from `profiledef.sh`;
- run customization steps in `arch-chroot`;
- produce artifacts in `out-wsl/`.

## Prerequisites

- Linux environment with Arch tooling (`pacstrap`, `arch-chroot`, `pacman`).
- `sudo` access.
- For `xbuildwslc.sh`: `zstd` installed.

## Build Commands

Run from repository root:

```bash
sudo ./xbuildwsl.sh
```

or:

```bash
sudo ./xbuildwslc.sh
```

## Output

- Gzip flow: `out-wsl/x-YYYY.MM.DD.tar.gz`
- Zstandard flow: `out-wsl/x-YYYY.MM.DD.tar.zst`

## Import into WSL

In PowerShell:

```powershell
wsl --import x C:\WSL\x C:\path\to\x-YYYY.MM.DD.tar
```

If you built `.tar.zst`, decompress it first (for example with `zstd -d`) to get a `.tar` file.

## Post-Import Notes

- First boot usually starts as `root`.
- Create a regular user and configure `/etc/wsl.conf` if you want automatic login as that user.
- Use `wsl --shutdown` from PowerShell after user/default configuration changes.
