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
echo "   Press Ctrl+C to cancel."
echo "──────────────────────────────────────────"

for i in 5 4 3 2 1; do
  printf "\rStarting archinstall in %s s… (Ctrl+C to cancel) " "$i"
  sleep 1
done
echo
echo "→ Starting archinstall (Automated with config)…"
echo

CONF_PATH="./user_configuration.json"
CREDS_PATH="./user_credentials.json"
[ -f "$CONF_PATH" ] || CONF_PATH="/root/user_configuration.json"
[ -f "$CREDS_PATH" ] || CREDS_PATH="/root/user_credentials.json"

# Usar copia temporal para modificaciones, preservando el JSON original
CONF_RUN="$CONF_PATH"
if [ -f "$CONF_PATH" ]; then
  TMP_CONF=$(mktemp)
  cp "$CONF_PATH" "$TMP_CONF"
  CONF_RUN="$TMP_CONF"
fi

ISO_SRC=$(findmnt -n -o SOURCE /run/archiso/bootmnt 2>/dev/null || true)
ISO_PK=""
[ -n "$ISO_SRC" ] && ISO_PK=$(lsblk -no PKNAME "$ISO_SRC" 2>/dev/null | head -n1)
CANDS=$(lsblk -dn -o NAME,TYPE,RM,RO | awk '$2=="disk" && $3=="0" && $4=="0" && $1 !~ /^sr/{print $1}')
MIN_SIZE=${XOS_MIN_SIZE_BYTES:-34359738368}
BEST_EMPTY=""
BEST_EMPTY_SIZE=0
BEST_ANY=""
BEST_ANY_SIZE=0
for n in $CANDS; do
  [ -n "$ISO_PK" ] && [ "$n" = "$ISO_PK" ] && continue
  SIZE=$(blockdev --getsize64 "/dev/$n" 2>/dev/null || echo 0)
  [ "$SIZE" -lt "$MIN_SIZE" ] && continue
  PARTS=$(lsblk -n "/dev/$n" -o TYPE | grep -c '^part$' || true)
  [ "$SIZE" -gt "$BEST_ANY_SIZE" ] && BEST_ANY="$n" && BEST_ANY_SIZE="$SIZE"
  if [ "$PARTS" -eq 0 ] && [ "$SIZE" -gt "$BEST_EMPTY_SIZE" ]; then
    BEST_EMPTY="$n"
    BEST_EMPTY_SIZE="$SIZE"
  fi
