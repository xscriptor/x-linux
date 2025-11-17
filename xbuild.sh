#!/usr/bin/env bash
set -Eeuo pipefail

LOG="build-$(date +%Y%m%d-%H%M).log"

# 0) Comprobar que existe pacman.conf y el perfil actual (profiledef.sh)
[[ -f pacman.conf ]] || { echo "Falta pacman.conf en este directorio"; exit 1; }
[[ -f profiledef.sh ]] || { echo "Falta profiledef.sh (no estás en la raíz del perfil archiso)"; exit 1; }

# 1) Intento de desmonte limpio (evita errores "target is busy")
for mp in work/x86_64/airootfs/proc work/x86_64/airootfs/sys work/x86_64/airootfs/dev work/x86_64/airootfs/run; do
  if mountpoint -q "$mp"; then
    sudo umount -l "$mp" || true   # -l lazy umount
  fi
done
# Si hubiera algo más montado dentro de airootfs, haz un umount recursivo "lazy":
if mountpoint -q work/x86_64/airootfs; then
  sudo umount -Rl work/x86_64/airootfs || true
fi

# 2) Limpieza de work/ y out/
sudo rm -rf work out

# 3) Build verboso con rutas explícitas
sudo mkarchiso -C pacman.conf -v -w ./work -o ./out . 2>&1 | tee "$LOG"

# 4) Verificación de la ISO y mensaje claro
ISO_COUNT=$(find ./out -maxdepth 2 -type f -name '*.iso' | wc -l)
if [[ "$ISO_COUNT" -gt 0 ]]; then
  echo "ISO creada:"
  find ./out -maxdepth 2 -type f -name '*.iso' -printf ' - %p (%k KB)\n'
else
  echo "No se encontró ISO en ./out. Revisa el log: $LOG"
  echo "Suele fallar por: falta de espacio, error en profiledef.sh, o un exit 1 en xos-customize.sh."
  exit 2
fi
