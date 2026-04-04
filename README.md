# nix-darwin-config

Cross-platform nix configuration for macOS, NixOS (Raspberry Pi), Ubuntu/Jetson nix profiles, and Docker images. All machines share the same tool set and a unified [nixvim](https://github.com/nix-community/nixvim) Neovim configuration managed by nix — no Homebrew, no Mason, no lazy.nvim.

---

## Features

### Neovim (nixvim)
Fully declarative Neovim built from `nixvim.nix`. No plugin manager, no runtime downloads.

| Feature | Details |
|---|---|
| Colorscheme | tokyonight-night |
| Completion | blink.cmp (Rust-based, fast) |
| LSP | nixd, lua_ls, basedpyright, ruff, sqls, ty |
| Formatting | conform.nvim (ruff, stylua, alejandra, markdownlint, shfmt) — format on save |
| Fuzzy finder | fzf-lua + UI select integration |
| File explorer | oil.nvim |
| AI completion | copilot.lua |
| Treesitter | lua, python, bash, markdown, json, yaml, sql |
| Git | gitsigns |
| SQL | vim-dadbod + dadbod-ui + dadbod-completion |
| Keymaps | which-key for discoverability |
| Python venv | auto-detects and activates uv `.venv` on buffer open |

All LSP servers and formatters come from nixpkgs — no Mason involved.

### Shared CLI tools
Available on all platforms: `bat`, `eza`, `fzf`, `zoxide`, `gh`, `carapace`, `nmap`, `nix`, `alejandra`, `ruff`, `uv`, `ty`, `nixd`.

---

## Platform targets

| Target | Flake output | System |
|---|---|---|
| Mac (`TMA-M4`) | `darwinConfigurations.TMA-M4` | `aarch64-darwin` |
| Raspberry Pi 4 | `nixosConfigurations.pi4` | `aarch64-linux` |
| Raspberry Pi 5 | `nixosConfigurations.pi5` | `aarch64-linux` |
| Jetson Nano (L4T Ubuntu) | `packages.aarch64-linux.userEnv` | `aarch64-linux` |
| Ubuntu x86\_64 | `packages.x86_64-linux.userEnv` | `x86_64-linux` |
| Docker dev image | `packages.x86_64-linux.dockerDev` | `x86_64-linux` |
| Docker minimal image | `packages.x86_64-linux.dockerMinimal` | `x86_64-linux` |

---

## Repository structure

```
flake.nix               # Orchestrator: wires all outputs together
nixvim.nix              # Neovim config (nixvim module)
modules/
  common.nix            # Shared packages (all platforms)
  darwin/
    base.nix            # macOS settings (nix-darwin)
  nixos/
    base.nix            # Shared NixOS settings (SSH, locale, nix)
hosts/
  TMA-M4/default.nix   # Mac host config
  pi4/default.nix       # Raspberry Pi 4 host config + SD image
  pi5/default.nix       # Raspberry Pi 5 host config + SD image
docker/
  dev.nix               # Dev Docker image (nvim + all tools)
  minimal.nix           # Minimal base Docker image
scripts/
  switch-mac.sh         # Apply Mac config
  build-pi4-image.sh    # Build Pi 4 SD card image
  build-pi5-image.sh    # Build Pi 5 SD card image
  install-user-env.sh   # Install nix profile on Ubuntu / Jetson
  build-docker.sh       # Build and optionally load Docker images
```

---

## Deployment

> **Cross-compiling from Mac**: Building `aarch64-linux` or `x86_64-linux` targets from an Apple Silicon Mac requires a remote Linux builder. See [Remote builder setup](#remote-builder-setup).

### macOS (nix-darwin)

```sh
# First time (installs nix-darwin if not present):
nix run nix-darwin -- switch --flake .#TMA-M4

# Subsequent updates:
./scripts/switch-mac.sh
# or:
darwin-rebuild switch --flake .#TMA-M4
```

### Raspberry Pi 4 / Pi 5

**Before building**, set your username and SSH public key in the host config:
- [hosts/pi4/default.nix](hosts/pi4/default.nix)
- [hosts/pi5/default.nix](hosts/pi5/default.nix)

```sh
# Build SD card image (requires aarch64-linux remote builder from Mac):
./scripts/build-pi4-image.sh   # → result/sd-image/nixos-*.img.zst
./scripts/build-pi5-image.sh

# Flash to SD card (replace /dev/rdiskN with your card):
zstdcat result/sd-image/nixos-*.img.zst | sudo dd of=/dev/rdiskN bs=4m status=progress
```

After first boot, the Pi can itself serve as a remote builder — see [Remote builder setup](#remote-builder-setup).

#### Updating a running Pi

```sh
# From the Pi (pull latest config and rebuild):
nixos-rebuild switch --flake github:YOUR_USER/nix-darwin-config#pi4
# or with a local clone:
nixos-rebuild switch --flake /path/to/nix-darwin-config#pi4
```

### Ubuntu / Jetson Nano (nix profile)

Full NixOS is not used on Jetson Nano due to NVIDIA's tightly coupled L4T kernel and bootloader. Instead, nix is installed on top of the host OS and a profile is applied.

```sh
# 1. Install nix (if not already installed):
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# 2. Install the user environment (auto-detects architecture):
./scripts/install-user-env.sh

# Or manually:
#   x86_64 Ubuntu:  nix profile install .#packages.x86_64-linux.userEnv
#   aarch64 Jetson: nix profile install .#packages.aarch64-linux.userEnv
```

### Docker images

```sh
# Build dev image (nvim + all tools) and load into Docker:
./scripts/build-docker.sh dev

# Build minimal base image and load:
./scripts/build-docker.sh minimal

# Build and load both:
./scripts/build-docker.sh all

# Run the dev image:
docker run --rm -it dev-env
```

> Requires an `x86_64-linux` remote builder when building from Mac.

---

## Remote builder setup

Building Linux targets from an Apple Silicon Mac requires a remote `aarch64-linux` (or `x86_64-linux`) builder. Your Raspberry Pi can serve this role after initial provisioning.

### 1. Create a dedicated build user on the builder machine

```sh
# On the remote Linux machine:
sudo useradd -m nix-build
sudo mkdir -p /home/nix-build/.ssh
```

### 2. Generate a key on the Mac

```sh
ssh-keygen -t ed25519 -f /etc/nix/builder_key -N ""
sudo cat /etc/nix/builder_key.pub  # copy this to the builder
```

### 3. Authorize the key on the builder

```sh
# On the remote Linux machine:
echo "PASTE_PUBLIC_KEY_HERE" | sudo tee /home/nix-build/.ssh/authorized_keys
sudo chown -R nix-build:nix-build /home/nix-build/.ssh
sudo chmod 600 /home/nix-build/.ssh/authorized_keys
# Allow nix-build to use the nix daemon:
echo "trusted-users = nix-build" | sudo tee -a /etc/nix/nix.conf
sudo systemctl restart nix-daemon
```

### 4. Enable in `modules/darwin/base.nix`

Uncomment the `nix.distributedBuilds` block and set `hostName` to your builder's address:

```nix
nix.distributedBuilds = true;
nix.buildMachines = [{
  hostName = "pi4.local";         # or IP address
  system = "aarch64-linux";
  sshUser = "nix-build";
  sshKey = "/etc/nix/builder_key";
  maxJobs = 4;
  supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
}];
```

---

## Updating

```sh
# Update all flake inputs:
nix flake update

# Apply updates on Mac:
./scripts/switch-mac.sh
```

---

## Key bindings (Neovim)

| Key | Action |
|---|---|
| `<leader>ff` | Find files (fzf-lua) |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>fr` | Recent files |
| `<leader>fw` | Grep word under cursor |
| `<leader>fd/fi/frf` | LSP definitions / implementations / references |
| `gd` / `K` / `gr` | LSP go to definition / hover / references |
| `<leader>rn` / `<leader>ca` | Rename / code action |
| `<leader>fo` | Format buffer |
| `[d` / `]d` | Previous / next diagnostic |
| `<leader>e` | Line diagnostics float |
| `-` | Open oil (file explorer) |
| `<leader>o` | Oil at CWD (float) |
| `<C-l>` | Accept Copilot suggestion |
| `<leader>at` | Toggle Copilot |
| `<C-h/j/k/l>` | Window navigation |
