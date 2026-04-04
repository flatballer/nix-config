#!/usr/bin/env bash
# Build a NixOS SD card image for Raspberry Pi 5.
#
# Requirements:
#   - An aarch64-linux remote builder configured in modules/darwin/base.nix
#     (or run this script directly on an aarch64-linux machine).
#
# Output: result/sd-image/nixos-*.img.zst
#
# Flash to SD card (replace /dev/rdiskN):
#   zstdcat result/sd-image/nixos-*.img.zst | sudo dd of=/dev/rdiskN bs=4m status=progress
set -euo pipefail

FLAKE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> Building NixOS SD image for Raspberry Pi 5..."
echo "    (requires aarch64-linux remote builder from Mac)"
nix build "${FLAKE_DIR}#nixosConfigurations.pi5.config.system.build.sdImage" \
  --print-build-logs \
  "$@"

echo ""
echo "==> Done. Image: $(readlink -f result)/sd-image/"
echo ""
echo "==> Flash to SD card (replace /dev/rdiskN with your device):"
echo "    zstdcat result/sd-image/nixos-*.img.zst | sudo dd of=/dev/rdiskN bs=4m status=progress"
