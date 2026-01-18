#!/bin/bash
# Build and create repository for xos-release package
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$SCRIPT_DIR/repo/x86_64"

echo "==> Building xos-release package..."
cd "$SCRIPT_DIR/xos-release"
makepkg -sf --noconfirm

echo "==> Creating repository structure..."
mkdir -p "$REPO_DIR"

echo "==> Moving package to repository..."
mv -f xos-release-*.pkg.tar.zst "$REPO_DIR/" 2>/dev/null || true

echo "==> Generating repository database..."
cd "$REPO_DIR"
repo-add xos.db.tar.gz xos-release-*.pkg.tar.zst

echo ""
echo "==> Repository ready at: $REPO_DIR"
echo "    Files:"
ls -la "$REPO_DIR"
echo ""
echo "==> Upload the contents of $REPO_DIR to your server/GitHub"
echo "    Example: https://github.com/xscriptordev/xos-repo/releases"
