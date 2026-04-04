{ inputs, nixos-hardware, pkgs, ... }:
{
  imports = [
    ../../modules/nixos/base.nix
    nixos-hardware.nixosModules.raspberry-pi-4
    # Produces config.system.build.sdImage (build with:
    #   nix build .#nixosConfigurations.pi4.config.system.build.sdImage)
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];

  networking.hostName = "pi4";

  # Set your username and add your SSH public key here
  users.users.thomas = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      # "ssh-ed25519 AAAA... you@host"
    ];
  };

  # Allow passwordless sudo for wheel
  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.05";
}
