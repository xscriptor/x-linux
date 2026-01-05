#!/usr/bin/env bash
set -euo pipefail

[ "${XOS_DEBUG:-0}" = "1" ] && set -x
[ "${XOS_NO_AUTO:-0}" = "1" ] && { echo "[XOs] Autostart disabled (XOS_NO_AUTO=1)."; return 0 2>/dev/null || exit 0; }
[ "${XOS_FORCE:-0}" != "1" ] && {
  if ! grep -q "/run/archiso/bootmnt" /proc/mounts 2>/dev/null && [ ! -d /run/archiso/airootfs ] && ! grep -Eq 'archisobasedir=|archisosearchuuid=' /proc/cmdline; then
    return 0 2>/dev/null || exit 0
  fi
}
[ "$(tty)" = "/dev/tty1" ] || { :; }

echo
echo "──────────────────────────────────────────"
echo "   XOs Live – Archinstall will start in 5s"
echo "   Press Ctrl+C to cancel."
echo "──────────────────────────────────────────"
for i in 5 4 3 2 1; do
  printf "\rStarting archinstall in %s s… (Ctrl+C to cancel) " "$i"
  sleep 1
done
echo
echo "→ Starting archinstall (Automated with config)…"
echo

CONF_PATH="/root/user_configuration.json"
CREDS_PATH="/root/user_credentials.json"

pick_target_disk() {
  local disks target
  disks=$(lsblk -dn -o NAME,TYPE,RM | awk '$2=="disk"{print $1" "$3}')
  while read -r name rm; do
    local path="/dev/$name"
    findmnt -no TARGET -S "$path" | grep -q "/run/archiso/bootmnt" && continue
    [ "$rm" = "1" ] && continue
    target="$path"
    break
  done <<< "$disks"
  if [ -z "$target" ]; then
    target=$(lsblk -dn -o NAME,TYPE | awk '$2=="disk"{print "/dev/"$1; exit}')
  fi
  echo "$target"
}

prepare_effective_config() {
  local target size_b size_mb boot_start_mib boot_size_mib root_start_mib root_size_mib tmpcfg
  target="$(pick_target_disk)"
  [ -n "$target" ] || return 1
  size_b="$(lsblk -b -dn -o SIZE "$target" 2>/dev/null || echo 0)"
  size_mb=$(( size_b / (1024*1024) ))
  boot_start_mib=1
  boot_size_mib=512
  root_start_mib=$(( boot_start_mib + boot_size_mib ))
  # Reserve a small tail room to avoid end-of-disk boundary issues
  root_size_mib=$(( size_mb - root_start_mib - 4 ))
  if [ "$root_size_mib" -lt 4096 ]; then
    root_size_mib=$(( size_mb - root_start_mib - 1 ))
  fi
  tmpcfg="/tmp/user_configuration.effective.json"
  PY="$(command -v python3 || command -v python || echo)"
  [ -n "$PY" ] || return 1
  "$PY" - "$CONF_PATH" "$tmpcfg" "$target" "$boot_start_mib" "$boot_size_mib" "$root_start_mib" "$root_size_mib" << 'PY'
import json, sys
src, dst, dev, boot_start_mib, boot_size_mib, root_start_mib, root_size_mib = sys.argv[1:]
with open(src) as f:
    cfg = json.load(f)
dc = cfg.get("disk_config", {})
mods = dc.get("device_modifications", [])
if not mods:
    mods = [{}]
    dc["device_modifications"] = mods
m = mods[0]
m["device"] = dev
parts = m.get("partitions", [])
if not parts or len(parts) < 2:
    parts = [{}, {}]
    m["partitions"] = parts
p0, p1 = parts[0], parts[1]
p0["fs_type"] = "fat32"
p0["mountpoint"] = "/boot"
p0["flags"] = ["boot","esp"]
p0["type"] = "primary"
p0["status"] = "create"
p0["size"] = {"sector_size": None, "unit":"MiB","value":int(boot_size_mib)}
p0["start"] = {"sector_size": None, "unit":"MiB","value":int(boot_start_mib)}
p1["fs_type"] = "btrfs"
p1["mount_options"] = ["compress=zstd"]
p1["type"] = "primary"
p1["status"] = "create"
p1["size"] = {"sector_size": None, "unit":"MiB","value":int(root_size_mib)}
p1["start"] = {"sector_size": None, "unit":"MiB","value":int(root_start_mib)}
with open(dst, "w") as f:
    json.dump(cfg, f, indent=4)
print(dst)
PY
}

INSTALL_OK=0
echo "[XOs] Using config: $CONF_PATH"
if [ -f "$CREDS_PATH" ]; then
  echo "[XOs] Using creds: $CREDS_PATH"
  ECFG="$(prepare_effective_config || true)"
  if [ -n "$ECFG" ] && [ -f "$ECFG" ]; then
    if archinstall --config "$ECFG" --creds "$CREDS_PATH"; then INSTALL_OK=1; fi
  else
    if archinstall --config "$CONF_PATH" --creds "$CREDS_PATH"; then INSTALL_OK=1; fi
  fi
else
  echo "[XOs] Credentials file not found at $CREDS_PATH, proceeding without creds."
  ECFG="$(prepare_effective_config || true)"
  if [ -n "$ECFG" ] && [ -f "$ECFG" ]; then
    if archinstall --config "$ECFG"; then INSTALL_OK=1; fi
  else
    if archinstall --config "$CONF_PATH"; then INSTALL_OK=1; fi
  fi
fi

if [ "$INSTALL_OK" = "1" ] && [ -f /root/xos-postinstall.sh ]; then
  bash /root/xos-postinstall.sh || true
  echo
  echo "──────────────────────────────────────────"
  echo "Please quit the installation media; the system will reboot."
  echo "──────────────────────────────────────────"
  for i in 5 4 3 2 1; do
    printf "\rRebooting in %s s… " "$i"
    sleep 1
  done
  echo
  systemctl reboot || reboot || echo "[XOs] Failed to trigger reboot. Please reboot manually."
fi
