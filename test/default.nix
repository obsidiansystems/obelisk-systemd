let inherit (import ./nix-thunk {}) thunkSource;
in
import (thunkSource ./nixpkgs + "/nixos/tests/make-test-python.nix") ({ pkgs, ... } :
{ skipLink = true;
  machine = {
    imports = [
      ./configuration.nix
    ];
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("default.target")
    machine.wait_for_unit("skeleton")
    machine.execute('logger -t TEST "#1 Verifying that server is running..."')
    machine.succeed("curl localhost:8080")
    machine.execute('logger -t TEST "#1 Verified!"')
  '';
})
