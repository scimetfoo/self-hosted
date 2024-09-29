{ config, pkgs, ... }:

{
  services.tailscale.enable = true;

  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";
    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = with pkgs; ''
      sleep 2

      # check if already authenticated to tailscale
      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi

      # otherwise authenticate with tailscale
      ${tailscale}/bin/tailscale up -authkey ${config.sops.secrets.tailscale-auth-key.path}
    '';
  };

  systemd.services.tailscale-cert = {
    description = "Obtain TLS certificate from Tailscale";
    after = [ "network-online.target" "tailscale.service" ];
    wants = [ "network-online.target" "tailscale.service" ];
    before = [ "nginx.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = ''
        ${pkgs.tailscale}/bin/tailscale cert \
          --cert-file /etc/ssl/tailscale/cert.pem \
          --key-file /etc/ssl/tailscale/key.pem \
          nixos.tailcf19f1.ts.net
      '';
    };
    wantedBy = [ "multi-user.target" ];
  };
}
