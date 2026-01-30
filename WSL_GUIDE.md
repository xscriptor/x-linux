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

This will create the file `out-wsl/x-wsl-YYYY.MM.DD.tar.gz`.

## 2. Copy the Image to Windows

Move the tarball to a location accessible by Windows (e.g., `C:\Users\YourUser\Downloads\`).

## 3. Import into WSL

Open **PowerShell** or **Command Prompt** as Administrator and run the following command:

```powershell
# Usage: wsl --import <DistroName> <InstallLocation> <PathToTarball>
wsl --import x-linux C:\WSL\x-linux C:\Users\YourUser\Downloads\x-wsl-2024.10.01.tar.gz
```

*   **<DistroName>**: Name you want to give the distro (e.g., `x-linux`).
*   **<InstallLocation>**: Disk path where the VHDX file will be stored.
*   **<PathToTarball>**: Path to the `.tar.gz` file you built (check the exact date in the filename).

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
