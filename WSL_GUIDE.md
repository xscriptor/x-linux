# X Linux on WSL Guide

This guide describes how to build, import, and run **X Linux** on Windows Subsystem for Linux (WSL).

## Prerequisites

- **Windows 10/11** with WSL enabled.
    - Install WSL via PowerShell (Admin): `wsl --install`
- A Linux environment (VM or another WSL distro) to run the build script, as `archiso` tools are required.

## 1. Build the WSL Image

From this repository on your Linux machine:

```bash
chmod +x xbuildwsl.sh
sudo ./xbuildwsl.sh
```

This will create the file `out-wsl/x-YYYY.MM.DD.tar.zst`.

## 2. Copy the Image to Windows

Move the tarball to a location accessible by Windows (e.g., `C:\Users\YourUser\Downloads\`).

## 3. Import into WSL

The built image is compressed with **Zstandard (.tar.zst)** for better compression. WSL does not support importing `.tar.zst` files directly. You need to decompress it first or pipe the content.

### Option A: Decompress First (Recommended)

1.  **Decompress** the file using a tool like [7-Zip](https://www.7-zip.org/) or `zstd` command line on Windows:
    ```powershell
    zstd -d x-2024.10.01.tar.zst
    ```
    This will produce `x-2024.10.01.tar`.

2.  **Import** the `.tar` file:
    ```powershell
    # Usage: wsl --import <DistroName> <InstallLocation> <PathToTarball>
    wsl --import x C:\WSL\x C:\Users\YourUser\Downloads\x-2024.10.01.tar
    ```

### Option B: Pipe Import (Advanced)

If you have `zstd` installed in another WSL distro or Windows, you *might* be able to pipe it, but Option A is safer.

*   **<DistroName>**: Name you want to give the distro (e.g., `x`).
*   **<InstallLocation>**: Disk path where the VHDX file will be stored.
*   **<PathToTarball>**: Path to the `.tar` file (after decompression).

## 4. Run X Linux

Start your new distribution:

```powershell
wsl -d x-linux
```

## 5. Post-Import Configuration

Since the import creates a root shell by default, you may want to create a regular user:

1.  **Create User**:
    ```bash
    useradd -m -G wheel -s /bin/bash yourusername
    passwd yourusername
    passwd # Set root password
    ```

2.  **Configure Sudo**:
    Uncomment the `%wheel` group line in `/etc/sudoers`:
    ```bash
    EDITOR=nano visudo
    # Uncomment: %wheel ALL=(ALL:ALL) ALL
    ```

3.  **Set Default User** (Optional):
    Create a `/etc/wsl.conf` file to auto-login as your user:
    ```ini
    [user]
    default=yourusername
    ```
    Then restart WSL (`wsl --shutdown` in PowerShell).

Enjoy X Linux on WSL!
