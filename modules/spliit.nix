{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.spliit;
in {
  options.services.spliit = {
    enable = mkEnableOption "Spliit service";
  };

  config = { 
    systemd.services.spliit-setup = {
      description = "Setup Spliit";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      path = with pkgs; [ git nodejs-18_x docker docker-compose bash coreutils ];
      script = ''
        #!${pkgs.bash}/bin/bash
        set -euxo pipefail

        echo "Setting up Spliit..."

        # Ensure the directory exists and set permissions
        mkdir -p /opt/spliit
        chown -R root:root /opt/spliit

        # Add /opt/spliit to Git's safe.directory
        ${pkgs.git}/bin/git config --global --add safe.directory /opt/spliit

        # Clone or update repository
        if [ ! -d "/opt/spliit/.git" ]; then
          echo "Cloning Spliit repository..."
          ${pkgs.git}/bin/git clone https://github.com/spliit-app/spliit.git /opt/spliit
        else
          echo "Updating Spliit repository..."
          cd /opt/spliit && ${pkgs.git}/bin/git pull
        fi
        cd /opt/spliit

        echo "Preparing environment file..."
        cp container.env.example container.env

        echo "Debugging: Checking script content"
        cat scripts/build-image.sh

        echo "Building Docker image..."
        ${pkgs.bash}/bin/bash ./scripts/build-image.sh

        echo "Starting containers..."
        ${pkgs.docker-compose}/bin/docker-compose up -d

        echo "Spliit setup completed successfully."
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "root";
        Group = "root";
        WorkingDirectory = "/opt/spliit";
      };
    };
  };
}
