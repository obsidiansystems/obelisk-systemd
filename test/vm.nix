let inherit (import ./nix-thunk {}) thunkSource;
in (import (thunkSource ./nixpkgs + "/nixos") { configuration = ./configuration.nix; }).vm
