{ config, pkgs, ... }:

{
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      actual-1 = {
        image = "actualbudget/actual-server:24.12.0-alpine";
        ports = [ "5006:5006" ];
        volumes = [ "/var/lib/actual-1:/data" ];
        environment = {
          DEBUG = "actual:*";
          LOG_LEVEL = "debug";
        };
      };
      actual-2 = {
        image = "actualbudget/actual-server:24.12.0-alpine";
        ports = [ "5007:5006" ];
        volumes = [ "/var/lib/actual-2:/data"];
        environment = {
          DEBUG = "actual:*";
          LOG_LEVEL = "debug";
        };
      };
    };
  };
}
