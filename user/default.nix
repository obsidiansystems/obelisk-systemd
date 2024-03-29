{ config, lib, ... }:
with lib;
let 
  cfg = config;
  obs = cfg.obelisks;
  obeliskSubmodule = import ../common { inherit lib; };
in
{ options.obelisks = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule obeliskSubmodule);
    default = {};
    example = lib.literalExpression ''
      obelisks."myapp" = {
        obelisk = (import /path/to/myapp {}).exe;
        configSource = "/path/to/config";
        port = 8080;
      };
    '';
    description = "An attrset of obelisk applications to run as user systemd services.";
  };

  # Configure user systemd services for each obelisk
  config.systemd.user.services = lib.mapAttrs (k: v: {
    Unit.Description = "${k} obelisk application";
    Service.Type = "simple";
    Service.Restart = "always";
    Service.ExecStart = "%S/${k}/backend --port=${builtins.toString v.port}";
    Service.KillMode = "control-group";
    Service.WorkingDirectory = "%S/${k}";
  }) obs;


  # "Deploy" the application executables and create folders in $XDG_CONFIG_HOME
  # for the obelisks. This is where config files, symlinks to executables, and
  # symlinks to static assets, will be stored.
  config.home.activation = lib.mapAttrs'
    (k: v: {
      name = "obelisk-activation-${k}";
      value = config.lib.dag.entryAfter ["writeBoundary"] ''
        ln -sfr ${v.obelisk}/* $XDG_CONFIG_HOME/${k}/
        ln -sfr ${v.configSource} $XDG_CONFIG_HOME/${k}/config
      '';
    }) obs;
}
