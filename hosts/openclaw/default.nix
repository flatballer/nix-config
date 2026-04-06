{ inputs, nixos-hardware, pkgs, ... }:
{
  imports = [
    ../../modules/nixos/base.nix
    nixos-hardware.nixosModules.raspberry-pi-5
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];

  networking.hostName = "openclaw";

  users.users.tommy = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHHO8OZZE3qf8uQIO0j1Q4/hB1w2nW7c/YmgO0y5cSee thomasmargraf@tma-m4.bat-degree.ts.net"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  # Headless — no desktop environment or display manager
  services.xserver.enable = false;
  systemd.defaultUnit = "multi-user.target";

  system.stateVersion = "25.05";
}
