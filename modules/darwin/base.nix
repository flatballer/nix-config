{ inputs, self, pkgs, lib, ... }:
{
  imports = [ ../common.nix ];

  nix.enable = false; # Determinate Systems manages the Nix daemon
  nix.settings.experimental-features = "nix-command flakes";
  nix.settings.builders-use-substitutes = true;
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  # Darwin-only packages
  # Note: ghostty is not in nixpkgs for macOS; install manually from ghostty.org
  environment.systemPackages = with pkgs; [
    fzf-zsh-plugin
    zsh-fzf-tab
    carapace-bridge
  ];

  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  environment.shellAliases = {
    ls = "eza --icons";
    ll = "eza -la --icons --git";
    la = "eza -a --icons";
    lt = "eza --tree --icons";
    cat = "bat";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    interactiveShellInit = ''
      # fzf shell integration
      source ${pkgs.fzf-zsh-plugin}/share/zsh/fzf-zsh-plugin/fzf-zsh-plugin.plugin.zsh

      # fzf-tab (must come after compinit, which enableCompletion triggers)
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

      # zoxide (smart cd)
      eval "$(zoxide init zsh)"

      # direnv hook
      eval "$(direnv hook zsh)"

      # carapace completions
      source <(carapace _carapace zsh)
    '';
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 6;

  system.defaults = {
    dock.autohide = true;
    dock.mru-spaces = false;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    loginwindow.LoginwindowText = "Managed by areto and Flatballer";
    screencapture.location = "~/Pictures/screenshots";
    screensaver.askForPasswordDelay = 10;
  };

  # aarch64-linux remote builder for cross-compilation.
  # Start the VM manually (once): nix run nixpkgs#darwin.linux-builder
  # It listens on localhost:31022 and auto-configures SSH access.
  nix.distributedBuilds = true;
  nix.buildMachines = [
    {
      hostName = "linux-builder";
      system = "aarch64-linux";
      maxJobs = 4;
      speedFactor = 2;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      sshUser = "builder";
      sshKey = "/etc/nix/builder_ed25519";
    }
  ];
}
