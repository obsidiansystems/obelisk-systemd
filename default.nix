{ config, lib, pkgs, ... }:
{ user = import ./user { inherit config lib; };
  system = import ./system { inherit config lib pkgs; };
}
