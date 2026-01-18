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

## Post-installation Customization

X uses a **post-install script** to apply branding and configurations.  
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

---

## License

All build scripts and configuration files are released under the MIT License,
unless stated otherwise in subdirectories (e.g., artwork or third-party themes).

---

## Author

**Xscriptor**
[github.com/xscriptor](https://github.com/xscriptor)

---


