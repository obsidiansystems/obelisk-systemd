{ pkgs ? import ./test/nixpkgs {} }:
pkgs.lib.recurseIntoAttrs
  { test = import ./test {};
    docs = import ./gen-docs.nix { inherit pkgs; };
  }
