{ lib, ... }:
{ options = {
    obelisk = lib.mkOption {
      type = lib.types.package;
      description = "The derivation containing the obelisk application that forms the basis of this service. This is usually the 'exe' attribute of the obelisk app.";
      example = "(import /path/to/obeliskapp {}).exe";
    };
    configSource = lib.mkOption {
      type = lib.types.str;
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
}
