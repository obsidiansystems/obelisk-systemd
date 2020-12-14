{ config, lib, ... }:
{ user = import ./user { inherit config lib; }; }
