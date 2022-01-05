# Module options

## System-level systemd service

### `obelisks :: attribute set of submodules`

Description: An attribute set of obelisk applications to be managed by systemd.


Default: `{}`

Example: 
```
obelisks."myapp" = {
  obelisk = (import /path/to/myapp {}).exe;
  configSource = "/path/to/config";
  port = 8080;
};

```


### `obelisks.<name>.acmeCertAdminEmail :: string`

Description: Contact email address for the CA to be able to reach you. See
security.acme.certs in the NixOS manual.




Example: `"admin@example.com"`



### `obelisks.<name>.baseUrl :: string`

Description: Specified the base url path at which the application will be served.


Default: `"/"`





### `obelisks.<name>.configSource :: string`

Description: The path to the obelisk application configuration folder. Configs will be copied from this folder every time the configuration is rebuilt. See <link xlink:heref="https://github.com/obsidiansystems/obelisk/tree/master/skeleton/config#config"> for more information.




Example: `"/path/to/obelisk-app/config"`



### `obelisks.<name>.enableHttps :: boolean`

Description: Enable HTTPS via Let's Encrypt.


Default: `false`





### `obelisks.<name>.enableNginxReverseProxy :: boolean`

Description: Enable nginx reverse proxy.


Default: `false`





### `obelisks.<name>.extraBackendArgs :: string`

Description: Additional arguments passed verbatim to the backend executable.


Default: `""`





### `obelisks.<name>.obelisk :: package`

Description: The derivation containing the obelisk application that forms the basis of this service. This is usually the 'exe' attribute of the obelisk app.



Example: `"(import /path/to/obeliskapp {}).exe"`



### `obelisks.<name>.port :: 16 bit unsigned integer; between 0 and 65535 (both inclusive)`

Description: The port this service should listen on.

Default: `8080`

Example: `8080`



### `obelisks.<name>.userHome :: null or string`

Description: The home directory for the user that will run the service. Defaults to /var/lib/name-of-obelisk




Example: `"/var/lib/example"`



### `obelisks.<name>.userName :: null or string`

Description: The name of the user that will run the service. This user will be created. Defaults to the name of the obelisk.








### `obelisks.<name>.virtualHostName :: string`

Description: The nginx vhost name for the application. See
services.nginx.virtualHosts in the NixOS manual for more
information.




Example: `"app.example.com"`





## User-level systemd service

### `obelisks :: attribute set of submodules`

Description: An attrset of obelisk applications to run as user systemd services.

Default: `{}`

Example: 
```
obelisks."myapp" = {
  obelisk = (import /path/to/myapp {}).exe;
  configSource = "/path/to/config";
  port = 8080;
};

```


### `obelisks.<name>.configSource :: string`

Description: The path to the obelisk application configuration folder. Configs will be copied from this folder every time the configuration is rebuilt. See <link xlink:heref="https://github.com/obsidiansystems/obelisk/tree/master/skeleton/config#config"> for more information.




Example: `"/path/to/obelisk-app/config"`



### `obelisks.<name>.obelisk :: package`

Description: The derivation containing the obelisk application that forms the basis of this service. This is usually the 'exe' attribute of the obelisk app.



Example: `"(import /path/to/obeliskapp {}).exe"`



### `obelisks.<name>.port :: 16 bit unsigned integer; between 0 and 65535 (both inclusive)`

Description: The port this service should listen on.

Default: `8080`

Example: `8080`




