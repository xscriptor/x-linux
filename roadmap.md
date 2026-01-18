# X Distribution — Roadmap

A comprehensive roadmap for completing the X Linux distribution based on Arch.

---

## Phase 1: Branding & Identity 

- [x] System identity (`/etc/os-release`)
- [x] GRUB distributor name (`GRUB_DISTRIBUTOR="X"`)
- [x] Bootloader menu entries (GRUB, systemd-boot, syslinux)
- [x] Fastfetch configuration
- [x] ISO profile (`profiledef.sh`)
- [x] MOTD (Message of the Day)

---

## Phase 2: Package Repository 

### 2.1 Confirm Repository URL

> **ACTION REQUIRED**: Choose your repository hosting:

| Option | URL Format |
|--------|------------|
| GitHub Releases | `https://github.com/xscriptordev/xos-repo/releases/download/latest/$arch` |
| Custom Server | `https://repo.xscriptor.com/xos/$arch` |
| GitLab Pages | `https://xscriptordev.gitlab.io/xos-repo/$arch` |

**Current setting** in `pacman.conf`:
```
https://github.com/xscriptordev/xos-repo/releases/download/latest/$arch
```

### 2.2 Package Tasks

- [x] Create `xos-release` PKGBUILD
- [x] Create install hooks
- [x] Add repository to `pacman.conf`
- [ ] Build package with `./build-repo.sh`
- [ ] Create `xos-repo` repository on GitHub
- [ ] Upload package files to GitHub Releases (tag: `latest`)
- [ ] Test ISO build with package

---

## Phase 3: Installation Experience

- [x] Archinstall configuration (`user_configuration.json`)
- [x] Automated installation (`x-autostart.sh`)
- [x] Post-install branding (`x-postinstall.sh`)
- [ ] Custom installer UI (future)
- [ ] Welcome app on first boot (future)

---

## Phase 4: Desktop Environment

- [x] GNOME branding (wallpaper, GDM logo)
- [x] KDE Plasma branding
- [x] XFCE branding
- [x] Display manager configuration (GDM, SDDM, LightDM)
- [ ] Custom theme/icons (future)
- [ ] Default application configuration

---

## Phase 5: Documentation & Website

- [ ] Landing page at `dev.xscriptor.com/xos`
- [ ] Installation guide
- [ ] FAQ / Troubleshooting
- [ ] Release notes template

---

## Phase 6: Release Pipeline

- [ ] Automated ISO builds (GitHub Actions / GitLab CI)
- [ ] Package signing with GPG
- [ ] Release versioning strategy
- [ ] Mirror setup (optional)

---

## Quick Start Commands

```bash
# Build the xos-release package
cd xos-packages
./build-repo.sh

# Build the ISO
cd /home/x/Documents/repos/xscriptordev/xos
./xbuild.sh
```

---

## Files Reference

| File | Purpose |
|------|---------|
| `profiledef.sh` | ISO metadata and build settings |
| `pacman.conf` | Package manager configuration with XOs repo |
| `packages.x86_64` | Packages included in the ISO |
| `airootfs/etc/os-release` | System identity |
| `airootfs/etc/default/grub` | GRUB configuration |
| `xos-packages/xos-release/` | Custom branding package |
