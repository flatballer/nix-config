#!/usr/bin/env bash
# Apply the nix-darwin configuration to the local Mac.
set -euo pipefail

FLAKE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> Switching Mac configuration (TMA-M4)..."
darwin-rebuild switch --flake "${FLAKE_DIR}#TMA-M4"
