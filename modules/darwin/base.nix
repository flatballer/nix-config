{ inputs, self, pkgs, lib, ... }:
{
  imports = [ ../common.nix ];

  nix.enable = false;
  nix.settings.experimental-features = "nix-command flakes";
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  # Darwin-only packages
  environment.systemPackages = with pkgs; [
    fzf-zsh-plugin
    zsh-fzf-tab
    carapace-bridge
  ];

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

  # Uncomment and configure to enable cross-building aarch64-linux/x86_64-linux
  # from this Mac. The Pi itself can serve as an aarch64-linux builder once
  # provisioned. You may also use a Linux VM or cloud instance.
  #
  # nix.distributedBuilds = true;
  # nix.buildMachines = [
  #   {
  #     hostName = "builder.local";       # or IP / SSH alias
  #     system = "aarch64-linux";
  #     maxJobs = 4;
  #     speedFactor = 2;
  #     supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
  #     sshUser = "nix-build";
  #     sshKey = "/etc/nix/builder_key";
  #   }
  #   {
  #     hostName = "builder-x86.local";
  #     system = "x86_64-linux";
  #     maxJobs = 4;
  #     speedFactor = 2;
  #     supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
  #     sshUser = "nix-build";
  #     sshKey = "/etc/nix/builder_key";
  #   }
  # ];
}
