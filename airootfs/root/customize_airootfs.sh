#!/usr/bin/env bash
# Inicializa y prepara el keyring de pacman dentro del airootfs del ISO.
# Sin TTY checks, sin autostart, sin countdown.
set -euo pipefail

pacman-key --init
pacman-key --populate archlinux
pacman -Sy --noconfirm archlinux-keyring