{ inputs, nixos-hardware, pkgs, lib, ... }:
{
  imports = [
    ../../modules/nixos/base.nix
    nixos-hardware.nixosModules.raspberry-pi-4
    "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
  ];

  networking.hostName = "openclaw";

  # ── Networking: systemd-networkd + iwd ──────────────────────────────────
  # Modern stack: iwd handles WiFi association, networkd handles DHCP/addressing.
  # Eliminates dhcpcd and wpa_supplicant entirely.
  #
  # WiFi credentials: after flashing, create the iwd profile on the root partition:
  #   mkdir -p /var/lib/iwd
  #   printf '[Security]\nPassphrase=<your-passphrase>\n' > /var/lib/iwd/dahoam.psk
  #   chmod 600 /var/lib/iwd/dahoam.psk
  networking.useNetworkd = true;

  networking.wireless.iwd = {
    enable = true;
    # Let systemd-networkd handle DHCP; iwd only manages association.
    settings.General.EnableNetworkConfiguration = false;
  };

  systemd.network.networks = {
    "10-eth" = {
      matchConfig.Name = "eth*";
      networkConfig.DHCP = "ipv4";
    };
    "20-wlan" = {
      matchConfig.Name = "wlan*";
      networkConfig.DHCP = "ipv4";
    };
  };

  environment.systemPackages = [ pkgs.nodejs ];

  users.users.schraube = {
    isNormalUser = true;
  };

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

  # nixos-hardware rpi4 adds modules (e.g. dw-hdmi) not present in the RPi kernel
  boot.initrd.allowMissingModules = true;

  # ── Tailscale ────────────────────────────────────────────────────────────
  # On first boot, auto-joins the tailnet using a pre-auth key stored in
  # /etc/secrets/tailscale-authkey (written to the SD card after flashing).
  #   echo '<your-authkey>' > /etc/secrets/tailscale-authkey
  #   chmod 600 /etc/secrets/tailscale-authkey
  services.tailscale.enable = true;

  systemd.services.tailscale-autoconnect = {
    description = "Automatic Tailscale connection on first boot";
    after = [ "network-online.target" "tailscale.service" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      state=$(${pkgs.tailscale}/bin/tailscale status --json 2>/dev/null \
        | ${pkgs.jq}/bin/jq -r '.BackendState // "unknown"')
      if [ "$state" = "Running" ]; then
        echo "Tailscale already connected — skipping."
        exit 0
      fi
      authkey=$(cat /etc/secrets/tailscale-authkey)
      ${pkgs.tailscale}/bin/tailscale up --authkey "$authkey"
    '';
  };

  system.stateVersion = "25.05";
}
