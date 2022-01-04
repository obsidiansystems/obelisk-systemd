{ config, lib, pkgs, ... }:
let inherit (import ./nix-thunk {}) thunkSource;
in
{
  imports = [
    (import ../. { inherit config lib pkgs; }).system
  ];
  obelisks."skeleton" = {
    obelisk = (import (thunkSource ./obelisk + "/skeleton") {}).exe;
    configSource = "${./config}";
    port = 8080;
    enableNginxReverseProxy = true;
    enableHttps = false;
    virtualHostName = "skeleton.localhost";
    acmeCertAdminEmail = "admin@example.com";
  };
  users.extraUsers.root.initialPassword = "asdf";
}
