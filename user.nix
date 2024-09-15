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

  systemd.tmpfiles.rules = [
    "d /var/lib/actual 0755 actual actual"
  ];

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

}

