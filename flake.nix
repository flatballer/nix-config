{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs,
    nixvim,
  }: let
    system = "aarch64-darwin";
    pkgsFor = nixpkgs.legacyPackages.${system};
    nvim = nixvim.lib.${system}.makeNixvimWithModule {
      pkgs = pkgsFor;
      module = import ./nixvim.nix;
    };
    configuration = {pkgs, ...}: {
      nix.enable = false;
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs; [
        nvim
        nixd
        alejandra
        ruff
        uv
        ty
        bat
        fzf
        fzf-zsh-plugin
        zsh-fzf-tab
        zoxide
        nmap
        tree-sitter
        carapace
        carapace-bridge
        gh
        eza
      ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = system;
      
      # Enable Touch ID auth for sudo 
      security.pam.services.sudo_local.touchIdAuth = true;
      
      # Set the NIX?PATH for nixd
      nix.nixPath = ["nixpkgs=${inputs.nixpkgs}"];
    };
  in {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."TMA-M4" = nix-darwin.lib.darwinSystem {
      modules = [configuration];
      system.defaults = {
        nix.linux-builder.enable = true;
        dock.autohide = true;
        dock.mru-spaces = false;
        finder.AppleShowAllExtensions = true;
        finder.FXPreferredViewStyle = "clmv";
        loginwindow.LoginwindowText = "Managed by areto and Flatballer";
        screencapture.location = "~/Pictures/screenshots";
        screensaver.askForPasswordDelay = 10;
      };
    };
  };
}
