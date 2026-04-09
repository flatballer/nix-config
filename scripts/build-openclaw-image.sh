#!/usr/bin/env bash
# Build a NixOS SD card image for openclaw (Raspberry Pi 4).
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

echo "==> Building NixOS SD image for openclaw (Raspberry Pi 4)..."
echo "    (requires aarch64-linux remote builder from Mac)"
sudo nix build "${FLAKE_DIR}#nixosConfigurations.openclaw.config.system.build.sdImage" \
  --print-build-logs \
  --builders-use-substitutes \
  "$@"

echo ""
echo "==> Done. Image: $(readlink -f result)/sd-image/"
echo ""
echo "==> Flash to SD card (replace /dev/rdiskN with your device):"
echo "    zstdcat result/sd-image/nixos-*.img.zst | sudo dd of=/dev/rdiskN bs=4m status=progress"
