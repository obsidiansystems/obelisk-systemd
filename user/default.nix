{ config, pkgs, lib, ... }:
with lib;
let 
  cfg = config;
  obs = cfg.obelisks;
in
  let obeliskSubmodule =
      { options = {
          obelisk = lib.mkOption {
            type = lib.types.package;
            description = "The derivation containing the obelisk application that forms the basis of this service.";
          };
          configSource = lib.mkOption {
            type = lib.types.path;
            example = "/path/to/obelisk-app/config";
            description = ''
              The path to the obelisk application configuration folder. Configs will be copied from this folder every time the configuration is rebuilt. See <link xlink:heref="https://github.com/obsidiansystems/obelisk/tree/master/skeleton/config#config"> for more information.
            '';
          };
          port = lib.mkOption {
            type = lib.types.port;
            default = 8080;
            example = 8080;
            description = "The port this service should listen on.";
          };
        };
      };
in
{ options.obelisks = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule obeliskSubmodule);
    default = {};
  };
  # Create folders in $XDG_CONFIG_HOME for the obelisks. This is where config
  # files, symlinks to executables, and symlinks to static assets, will be stored.
  config.xdg.configFile =
    lib.mapAttrs'
      (k: v: {
        name = "${k}/config";
        value = {
          source = v.configSource;
        };
      }) obs;
  # Configure user systemd services for each obelisk
  config.systemd.user.services = lib.mapAttrs (k: v: {
    Unit.Description = "${k} obelisk application";
    Service.Type = "simple";
    Service.Restart = "always";
    Service.ExecStart = "$XDG_CONFIG_HOME/${k}/backend --port=${builtins.toString v.port}";
    Service.WorkingDirectory = "$XDG_CONFIG_HOME/${k}";
  }) obs;
  # "Deploy" the application executables
  config.home.activation = lib.mapAttrs'
    (k: v: {
      name = "obelisk-activation-${k}";
      value = config.lib.dag.entryAfter ["writeBoundary"] ''
        ln -sfr ${v.obelisk}/* $XDG_CONFIG_HOME/${k}/
      '';
    }) obs;
}
