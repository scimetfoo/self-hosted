{ config, pkgs, lib, ... }:
{
 config = {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "server";
      extraUpFlags = [
      ];
    };

    systemd.services.tailscaled = {
      after = [ "technitium-dns-server.service" ];
      requires = [ "technitium-dns-server.service" ];
    };

    systemd.services.tailscale-autoconnect = {
      description = "Automatic connection to Tailscale";
      after = [ "network-pre.target" "tailscale.service" "technitium-dns-server.service" ];
      wants = [ "network-pre.target" "tailscale.service" "technitium-dns-server.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = with pkgs; ''
        sleep 2
        status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
        if [ $status = "Running" ]; then exit 0; fi
        ${pkgs.tailscale}/bin/tailscale up \
          --auth-key file:${config.sops.secrets.tailscale-auth-key.path} \
          --hostname=nixos \
          --advertise-routes=100.65.47.114/32 \
        ${pkgs.tailscale}/bin/tailscale set \
          --dns=100.65.47.114 \
          --search-domain=murtazaa.com
      '';
    };

    networking = {
      nameservers = [ "127.0.0.1" "1.1.1.1" ];
      dhcpcd.extraConfig = "nohook resolv.conf";
      resolvconf.enable = false;
    };

    environment.etc."resolv.conf".text = ''
      nameserver 127.0.0.1
      nameserver 1.1.1.1
    '';
  };
}
