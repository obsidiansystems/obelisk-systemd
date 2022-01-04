# Generates documentation markdown file for the options defined in
# `system/default.nix` and `user/default.nix`.
# This can be used to generate a new `module-options.md` by running
# `cat $(nix-build gen-docs.nix) > module-options.md`
{ pkgs ? import ./test/nixpkgs {} }:
let system = (import ./docs.nix { inherit pkgs; }).md;
    user = (import ./docs.nix { inherit pkgs; module = import ./user { config = {}; lib = pkgs.lib; }; }).md;
    doc = pkgs.writeText "obelisk-systemd-options.md" ''
      # Module options

      ## System-level systemd service

      ${system}

      ## User-level systemd service

      ${user}
    '';
in doc
