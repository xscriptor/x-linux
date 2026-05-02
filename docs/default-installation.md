# Default Installation

This document describes the default installation behavior used by X Linux in the live environment.

## Installation Entry Point

The default flow is driven by `airootfs/root/x-autostart.sh`.

At boot, the script:

1. Verifies it is running in a live ArchISO context.
2. Runs only on `tty1` (unless forced).
3. Waits briefly to let users cancel autostart.
4. Checks network availability before launching `archinstall`.

Environment flags:

- `x_NO_AUTO=1`: disables autostart.
- `x_FORCE=1`: forces execution even outside normal live checks.
- `x_DEBUG=1`: enables shell debug output.

## Configuration Files Used

- Base config template: `airootfs/root/user_configuration.json`
- Credentials file: `airootfs/root/user_credentials.json`
- Additional profile preset also exists at: `airootfs/etc/archinstall/archinstall.json`

The default automated path uses the files in `/root/` during the live session.

## Disk Selection and Partitioning

Before running `archinstall`, `x-autostart.sh` generates an effective configuration (`/tmp/user_configuration.effective.json`) by patching the base template.

Disk logic:

- Detects the ISO boot device and avoids selecting it as target.
- Scans block devices and picks the first suitable disk.
- Skips very small disks (less than 10 GB).

Partition layout logic (generated dynamically):

- Partition 1 (`/boot`): FAT32, ESP/boot flags, 512 MiB.
- Partition 2 (`/`): Btrfs with `compress=zstd`, uses remaining space.
- Target disk is wiped.

## Default System Settings

From `user_configuration.json`, the default installation includes:

- Bootloader: `Grub`
- Hostname: `x`
- Kernel: `linux`
- Locale/UI: English installer language, `en_US.UTF-8` system language, keyboard layout `es`
- Timezone: `UTC`
- Network: NetworkManager mode (`nm`)
- Swap: enabled
- Desktop profile: GNOME (`gdm` greeter)
- User: `xscriptor` with sudo enabled
- Password: `changeme000` (encrypted, you should change it after installation or even in the installation process)

## Default Package Intent

The Archinstall config includes a baseline package set for identity and development bootstrap, such as:

- `x-release`, `xpm`
- `git`, `base-devel`
- `wget`, `curl`

Additional live-image packages are controlled by `packages.x86_64`.

## User and Credentials

If `user_credentials.json` is present, it is passed through `--creds` to `archinstall`.

Current repository state includes:

- A predefined user entry (`xscriptor`) with sudo enabled.
- Password data stored in encrypted hash form.

If credentials are missing, Archinstall prompts interactively.

## Post-Install Behavior

When `archinstall` succeeds, `x-autostart.sh` executes `/root/x-postinstall.sh` (if present), then schedules reboot.

This post-install step is intended to apply X branding and finalize system setup.

## Operational Notes

- Automatic disk selection is convenient for unattended flow but should be reviewed carefully for multi-disk systems.
- For manual/controlled setups, disable autostart and run Archinstall interactively.
