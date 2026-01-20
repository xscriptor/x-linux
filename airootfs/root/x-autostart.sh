#!/usr/bin/env bash
set -euo pipefail

# Enable debug if requested
[ "${x_DEBUG:-0}" = "1" ] && set -x

# 1. Environment Check
# On real hardware, devices might take a moment.
if command -v udevadm >/dev/null 2>&1; then
  udevadm settle || true
fi

# Check if we should run (Live environment check)
# We relax the check to support various boot modes, but we ensure we are in a live context.
IS_LIVE=0
if grep -q "/run/archiso/bootmnt" /proc/mounts 2>/dev/null; then IS_LIVE=1; fi
if [ -d /run/archiso/airootfs ]; then IS_LIVE=1; fi
if grep -Eq 'archisobasedir=|archisosearchuuid=|script=' /proc/cmdline; then IS_LIVE=1; fi

[ "${x_NO_AUTO:-0}" = "1" ] && { echo "[x] Autostart disabled (x_NO_AUTO=1)."; exit 0; }

if [ "$IS_LIVE" = "0" ] && [ "${x_FORCE:-0}" != "1" ]; then
  # Not a live environment and not forced -> Exit silently
  exit 0
fi

# TTY Check: Only run on tty1 to avoid running in background ssh/other terminals
if [ "$(tty)" != "/dev/tty1" ] && [ "${x_FORCE:-0}" != "1" ]; then
  exit 0
fi

echo
echo "──────────────────────────────────────────"
echo "   x Live – Archinstall will start in 5s"
echo "   Press Ctrl+C to cancel."
echo "──────────────────────────────────────────"
for i in 5 4 3 2 1; do
  printf "\rStarting archinstall in %s s… (Ctrl+C to cancel) " "$i"
  sleep 1
done
echo
echo "→ Starting archinstall (Automated with config)…"
echo

# 2. Wait for Network (Crucial for archinstall)
echo "[x] Checking internet connection..."
MAX_RETRIES=30
count=0
while ! ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; do
  printf "\rWaiting for network... %ds" "$count"
  sleep 1
  count=$((count+1))
  if [ "$count" -ge "$MAX_RETRIES" ]; then
    echo
    echo "[x] Warning: No internet connection detected. Installation might fail."
    break
  fi
done
echo
echo "[x] Network ready."

CONF_PATH="/root/user_configuration.json"
CREDS_PATH="/root/user_credentials.json"

# 3. Disk Detection Logic
pick_target_disk() {
  # Get the device where the ISO is mounted (to avoid it)
  ISO_DEV=$(findmnt -no SOURCE /run/archiso/bootmnt 2>/dev/null || echo "")
  # Clean up /dev/ explicitly
  ISO_DEV="${ISO_DEV%%[0-9]*}" # Remove partition number if present (e.g. sdb1 -> sdb)
  
  # List all disks: Name, Type, Removable, Size (bytes)
  # Exclude loop devices and sr (optical)
  lsblk -dn -o NAME,TYPE,RM,SIZE -b | awk '$2=="disk"' | while read -r name type rm size; do
    path="/dev/$name"
    
    # Skip the ISO device
    if [ -n "$ISO_DEV" ] && [ "$path" = "$ISO_DEV" ]; then continue; fi
    
    # Skip very small disks (< 10GB) - usually USBs
    if [ "$size" -lt 10737418240 ]; then continue; fi
    
    # On real hardware, we prefer non-removable (rm=0)
    # But some SSDs might show up as removable in some hot-plug configs.
    # We prioritize the first large non-ISO disk we find.
    echo "$path"
    return 0
  done
}

