{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.maubot;
in {
  options.services.maubot = {
    enable = mkEnableOption "maubot service";
    package = mkOption {
      type = types.package;
      description = "The package used for maubot binary";
    };
    settings = mkOption {
      default = {};
      description = "The configuration of maubot";
      type = with types; submodule {
        options = {
          server.hostname = mkOption {
            type = types.str;
          };
          server.port = mkOption {
            type = types.ints.unsigned;
          };
          server.public_url = mkOption {
            type = types.str;
          };
          server.unshared_secret = mkOption {
            type = types.str;
          };
          admins = mkOption {
            type = types.attrsOf types.str;
          };
          homeservers = mkOption {
            type = types.attrs;
          };
        };
      };
    };
  };

  config = mkIf cfg.enable (
    let
      libDir = "/var/lib/maubot";
      pluginsDir = "${libDir}/plugins";
      trashDir = "${libDir}/trash";
      yamlConfig = generators.toYAML { } {
        server = {
          hostname = cfg.settings.server.hostname;
          port = cfg.settings.server.port;
          public_url = cfg.settings.server.public_url;
          unshared_secret = cfg.settings.server.unshared_secret;
        };
        admins = cfg.settings.admins;
        homeservers = cfg.settings.homeservers;
        database = "sqlite://${libDir}/database";
        crypto_database = "default";
        plugin_directories = {
          upload = "${pluginsDir}";
          load = [ "${pluginsDir}" ];
          trash = "${trashDir}";
        };
        plugin_database.sqlite = "${pluginsDir}";
      };
      configFile = pkgs.writeText "config.yaml" yamlConfig;
    in {
      environment.systemPackages = [ cfg.package ];
      systemd.services.maubot = {
        description = "Maubot service";
        wantedBy = [ "multi-user.target" ];
        restartIfChanged = true;
        serviceConfig.ExecStartPre = [
          "${pkgs.coreutils}/bin/mkdir -p ${pluginsDir}"
          "${pkgs.coreutils}/bin/mkdir -p ${trashDir}"
        ];
        serviceConfig.ExecStart = "${cfg.package}/bin/maubot --config ${configFile}";
      };
    }
  );
}
