{
  description = "Cross-platform nix config: macOS, NixOS (Pi4, Pi5), Docker, Ubuntu/Jetson nix profiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:nixos/nixos-hardware";

    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ { self, nix-darwin, nixos-hardware, nixpkgs, nixvim }:
  let
    # ── Helpers ─────────────────────────────────────────────────────────────

    # Build a nixvim-wrapped neovim for a given system.
    nvimFor = system: (nixvim.lib.evalNixvim {
      inherit system;
      modules = [ ./nixvim.nix ];
    }).config.build.package;

    # A nix profile environment installable on Ubuntu / Jetson (no NixOS).
    # Install with: nix profile install .#packages.<system>.userEnv
    userEnvFor = system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in pkgs.buildEnv {
        name = "user-env";
        paths = with pkgs; [
          (nvimFor system)
          nixd alejandra
          ruff uv ty
          bat fzf zoxide
          gh eza carapace nmap
          tree-sitter
        ];
      };

  in {
    # ── macOS ──────────────────────────────────────────────────────────────
    # darwin-rebuild build --flake .#TMA-M4
    darwinConfigurations."TMA-M4" = nix-darwin.lib.darwinSystem {
      specialArgs = { inherit inputs self; };
      modules = [
        ./hosts/TMA-M4/default.nix
        {
          # Inject nvim into system packages
          environment.systemPackages = [ (nvimFor "aarch64-darwin") ];
          # Required by nix-darwin for user-scoped defaults (dock, finder, etc.)
          system.primaryUser = "thomasmargraf";
        }
      ];
    };

    # ── NixOS: Raspberry Pi 4 ─────────────────────────────────────────────
    # Build SD image: nix build .#nixosConfigurations.pi4.config.system.build.sdImage
    nixosConfigurations.pi4 = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { inherit inputs nixos-hardware; };
      modules = [
        ./hosts/pi4/default.nix
        { environment.systemPackages = [ (nvimFor "aarch64-linux") ]; }
      ];
    };

    # ── NixOS: Raspberry Pi 5 ─────────────────────────────────────────────
    nixosConfigurations.pi5 = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { inherit inputs nixos-hardware; };
      modules = [
        ./hosts/pi5/default.nix
        { environment.systemPackages = [ (nvimFor "aarch64-linux") ]; }
      ];
    };

    # ── NixOS: openclaw (Raspberry Pi 4) ──────────────────────────────────
    nixosConfigurations.openclaw = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      specialArgs = { inherit inputs nixos-hardware; };
      modules = [
        ./hosts/openclaw/default.nix
        { environment.systemPackages = [ (nvimFor "aarch64-linux") ]; }
      ];
    };

    # ── Per-system packages ───────────────────────────────────────────────
    packages = {
      # Standalone nvim (useful for quick installs: nix run .#packages.<sys>.nvim)
      aarch64-darwin.nvim  = nvimFor "aarch64-darwin";
      aarch64-linux.nvim   = nvimFor "aarch64-linux";
      x86_64-linux.nvim    = nvimFor "x86_64-linux";

      # nix profile for Ubuntu / Jetson (run on top of host OS)
      aarch64-linux.userEnv = userEnvFor "aarch64-linux";   # Jetson Nano + Pi
      x86_64-linux.userEnv  = userEnvFor "x86_64-linux";    # Ubuntu x86_64

      # Docker images (x86_64-linux; requires remote builder from Mac)
      x86_64-linux.dockerDev = import ./docker/dev.nix {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        nvim = nvimFor "x86_64-linux";
      };
      x86_64-linux.dockerMinimal = import ./docker/minimal.nix {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
      };
    };
  };
}
