{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./disko-config.nix
    ];

  sops.defaultSopsFile = ../secrets/secrets.yaml;
  sops.secrets.nixos-password.neededForUsers = true;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/nixos/.config/sops/age/keys.txt";
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  sops.secrets.nixos-password = { };

  # File systems configuration.
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-partlabel/disk-main-root";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-partlabel/disk-main-ESP";
      fsType = "vfat";
    };
  };

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";  
    efiSupport = true;
    efiInstallAsRemovable = true; 
    useOSProber = true; 
  }; 

  services.openssh.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users.nixos = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    initialHashedPassword = config.sops.secrets.nixos-password.path;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    configure = {
      customRC = ''
        colorscheme habamax
      '';

      packages.packages = {
        start = [
          pkgs.vimPlugins.nerdtree
        ];
      };
    };
  };

  system.stateVersion = "24.05";

}
