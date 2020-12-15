# obelisk-systemd

Define systemd services for obelisk applications.

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
{ config, lib, ... }:

imports = [
  (import ./obelisk-systemd { inherit config lib; }).user
];

obelisks."lithograph" = {
  obelisk = (import ./lithograph {}).exe;
  configSource = ./config;
  port = 8080;
};
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
{ config, lib, ... }:

imports = [
  (import /obelisk-systemd { inherit config, lib; }).system;
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
```
