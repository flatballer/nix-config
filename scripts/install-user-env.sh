#!/usr/bin/env bash
# Install the nix user environment on Ubuntu or Jetson (aarch64 / x86_64).
# Installs nix if not present, then adds the userEnv profile.
#
# Run on the target machine (not from the Mac):
#   curl -fsSL https://raw.githubusercontent.com/flatballer/nix-config/main/scripts/install-user-env.sh | bash
# or from a local clone:
#   ./scripts/install-user-env.sh
set -euo pipefail

FLAKE_URL="${1:-github:flatballer/nix-config}"

# 1. Install nix if missing
if ! command -v nix &>/dev/null; then
  echo "==> nix not found. Installing via Determinate Systems installer..."
  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix \
    | sh -s -- install --no-confirm
  # Source nix into current shell
  # shellcheck disable=SC1091
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# 2. Detect architecture
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64)  SYSTEM="x86_64-linux" ;;
  aarch64) SYSTEM="aarch64-linux" ;;
  *)
    echo "Unsupported architecture: $ARCH" >&2
    exit 1
    ;;
esac

echo "==> Installing userEnv for ${SYSTEM} from ${FLAKE_URL}..."
nix profile install "${FLAKE_URL}#packages.${SYSTEM}.userEnv" \
  --extra-experimental-features "nix-command flakes"

echo ""
echo "==> Done. Restart your shell or run:"
echo "    source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
echo ""
echo "==> To update later:"
echo "    nix profile upgrade '.*userEnv.*'"
