{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.mautrix-whatsapp;
  dataDir = "/var/lib/mautrix-whatsapp";
  settingsFormat = pkgs.formats.yaml {};
in {
  options.services.mautrix-whatsapp = {
    enable = mkEnableOption "mautrix-whatsapp service";
    package = mkOption {
      type = types.package;
      default = pkgs.mautrix-whatsapp;
      description = "The package used for the mautrix-whatsapp binary";
    };
    settings = mkOption {
      default = {};
      description = "The configuration of mautrix-whatsapp";
      type = types.submodule {
        freeformType = settingsFormat.type;
      };
    };
  };

  config = mkIf cfg.enable (
    let
      yamlConfig = generators.toYAML { } cfg.settings;
      configFile = pkgs.writeText "config.yaml" yamlConfig;
    in {
      environment.systemPackages = [ cfg.package ];
      systemd.services.mautrix-whatsapp = {
        description = "mautrix-whatsapp bridge";
        wantedBy = [ "multi-user.target" ];
        restartIfChanged = true;
        serviceConfig.ExecStartPre = [
          "${pkgs.coreutils}/bin/mkdir -p ${dataDir}"
          "${pkgs.coreutils}/bin/cp ${configFile} ${dataDir}/config.yaml"
        ];
        serviceConfig.ExecStart = "${cfg.package}/bin/mautrix-whatsapp --config ${dataDir}/config.yaml";
      };
    }
  );
}
