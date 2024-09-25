{ config, pkgs, inputs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    zsh
    fzf
    bat
    ripgrep
    htop
    sops
    sqlite
    fd
    inputs.actual-nix.packages."${pkgs.system}".actual-server
    tailscale
  ];
  
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/nixos/.config/sops/age/keys.txt";
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.secrets.tailscale-auth-key = { };
  services.tailscale.enable = true;
  users.defaultUserShell = pkgs.zsh;

  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "fzf" ];
    };
    shellInit = ''
      [ -f ${pkgs.fzf}/etc/profile.d/fzf.sh ] && source ${pkgs.fzf}/etc/profile.d/fzf.sh
      export PROMPT="%n@%m %1~ %# "
    '';
  };

  users.users.nixos = {
    isNormalUser = true;
    shell = pkgs.zsh;
  };

  services.actual = {
    enable = true;
    hostname = "127.0.0.1";
    port = 5006;
  };

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

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
    allowedTCPPorts = [ 22 443 ];
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/actual 0755 actual actual"
    "d /etc/ssl/tailscale 0755 root root"
    "f /etc/ssl/tailscale/key.pem 0640 root ssl-cert - -"
    "f /etc/ssl/tailscale/cert.pem 0644 root root - -"
  ];

  users.groups.ssl-cert = { };

  users.users.nginx = {
    isSystemUser = true;
    extraGroups = [ "ssl-cert" ];  
  };

  systemd.services.tailscale-cert = {
    description = "Obtain TLS certificate from Tailscale";
    after = [ "network-online.target" "tailscale.service" ];
    wants = [ "network-online.target" "tailscale.service" ];
    before = [ "nginx.service" ];  # Ensure this runs before nginx
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

  systemd.timers.tailscale-cert-renewal = {
    description = "Renew Tailscale TLS certificate";
    wantedBy = [ "timers.target" ];
    timerConfig.OnCalendar = "weekly";
    timerConfig.Persistent = true;
  };

  services.nginx = {
    enable = true;
    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;

    virtualHosts."actual" = {
      onlySSL = true;
      sslCertificate = "/etc/ssl/tailscale/cert.pem";
      sslCertificateKey = "/etc/ssl/tailscale/key.pem";
      serverName = "nixos.tailcf19f1.ts.net";
      extraConfig = ''
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
      '';
      locations."/user-1/" = {
        proxyPass = "http://127.0.0.1:5006";
        proxyWebsockets = true;
        extraConfig = ''
          rewrite ^/user-1/(.*) /$1 break;
        '';
      };

      locations."/user-2/" = {
        proxyPass = "http://127.0.0.1:5007";
        proxyWebsockets = true;
        extraConfig = ''
          rewrite ^/user-2/(.*) /$1 break;
        '';
      };
    };
  };
}




