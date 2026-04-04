#!/usr/bin/env bash
# Build Docker images defined in docker/ and optionally load them.
#
# Usage:
#   ./scripts/build-docker.sh dev      # build dev-env image
#   ./scripts/build-docker.sh minimal  # build minimal-env image
#   ./scripts/build-docker.sh all      # build both
#
# Requirements (building from Mac):
#   - An x86_64-linux remote builder configured in modules/darwin/base.nix
#   - Docker running locally to load and run the image
set -euo pipefail

FLAKE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="${1:-all}"

build_image() {
  local attr="$1"
  local tag="$2"

  echo "==> Building ${tag}..."
  nix build "${FLAKE_DIR}#packages.x86_64-linux.${attr}" \
    --print-build-logs \
    --out-link "result-${attr}"

  if command -v docker &>/dev/null; then
    echo "==> Loading ${tag} into Docker..."
    "result-${attr}" | docker load
    echo "==> Loaded. Run with: docker run --rm -it ${tag}"
  else
    echo "==> Docker not found. Load manually:"
    echo "    result-${attr} | docker load"
  fi
}

case "$TARGET" in
  dev)
    build_image dockerDev dev-env
    ;;
  minimal)
    build_image dockerMinimal minimal-env
    ;;
  all)
    build_image dockerDev dev-env
    build_image dockerMinimal minimal-env
    ;;
  *)
    echo "Usage: $0 [dev|minimal|all]" >&2
    exit 1
    ;;
esac
