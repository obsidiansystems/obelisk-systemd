# obelisk-systemd
[![Built with Nix](https://img.shields.io/static/v1?logo=nixos&logoColor=white&label=&message=Built%20with%20Nix&color=41439a)](https://nixos.org) [![Obelisk](https://img.shields.io/badge/Powered%20By-Obelisk-black?style=flat&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAA4AAAAOCAMAAAAolt3jAAAAXVBMVEUAAAAAAP+AgIAaGhoKCgoJCQkQEBQPEhIVGhwbHSMcHiMcHiUdISclKTEpLzYsMTstMjsvNT4vNT8vNj80PUc6R1M8S1dIXWxVcoRhhZljiZ1jip5pk6lum7FwnrUhj9JFAAAAEHRSTlMAAQIKGR5ARm2MkJCcx+b4Muz3FwAAAGxJREFUCB0FwQlqxDAQADBlnMvQ/v+dhYA3rD1TaUP0fYs1R9K4ftr29N/ryKW5OjXOM8621h4dRW16fuOGYuG+44Ci0I7YYFLQAiQFoqBIWDEhWVgzBiSFz4gcKDCe3L06mO/z2nm/F+pvJP9dpDX3DsTigAAAAABJRU5ErkJggg==)](https://github.com/obsidiansystems/obelisk)

Define systemd services for obelisk applications.


* [User-level systemd service via home-manager](#user-level-systemd-service-via-home-manager)
  * [Example configuration](#example-configuration)
    * [Fetch sources](#fetch-sources)
    * [Configure obelisk app](#configure-obelisk-app)
    * [home-manager configuration](#home-manager-configuration)
    * [Activate](#activate)
* [System-level systemd service via NixOS](#system-level-systemd-service-via-nixos)
  * [Example configuration](#example-configuration-1)
    * [Fetch sources](#fetch-sources-1)
    * [Configure obelisk app](#configure-obelisk-app-1)
    * [NixOS Configuration](#nixos-configuration)

## User-level systemd service via home-manager

The [user](user) module defines a user-level systemd service that can be imported into a [home-manager](https://github.com/nix-community/home-manager/blob/master/README.md) configuration.

### Example configuration

#### Fetch sources
To get started, clone this repo and your obelisk application into your home-manager configuration folder. We recommend using [nix-thunk](https://github.com/obsidiansystems/nix-thunk) to pack the obelisk application source, but this is optional.


```bash
cd ~/.config/nixpkgs

git clone git@github.com:obsidiansystems/obelisk-systemd
nix-thunk pack obelisk-systemd

git clone git@gitlab.com:obsidian.systems/lithograph
nix-thunk pack lithograph
```

#### Configure obelisk app

You'll also need to create the config folder for your project. Our example project, lithograph, requires a config folder that looks like the following:

```
config
├── backend
│   └── clientSessionKey
└── common
    └── route
```

Configuration is very app-specific, so consult your application's documentation to see what sort of configuration you need to provide. There's usually a development config available in the application repo, which might be useful as a starting point.

We'll use the following commands to create the config:

```bash
mkdir -p config/backend
mkdir -p config/common
dd if=/dev/urandom bs=96 count=1 of=config/backend/clientSessionKey
echo "http://localhost:8080" > config/common/route
```

#### home-manager configuration

Now in `home.nix` you can import the user systemd module and specify your app configuration. See [common/default.nix](common/default.nix) and [user/default.nix](user/default.nix) for an explanation of the options:

```nix
{ config, lib, pkgs, ... }:

{
  imports = [
    (import ./obelisk-systemd { inherit config lib; }).user
  ];

  obelisks."lithograph" = {
    obelisk = (import ./lithograph {}).exe;
    configSource = ./config;
    port = 8080;
  };
}
```

#### Activate

Running `home-manager switch` should activate this service.

You can inspect the running service using `systemctl`. For example:

```bash
systemctl status --user lithograph
```

## System-level systemd service via NixOS

The [system](system) module defines a system-level systemd service that can be imported into a [NixOS](https://nixos.org/nixos) configuration.

### Example configuration

#### Fetch sources
Clone this repository and your obelisk application into your nixos configuration folder (usually `/etc/nixos/`).

```bash
cd /etc/nixos
git clone git@github.com:obsidiansystems/obelisk-systemd
git clone git@gitlab.com:obsidian.systems/lithograph
```

#### Configure obelisk app

Create a configuration folder for your application. For example:

```bash
mkdir -p config/backend
mkdir -p config/common
dd if=/dev/urandom bs=96 count=1 of=config/backend/clientSessionKey
echo "https://lithograph.example.com" > config/common/route
```

#### NixOS Configuration

Now in your `configuration.nix`, you can import the system systemd module and specify your app configuration. See [common/default.nix](common/default.nix) and [system/default.nix](system/default.nix) for an explanation of the options:

```nix
{ config, lib, pkgs, ... }:

{
  imports = [
    (import /obelisk-systemd { inherit config lib; }).system
  ];

  obelisks."lithograph" = {
    obelisk = (import ./lithograph {}).exe;
    configSoruce = ./config;
    port = 8080;
    enableNginxReverseProxy = true;
    enableHttps = true;
    virtualHostName = "lithograph.example.com";
    acmeCertAdminEmail = "admin@example.com";
  };
}
```