done
TARGET="${BEST_EMPTY:-$BEST_ANY}"
if [ -n "${XOS_TARGET_DEVICE:-}" ]; then
  case "${XOS_TARGET_DEVICE}" in
    /dev/*) TARGET="${XOS_TARGET_DEVICE#/dev/}" ;;
    *) TARGET="${XOS_TARGET_DEVICE}" ;;
  esac
fi
if [ -n "$TARGET" ]; then
  echo "[XOs] Target disk selected: /dev/$TARGET"
else
  echo "[XOs] No suitable target disk found, falling back to interactive Archinstall."
fi
if [ -n "$TARGET" ] && [ -f "$CONF_RUN" ]; then
  DEV="/dev/$TARGET"
  if command -v jq >/dev/null 2>&1; then
    TMP=$(mktemp)
    jq '.disk_config.device_modifications[0].device = "'"$DEV"'"' "$CONF_RUN" > "$TMP" && mv "$TMP" "$CONF_RUN"
  else
    sed -i -E '0,/\"device\"[[:space:]]*:[[:space:]]*\"[^\"]*\"/s//\"device\": \"'"$DEV"'\"/' "$CONF_RUN"
  fi
fi

if [ -f "$CONF_RUN" ] && command -v jq >/dev/null 2>&1; then
  BIDX=$(jq -r '.disk_config.device_modifications[0].partitions | to_entries[] | select(.value.fs_type=="btrfs") | .key' "$CONF_RUN" | head -n1)
  FIDX=$(jq -r '.disk_config.device_modifications[0].partitions | to_entries[] | select(.value.fs_type=="fat32") | .key' "$CONF_RUN" | head -n1)
  if [ -n "$FIDX" ] && [ -n "${XOS_BOOT_SIZE_MIB:-}" ]; then
    BOOT_UNIT=$(jq -r ".disk_config.device_modifications[0].partitions[$FIDX].size.unit" "$CONF_RUN")
    case "$BOOT_UNIT" in
      MiB|MIB|MiB) NEW_BOOT_VAL=${XOS_BOOT_SIZE_MIB} ;;
      GiB|GIB|GiB) NEW_BOOT_VAL=$(( XOS_BOOT_SIZE_MIB / 1024 )) ;;
      B) NEW_BOOT_VAL=$(( XOS_BOOT_SIZE_MIB * 1048576 )) ;;
      *) NEW_BOOT_VAL=${XOS_BOOT_SIZE_MIB} ;;
    esac
    TMP=$(mktemp)
    jq ".disk_config.device_modifications[0].partitions[$FIDX].size.value = ${NEW_BOOT_VAL}" "$CONF_RUN" > "$TMP" && mv "$TMP" "$CONF_RUN"
  fi
  if [ -n "$BIDX" ]; then
    BUNIT=$(jq -r ".disk_config.device_modifications[0].partitions[$BIDX].size.unit" "$CONF_RUN")
    SUNIT=$(jq -r ".disk_config.device_modifications[0].partitions[$BIDX].start.unit" "$CONF_RUN")
    SVAL=$(jq -r ".disk_config.device_modifications[0].partitions[$BIDX].start.value" "$CONF_RUN")
    case "$SUNIT" in
      MiB|MIB|MiB) START_BYTES=$(( SVAL * 1048576 )) ;;
      GiB|GIB|GiB) START_BYTES=$(( SVAL * 1073741824 )) ;;
      B) START_BYTES=$(( SVAL )) ;;
      *) START_BYTES=$(( SVAL * 1048576 )) ;;
    esac
    if [ -n "$TARGET" ]; then
      DISK_BYTES=$(blockdev --getsize64 "/dev/$TARGET" 2>/dev/null || echo 0)
    else
      DISK_BYTES=0
    fi
    if [ "$BUNIT" = "Percent" ]; then
      if [ -n "${XOS_ROOT_PERCENT:-}" ]; then
        TMP=$(mktemp)
        jq ".disk_config.device_modifications[0].partitions[$BIDX].size.value = ${XOS_ROOT_PERCENT}" "$CONF_RUN" > "$TMP" && mv "$TMP" "$CONF_RUN"
      fi
    else
      if [ "$DISK_BYTES" -gt 0 ]; then
        REST_BYTES=$(( DISK_BYTES - START_BYTES ))
        case "$BUNIT" in
          B) NEW_SIZE_VAL=$REST_BYTES ;;
          MiB|MIB|MiB) NEW_SIZE_VAL=$(( REST_BYTES / 1048576 )) ;;
          GiB|GIB|GiB) NEW_SIZE_VAL=$(( REST_BYTES / 1073741824 )) ;;
          *) NEW_SIZE_VAL=$(( REST_BYTES / 1048576 )) ;;
        esac
        TMP=$(mktemp)
        jq ".disk_config.device_modifications[0].partitions[$BIDX].size.value = ${NEW_SIZE_VAL}" "$CONF_RUN" > "$TMP" && mv "$TMP" "$CONF_RUN"
      fi
    fi
  fi
  if [ -n "$BIDX" ] && [ -n "$FIDX" ] && [ -n "${XOS_BOOT_SIZE_MIB:-}" ]; then
    BSTART_UNIT=$(jq -r ".disk_config.device_modifications[0].partitions[$BIDX].start.unit" "$CONF_RUN")
    BOOT_UNIT=$(jq -r ".disk_config.device_modifications[0].partitions[$FIDX].size.unit" "$CONF_RUN")
    BOOT_VAL=$(jq -r ".disk_config.device_modifications[0].partitions[$FIDX].size.value" "$CONF_RUN")
    case "$BOOT_UNIT" in
      GiB|GIB|GiB) BOOT_MIB=$(( BOOT_VAL * 1024 )) ;;
      MiB|MIB|MiB) BOOT_MIB=$BOOT_VAL ;;
      B) BOOT_MIB=$(( BOOT_VAL / 1048576 )) ;;
      *) BOOT_MIB=$BOOT_VAL ;;
    esac
    NEW_START_MIB=$(( BOOT_MIB + 1 ))
    case "$BSTART_UNIT" in
      MiB|MIB|MiB) NEW_START_VAL=$NEW_START_MIB ;;
      GiB|GIB|GiB) NEW_START_VAL=$(( NEW_START_MIB / 1024 )) ;;
      B) NEW_START_VAL=$(( NEW_START_MIB * 1048576 )) ;;
      *) NEW_START_VAL=$NEW_START_MIB ;;
    esac
    TMP=$(mktemp)
    jq ".disk_config.device_modifications[0].partitions[$BIDX].start.value = ${NEW_START_VAL}" "$CONF_RUN" > "$TMP" && mv "$TMP" "$CONF_RUN"
  fi
elif [ -f "$CONF_RUN" ]; then
  python3 - "$CONF_RUN" "$TARGET" "${XOS_ROOT_PERCENT:-}" "${XOS_BOOT_SIZE_MIB:-}" << 'PY'
import json,sys,subprocess
path=sys.argv[1]
target=sys.argv[2]
root_pct=sys.argv[3]
boot_mib_arg=sys.argv[4]
with open(path,'r',encoding='utf-8') as f:
    data=json.load(f)
dc=data.get('disk_config',{})
mods=dc.get('device_modifications') or []
if not mods:
    sys.exit(0)
dm=mods[0]
parts=dm.get('partitions',[])
bidx=next((i for i,p in enumerate(parts) if p.get('fs_type')=='btrfs'), None)
fidx=next((i for i,p in enumerate(parts) if p.get('fs_type')=='fat32'), None)
def to_bytes(unit,val):
    if unit in ('MiB','MIB','MiB'): return int(val)*1048576
    if unit in ('GiB','GIB','GiB'): return int(val)*1073741824
    return int(val)
def from_bytes(unit,bytes_):
    if unit in ('MiB','MIB','MiB'): return bytes_//1048576
    if unit in ('GiB','GIB','GiB'): return bytes_//1073741824
    return bytes_
if fidx is not None and boot_mib_arg:
    u=parts[fidx]['size'].get('unit')
    b_mib=int(boot_mib_arg)
    if u in ('MiB','MIB','MiB'): parts[fidx]['size']['value']=b_mib
    elif u in ('GiB','GIB','GiB'): parts[fidx]['size']['value']=b_mib//1024
    elif u=='B': parts[fidx]['size']['value']=b_mib*1048576
    else: parts[fidx]['size']['value']=b_mib
if bidx is not None:
    su=parts[bidx]['start'].get('unit')
    sv=int(parts[bidx]['start'].get('value',0))
    start_bytes=to_bytes(su,sv)
    bu=parts[bidx]['size'].get('unit')
    if bu=='Percent':
        if root_pct: parts[bidx]['size']['value']=int(root_pct)
    else:
        disk_bytes=0
        if target:
            try:
                disk_bytes=int(subprocess.check_output(['blockdev','--getsize64','/dev/'+target],text=True).strip())
            except Exception:
                disk_bytes=0
        if disk_bytes>0:
            rest_bytes=max(0,disk_bytes-start_bytes)
            parts[bidx]['size']['value']=from_bytes(bu,rest_bytes)
    if fidx is not None and boot_mib_arg:
        fu=parts[fidx]['size'].get('unit')
        fv=int(parts[fidx]['size'].get('value',0))
        if fu in ('GiB','GIB','GiB'): boot_mib=fv*1024
        elif fu in ('MiB','MIB','MiB'): boot_mib=fv
        elif fu=='B': boot_mib=fv//1048576
        else: boot_mib=fv
        new_start_mib=boot_mib+1
        if su in ('MiB','MIB','MiB'): parts[bidx]['start']['value']=new_start_mib
        elif su in ('GiB','GIB','GiB'): parts[bidx]['start']['value']=new_start_mib//1024
        elif su=='B': parts[bidx]['start']['value']=new_start_mib*1048576
        else: parts[bidx]['start']['value']=new_start_mib
with open(path,'w',encoding='utf-8') as f:
    json.dump(data,f)
PY
fi

INSTALL_OK=0
if [ -f "$CONF_RUN" ]; then
  if [ -f "$CREDS_PATH" ]; then
    if archinstall --config "$CONF_RUN" --creds "$CREDS_PATH"; then INSTALL_OK=1; fi
  else
    if archinstall --config "$CONF_RUN"; then INSTALL_OK=1; fi
  fi
else
  if archinstall; then INSTALL_OK=1; fi
fi

# Postinstall (branding xos)
if [ "$INSTALL_OK" = "1" ] && [ -f /root/xos-postinstall.sh ]; then
  bash /root/xos-postinstall.sh || true
else
  if [ "$INSTALL_OK" != "1" ]; then
    echo "[XOs] Archinstall failed. Check /var/log/archinstall/install.log for details." || true
  fi
fi
