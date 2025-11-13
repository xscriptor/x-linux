#!/usr/bin/env bash
set -euo pipefail

# Dont excecute while building mkarchiso
grep -q "/run/archiso/bootmnt" /proc/mounts 2>/dev/null || { return 0 2>/dev/null || exit 0; }

# Allow deactivate
[ "${XOS_NO_AUTO:-0}" = "1" ] && { echo "[XOs] Autoinicio desactivado (XOS_NO_AUTO=1)."; return 0 2>/dev/null || exit 0; }

# Only on TTY1
[ "$(tty)" = "/dev/tty1" ] || { return 0 2>/dev/null || exit 0; }

echo
echo "──────────────────────────────────────────"
echo "   XOs Live – Archinstall will start in 5s"
echo "   Pulsa Ctrl+C para cancelar."
echo "──────────────────────────────────────────"

for i in 5 4 3 2 1; do
  printf "\rStarting archinstall in %s s… (Ctrl+C to cancel) " "$i"
  sleep 1
done
echo
echo "→ Starting archinstall (Automated with config)…"
echo

CONF_PATH="/root/archinstall_config.json"
CREDS_PATH="/root/user_credentials.json"

ISO_SRC=$(findmnt -n -o SOURCE /run/archiso/bootmnt 2>/dev/null || true)
ISO_PK=""
[ -n "$ISO_SRC" ] && ISO_PK=$(lsblk -no PKNAME "$ISO_SRC" 2>/dev/null | head -n1)
CANDS=$(lsblk -dn -o NAME,TYPE | awk '$2=="disk"{print $1}')
BEST_EMPTY=""
BEST_EMPTY_SIZE=0
BEST_ANY=""
BEST_ANY_SIZE=0
for n in $CANDS; do
  [ -n "$ISO_PK" ] && [ "$n" = "$ISO_PK" ] && continue
  SIZE=$(blockdev --getsize64 "/dev/$n" 2>/dev/null || echo 0)
  PARTS=$(lsblk -n "/dev/$n" -o TYPE | grep -c '^part$' || true)
  [ "$SIZE" -gt "$BEST_ANY_SIZE" ] && BEST_ANY="$n" && BEST_ANY_SIZE="$SIZE"
  if [ "$PARTS" -eq 0 ] && [ "$SIZE" -gt "$BEST_EMPTY_SIZE" ]; then
    BEST_EMPTY="$n"
    BEST_EMPTY_SIZE="$SIZE"
  fi
done
TARGET="${BEST_EMPTY:-$BEST_ANY}"
if [ -n "$TARGET" ] && [ -f "$CONF_PATH" ]; then
  DEV="/dev/$TARGET"
  if command -v jq >/dev/null 2>&1; then
    TMP=$(mktemp)
    jq '.disk_config.device_modifications[0].device = "'"$DEV"'"' "$CONF_PATH" > "$TMP" && mv "$TMP" "$CONF_PATH"
  else
    sed -i -E '0,/\"device\"[[:space:]]*:[[:space:]]*\"[^\"]*\"/s//\"device\": \"'"$DEV"'\"/' "$CONF_PATH"
  fi
fi

INSTALL_OK=0
if [ -f "$CONF_PATH" ]; then
  if [ -f "$CREDS_PATH" ]; then
    if archinstall --config "$CONF_PATH" --creds "$CREDS_PATH"; then INSTALL_OK=1; fi
  else
    if archinstall --config "$CONF_PATH"; then INSTALL_OK=1; fi
  fi
else
  if archinstall; then INSTALL_OK=1; fi
fi

# Postinstall (branding del sistema instalado)
if [ "$INSTALL_OK" = "1" ] && [ -f /root/xos-postinstall.sh ]; then
  bash /root/xos-postinstall.sh || true
fi
