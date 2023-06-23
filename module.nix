{ config, pkgs, lib, ... }: with lib; with lib.types; 
let
  cfg = config.services.misskey;
in
{
  options.services.misskey = {
    enable = mkEnableOption "Misskey service";
    package = mkOption {
      type = package;
      description = "The Misskey package used by the service.";
      default = pkgs.misskey;
    };
    config.directory = mkOption {
      type = path;
      description = "The directory contains Misskey configuration files.";
      default = "/etc/misskey";
    };
    config.file = mkOption {
      type = str;
      description = "The file name of the Misskey configuration file to use.";
      default = "default.yml";
    };
    data.directory = mkOption {
      type = path;
      description = "The directory used to store Misskey files.";
      default = "/var/lib/misskey";
    };
  };
  config = mkIf cfg.enable {
    users.users.misskey = {
      isSystemUser = true;
      group = config.users.groups.misskey.name;
    };
    users.groups.misskey = {};
    systemd.services.misskey = with pkgs; {
      path = [ nodejs nodejs.pkgs.pnpm bash ];
      preStart = "pnpm run migrate";
      script = "pnpm run start";
      environment = {
        NODE_ENV = "production";
        MISSKEY_CONFIG_DIR = cfg.config.directory;
        MISSKEY_CONFIG_YML = cfg.config.file;
        MISSKEY_FILES_DIR = cfg.data.directory;
      };
      wantedBy = [ "multi-user.target" ];   
      serviceConfig = {
        User = config.users.users.misskey.name;
        Group = config.users.groups.misskey.name;
        WorkingDirectory = cfg.package;
        StateDirectory = "misskey";
        Restart = "always";
      };
    };
  };
}
