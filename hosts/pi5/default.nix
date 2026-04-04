{ inputs, nixos-hardware, pkgs, ... }:
{
  imports = [
    ../../modules/nixos/base.nix
    nixos-hardware.nixosModules.raspberry-pi-5
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];

  networking.hostName = "pi5";

  users.users.thomas = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      # "ssh-ed25519 AAAA... you@host"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.05";
}
