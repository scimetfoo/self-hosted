{ config, pkgs, ... }:

{
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/nixos/.config/sops/age/keys.txt";
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.secrets.tailscale-auth-key = { };
}

