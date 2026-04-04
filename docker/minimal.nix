# Docker minimal image: bare shell + coreutils.
# Intended as a base for service deployments — add your app on top.
# Build:  nix build .#packages.x86_64-linux.dockerMinimal
# Load:   docker load < result
{ pkgs }:
pkgs.dockerTools.streamLayeredImage {
  name = "minimal-env";
  tag = "latest";
  contents = with pkgs; [
    bashInteractive
    coreutils
    cacert
  ];
  config = {
    Cmd = [ "${pkgs.bashInteractive}/bin/bash" ];
    Env = [
      "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
  };
}
