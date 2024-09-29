{ config, pkgs, inputs, ... }:

{
  imports = [
    ./packages.nix
    ./users.nix
    ./zsh.nix
    ./docker.nix
    ./sops.nix
    ./tailscale.nix
    ./nginx.nix
    ./actual.nix
  ];

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
    allowedTCPPorts = [ 22 443 ];
  };

  systemd.tmpfiles.rules = [
    "d /etc/ssl/tailscale 0755 root root"
    "f /etc/ssl/tailscale/key.pem 0640 root ssl-cert - -"
    "f /etc/ssl/tailscale/cert.pem 0644 root root - -"
    "d /var/www/actual 0755 nginx nginx"
  ];

  users.groups.ssl-cert = { };
}

