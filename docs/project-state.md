# Project State

This document summarizes the current state of the X Linux project based on repository contents, scripts, and roadmap progress.

## Snapshot

- Status: active development.
- Distribution model: Arch-based custom spin built with `mkarchiso`.
- Delivery targets:
  - Bootable live ISO.
  - WSL-importable root filesystem tarballs.
- Repository model: includes a custom `[x]` pacman repository.

## What Is Already Implemented

### Identity and Branding

- System identity files are present in `airootfs/etc/` (including `os-release` and `motd`).
- Bootloader branding assets and config are present (`grub/`, `syslinux/`, `efiboot/`).
- Desktop-related branding automation exists in post-install scripts under `airootfs/root/`.

### Installation and Automation

- Preconfigured Archinstall files are included in `airootfs/etc/archinstall/` and `airootfs/root/`.
- Automated/post-install scripts are available:
  - `airootfs/root/x-autostart.sh`
  - `airootfs/root/x-postinstall.sh`
  - `airootfs/root/customize_airootfs.sh`

### Build Tooling

- ISO build script: `xbuild.sh`.
- WSL build scripts: `xbuildwsl.sh` and `xbuildwslc.sh`.
- ArchISO profile definition is maintained in `profiledef.sh`.

### Project Operations

- `ROADMAP.md` is integrated with GitHub Issues sync through `.github/workflows/roadmap-sync.yml`.
- The sync script (`.github/scripts/sync_roadmap.py`) can create and synchronize issue states from roadmap checkboxes.

## In Progress or Pending Areas

According to `ROADMAP.md`, notable pending areas include:

- Full package repository lifecycle completion.
- Improved installation UX and first-boot experience.
- Expanded user-facing documentation.
- Automated release pipeline (build/sign/versioning strategy).

## Risks and Notes

- Build scripts require `sudo` and assume an Arch-like host environment with required tools installed.
- `pacman.conf` currently uses `SigLevel = Optional TrustAll` for the custom repo, which is convenient for development but should be revisited for hardened release workflows.
- WSL guidance exists in multiple places; this has now been normalized into `docs/build-wsl.md` for consistency.
