# Release history of obelisk-systemd

## v0.2.1.0

* Change systemd [KillMode](https://www.freedesktop.org/software/systemd/man/systemd.kill.html#KillMode=) to "control-group" so that child processes are terminated when the unit is stopped or restarted

## v0.2.0.1

* Add module docs
* Add test to verify that configs could be read

## v0.2.0.0

* Keep configs out of the nix store
* system: Make username and home directory configurable
* system: default to nginx and https off

## v0.1.0.0

* Provide a user-level systemd service via home-manager.
* Provide a system-level systemd service via NixOS.

