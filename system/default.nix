{ config, lib, pkgs, ... }:
with lib;
let cfg = config;
    httpsObelisks = lib.filterAttrs (_: v: v.enableHttps) cfg.obelisks;
    commonSubmodule = import ../common { inherit lib; };
    obeliskSubmodule = {
      options = commonSubmodule.options // {
        virtualHostName = lib.mkOption {
          type = types.str;
          description = ''
            The nginx vhost name for the application. See
            services.nginx.virtualHosts in the NixOS manual for more
            information.
          '';
          example = "app.example.com";
        };
        acmeCertAdminEmail = lib.mkOption {
          type = types.str;
          description = ''
            Contact email address for the CA to be able to reach you. See
            security.acme.certs in the NiOS manual.
          '';
          example = "admin@example.com";
        };
        enableNginxReverseProxy = lib.mkOption {
          type = types.bool;
          description = ''
            Enable nginx reverse proxy.
          '';
          default = false;
        };
        enableHttps = lib.mkOption {
          type = types.bool;
          description = ''
            Enable HTTPS via Let's Encrypt.
          '';
          default = false;
        };
        baseUrl = lib.mkOption {
          type = types.str;
          default = "/";
        };
        extraBackendArgs = lib.mkOption {
          type = types.str;
          default = "";
        };
      };
    };
in
{
  options.obelisks = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule obeliskSubmodule);
    default = {};
  };

  # Configure nginx reverse proxy (with Let's Encrypt, if HTTPS is enabled)
  config.services.nginx = {
    enable = lib.any (v: v.enableNginxReverseProxy) (lib.attrValues cfg.obelisks);
    recommendedProxySettings = true;
    virtualHosts = lib.mapAttrs' (k: v: {
      name = v.virtualHostName;
      value = {
        enableACME = v.enableHttps;
        forceSSL = v.enableHttps;
        locations.${v.baseUrl} = {
          proxyPass = "http://127.0.0.1:" + toString v.port;
          proxyWebsockets = true;
          extraConfig = ''
            access_log off;
          '';
        };
      };
    }) (lib.filterAttrs (_: v: v.enableNginxReverseProxy) cfg.obelisks);
  };

  # Open firewall ports for server traffic
  config.networking.firewall.allowedTCPPorts = if lib.length (lib.attrValues httpsObelisks) > 0
    then [ 80 443 ]
    else [ 80 ];

  # If using Let's Encrypt, we must provide an admin contact email address
  config.security.acme.certs = lib.mapAttrs' (_: v: {
    name = "${v.virtualHostName}";
    value = { email = v.acmeCertAdminEmail; };
  }) httpsObelisks;

  # Configure the systemd service for each application
  config.systemd.services = lib.mapAttrs (name: v: {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    restartIfChanged = true;
    path = [ pkgs.gnutar ];
    script = ''
      ln -sft . '${v.obelisk}'/*
      mkdir -p log
      exec ./backend --port=${toString v.port} ${v.extraBackendArgs} < /dev/null
    '';
    serviceConfig = {
      User = name;
      KillMode = "process";
      WorkingDirectory = "~";
      Restart = "always";
      RestartSec = 5;
    };
  }) cfg.obelisks;

  # Configure a separate user for each application
  config.users.users = lib.mapAttrs (name: v: {
    description = "${name} service";
    home = "/var/lib/${name}";
    createHome = true;
    isSystemUser = true;
    group = name;
  }) cfg.obelisks;
  # Configure a separate group for each application
  config.users.groups = lib.mapAttrs (_: _: {
  }) cfg.obelisks;
}
