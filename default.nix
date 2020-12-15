{ config, lib, ... }:
{ user = import ./user { inherit config lib; };
  system = improt ./system { inherit config lib; };
}
