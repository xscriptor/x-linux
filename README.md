<h1 align="center"> X Linux </h1>

**X** is a custom Arch Linux spin focused on simplicity, clean X branding, and reproducible builds.  
This repository contains the full ArchISO profile and post-installation assets used to generate the official X Linux ISO image.

> **Project status:** Under active development  

---

## Overview

X aims to provide a minimal yet polished Arch-based system with its own identity and branding.  
It is built entirely from official Arch repositories, using the standard `mkarchiso` workflow with a custom profile definition and post-install scripts.

---

## Project Structure

```
X/
├── profiledef.sh             # ArchISO profile definition
├── pacman.conf               # Custom package configuration
├── packages.x86_64           # Package list for ISO build
├── airootfs/                 # Root filesystem (customized ArchISO overlay)
│   ├── root/
│   │   ├── x-assets/       # Branding assets dir
│   │   ├── x-postinstall.sh # Main post-installation script
│   │   └── ...
│   └── ...
├── xbuild.sh                 # Automated build script
├── x.sh                      # Quick rebuild/clean script
└── .gitignore
```

---

## Archinstall Preconfiguration

This ISO comes with a pre-configured `archinstall` profile (`user_configuration.json`) designed to speed up the installation process.
*   **Note:** While completely automated, in some specific hardware cases you might need to manually **re-select the disk partitioning** layout during the setup wizard.

---

## Building the ISO

To build the X ISO image locally, ensure you have `archiso` installed.

```bash
sudo pacman -S archiso
```

Then run the included build script:

```bash
./xbuild.sh
```

The script will:

1.  Unmount any stale mounts from previous builds.
2.  Clean the `work/` and `out/` directories.
3.  Run `mkarchiso` with the provided configuration.
4.  Store the resulting `.iso` image inside `./out/`.

Example output:

```
out/
└── X-YYYY.MM.DD-x86_64.iso
```

---

## Build for WSL (Windows Subsystem for Linux)

To create a tarball compatible with WSL:

```bash
sudo ./xbuildwsl.sh
```

This will produce `out-wsl/x-wsl-YYYY.MM.DD.tar.gz`. For instructions on how to import and use this in Windows, see [WSL_GUIDE.md](./WSL_GUIDE.md).

---

## Post-installation Customization (optional)

X uses a custom repository to manage branding and configurations automatically.

### Option 1: Automated (Recommended)
The **X repository** is pre-configured in the `pacman.conf` and `archinstall` configuration.
If you need to add it manually to an existing system:

```ini
# X repo
[x]
SigLevel = Optional TrustAll
Server = https://xscriptor.github.io/x-repo/repo/x86_64
```

With this repository enabled, the **post-install script is NO LONGER NECESSARY**, as the `x-release` package handles all branding (logo, names) automatically via hooks.

### Option 2: Post-install Script (Fallback)
If the repository is unreachable or you prefer a manual approach, you can still use the **post-install script**.  
**Important:** This script must be run **immediately after installing Arch (via `archinstall` or manually) but BEFORE rebooting**, while your new system is still mounted at `/mnt`.

1.  Run `archinstall` and complete the installation (do **not** reboot yet).
2.  Exit `archinstall` to the shell.
3.  Execute the post-install script located in `/root`:

```bash
/root/X-postinstall.sh
```

This script will:

*   Configure `/etc/os-release` (identity).
*   Install wallpapers, logos, and branding for GNOME/KDE/XFCE.
*   Setup initial user configurations (skel).
*   Customize the bootloader (GRUB/systemd-boot).

Once finished, you can safe reboot into your new X system.

---

## Notes

*   The repository ignores build outputs (`work/`, `out/`, logs) for cleaner commits.
*   All configuration and assets required to reproduce the ISO are included.
*   For development or debugging, you can modify files under `airootfs/` and rebuild.

### Developer Resources
For additional automation scripts and tools useful for developers, visit:
[https://github.com/xscriptordev/x](https://github.com/xscriptordev/x)

---

## License

All build scripts and configuration files are released under the MIT License,
unless stated otherwise in subdirectories (e.g., artwork or third-party themes).

---



[X](https://github.com/xscriptor)

---


