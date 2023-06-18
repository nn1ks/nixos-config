{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.logiops;
in {
  options.services.logiops = {
    enable = mkEnableOption "logiops service";
    extraConfig = mkOption {
      type = types.str;
      default = "";
    };
  };

  config = mkIf cfg.enable (
    let
      configFile = pkgs.writeText "logid.cfg" cfg.extraConfig;
    in {
      systemd.services.logiops = {
        description = "Logiops service";
        wantedBy = [ "multi-user.target" ];
        restartIfChanged = true;
        serviceConfig.ExecStart = "${pkgs.logiops}/bin/logid --verbose --config ${configFile}";
      };
    }
  );
}
