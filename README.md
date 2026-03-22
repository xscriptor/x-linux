<h1 align="center"> X Linux </h1>

**X** is a custom Arch Linux spin focused on simplicity, clean branding, and reproducible builds.  
It ships its own package repository ([x-repo](https://github.com/xscriptor/x-repo)) so you can install X-specific packages directly with `pacman`, and more tools will be migrated there over time.

> **Project status:** Under active development  

---

## Overview

X provides a minimal yet polished Arch-based system with its own identity.  
It is built with the standard `mkarchiso` workflow, layering a custom profile, branding assets, and post-install automation on top of official Arch repositories.

### Key Features

- **Custom branding** — `/etc/os-release`, GRUB, MOTD, wallpapers, and logos all carry the X identity.
- **X package repository** — A dedicated `[x]` repo in `pacman.conf` delivers the `x-release` branding package (and future tools) via `pacman`.
- **Preconfigured archinstall** — Ships a `user_configuration.json` so installation is nearly hands-free.
- **Post-install automation** — `x-postinstall.sh` applies branding to GNOME, KDE Plasma, XFCE, GDM, SDDM, and LightDM.
- **WSL support** — Build a WSL-importable tarball with `xbuildwsl.sh`.
- **Multiple desktop environments** — Branding preconfigured for GNOME, KDE Plasma, and XFCE.

---

## Project Structure

```
x-linux/
├── profiledef.sh             # ArchISO profile definition
├── pacman.conf               # Package manager config (includes [x] repo)
├── packages.x86_64           # Package list for ISO build
├── airootfs/                 # Root filesystem overlay
│   ├── etc/
│   │   ├── os-release        # X system identity
│   │   ├── default/grub      # GRUB configuration (GRUB_DISTRIBUTOR="X")
│   │   ├── motd              # Message of the Day
│   │   ├── dconf/            # GNOME/GDM branding (wallpaper, login logo)
│   │   └── pacman.d/hooks/   # Branding hooks for x-release package
│   ├── root/
│   │   ├── x-autostart.sh    # Automated installation script
│   │   ├── x-postinstall.sh  # Post-install branding (GNOME/KDE/XFCE)
│   │   └── user_configuration.json  # Archinstall preset
│   └── usr/local/share/      # Wallpapers, logos, and assets
├── xbuild.sh                 # Build ISO locally
├── xbuildwsl.sh              # Build WSL tarball
├── x.sh                      # Quick rebuild/clean script
├── WSL_GUIDE.md              # Guide for importing into WSL
└── roadmap.md                # Project roadmap
```

---

## The X Repository

X ships a custom pacman repository that provides branding and utility packages.  
Currently the repo includes `x-release`, and more tools will be migrated here over time.

The repository is pre-configured in `pacman.conf`:

```ini
[x]
SigLevel = Optional TrustAll
Server = https://xscriptor.github.io/x-repo/repo/x86_64
```

To add it to an existing Arch installation, append the block above to `/etc/pacman.conf` and run:

```bash
sudo pacman -Sy x-release
```

With the repository enabled, the `x-release` package handles all branding automatically via pacman hooks — the post-install script is no longer necessary.

---

## Building the ISO

Install `archiso`:

```bash
sudo pacman -S archiso
```

Then run:

```bash
./xbuild.sh
```

The script will:

1. Unmount any stale mounts from previous builds.
2. Clean the `work/` and `out/` directories.
3. Run `mkarchiso` with the provided configuration.
4. Store the resulting `.iso` image inside `./out/`.

Output:

```
out/
└── X-YYYY.MM.DD-x86_64.iso
```

---

## Building for WSL

To create a tarball compatible with Windows Subsystem for Linux:

```bash
sudo ./xbuildwsl.sh
```

This produces `out-wsl/x-YYYY.MM.DD.tar.gz`.  
See [WSL_GUIDE.md](./WSL_GUIDE.md) for import instructions.

---

## Archinstall Preconfiguration

The ISO includes a pre-configured `archinstall` profile (`user_configuration.json`) for a streamlined installation.

> **Note:** On some hardware you may need to manually re-select the disk partitioning layout during the setup wizard.

---

## Post-installation (Fallback)

If the X repository is unreachable, you can apply branding manually with the post-install script.  
**Run this right after `archinstall` finishes, before rebooting** (while the new system is still mounted at `/mnt`):

```bash
/root/x-postinstall.sh
```

This configures `/etc/os-release`, wallpapers, logos, and bootloader entries for the installed desktop environment.

---

## Notes

- Build outputs (`work/`, `out/`, logs) are git-ignored.
- All configuration and assets needed to reproduce the ISO are included in the repository.
- For development or debugging, modify files under `airootfs/` and rebuild.

### Developer Resources

For additional automation scripts and tools, visit:  
[https://github.com/xscriptor/x](https://github.com/xscriptor/x)

---

## License

All build scripts and configuration files are released under the MIT License,  
unless stated otherwise in subdirectories (e.g., artwork or third-party themes).

---

[X](https://github.com/xscriptor)