prepare_effective_config() {
  local target size_b size_mb boot_start_mib boot_size_mib root_start_mib root_size_mib tmpcfg
  
  target="$(pick_target_disk)"
  if [ -z "$target" ]; then
    echo "[x] Error: No suitable target disk found!" >&2
    return 1
  fi
  
  echo "[x] Selected target disk: $target" >&2
  
  size_b="$(lsblk -b -dn -o SIZE "$target" 2>/dev/null || echo 0)"
  size_mb=$(( size_b / (1024*1024) ))
  
  # Partition Layout Calculation (MiB)
  # 1MB gap at start + 512MB Boot + Root + 1MB gap at end
  boot_start_mib=1
  boot_size_mib=512
  root_start_mib=$(( boot_start_mib + boot_size_mib ))
  
  # Leave some breathing room at the end (5MB)
  root_size_mib=$(( size_mb - root_start_mib - 5 ))
  
  if [ "$root_size_mib" -lt 4096 ]; then
    echo "[x] Error: Target disk too small (< 4GB)." >&2
    return 1
  fi
  
  tmpcfg="/tmp/user_configuration.effective.json"
  PY="$(command -v python3 || command -v python || echo)"
  [ -n "$PY" ] || return 1
  
  "$PY" - "$CONF_PATH" "$tmpcfg" "$target" "$boot_start_mib" "$boot_size_mib" "$root_start_mib" "$root_size_mib" << 'PY'
import json, sys
src, dst, dev, boot_start_mib, boot_size_mib, root_start_mib, root_size_mib = sys.argv[1:]

try:
    with open(src) as f:
        cfg = json.load(f)
except Exception as e:
    print(f"Error loading config: {e}", file=sys.stderr)
    sys.exit(1)

# Ensure disk_config exists
dc = cfg.get("disk_config", {})
if not dc:
    dc = {"type": "disk_config"}
    cfg["disk_config"] = dc

# Ensure device_modifications exists
mods = dc.get("device_modifications", [])
if not mods:
    mods = [{}]
    dc["device_modifications"] = mods

# Set target device
m = mods[0]
m["device"] = dev
m["wipe"] = True  # Ensure wipe is set

parts = m.get("partitions", [])
if not parts or len(parts) < 2:
    parts = [{}, {}]
    m["partitions"] = parts

# Partition 0: Boot/ESP
p0 = parts[0]
p0["fs_type"] = "fat32"
p0["mountpoint"] = "/boot"
p0["flags"] = ["boot", "esp"]
p0["type"] = "primary"
p0["status"] = "create"
p0["size"] = {"sector_size": None, "unit": "MiB", "value": int(boot_size_mib)}
p0["start"] = {"sector_size": None, "unit": "MiB", "value": int(boot_start_mib)}

# Partition 1: Root (Btrfs)
p1 = parts[1]
p1["fs_type"] = "btrfs"
p1["mountpoint"] = "/"
p1["mount_options"] = ["compress=zstd"]
p1["type"] = "primary"
p1["status"] = "create"
p1["size"] = {"sector_size": None, "unit": "MiB", "value": int(root_size_mib)}
p1["start"] = {"sector_size": None, "unit": "MiB", "value": int(root_start_mib)}

# Force pre_mounted_config to False because we are defining the layout
cfg["config_type"] = "default" 

with open(dst, "w") as f:
    json.dump(cfg, f, indent=4)
print(dst)
PY
}

INSTALL_OK=0
echo "[x] Using config template: $CONF_PATH"

# Prepare the effective configuration (Disk selection + JSON patch)
ECFG="$(prepare_effective_config || true)"

if [ -z "$ECFG" ] || [ ! -f "$ECFG" ]; then
    echo "[x] Failed to generate effective configuration. Falling back to default (risky)."
    ECFG="$CONF_PATH"
else
    echo "[x] Generated effective config: $ECFG"
fi

ARGS="--config $ECFG"
if [ -f "$CREDS_PATH" ]; then
  echo "[x] Using credentials: $CREDS_PATH"
  ARGS="$ARGS --creds $CREDS_PATH"
else
  echo "[x] No credentials file found. You will be prompted for passwords."
fi

# Run archinstall
if archinstall $ARGS; then
  INSTALL_OK=1
else
  echo "[x] archinstall failed."
fi

if [ "$INSTALL_OK" = "1" ] && [ -f /root/x-postinstall.sh ]; then
  echo "──────────────────────────────────────────"
  echo "   Running x Post-Installation Script"
  echo "──────────────────────────────────────────"
  bash /root/x-postinstall.sh || echo "[x] Post-install script failed!"
  
  echo
  echo "──────────────────────────────────────────"
  echo "Installation Complete. Rebooting in 5s..."
  echo "──────────────────────────────────────────"
  for i in 5 4 3 2 1; do
    printf "\rRebooting in %s s… " "$i"
    sleep 1
  done
  echo
  systemctl reboot || reboot || echo "[x] Please reboot manually."
fi
