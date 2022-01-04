# Module options

## System-level systemd service

### `obelisks :: attribute set of submodules`






### `obelisks.acmeCertAdminEmail :: string`

Description: Contact email address for the CA to be able to reach you. See
security.acme.certs in the NiOS manual.


Example: admin@example.com



### `obelisks.baseUrl :: string`







### `obelisks.configSource :: string`

Description: The path to the obelisk application configuration folder. Configs will be copied from this folder every time the configuration is rebuilt. See <link xlink:heref="https://github.com/obsidiansystems/obelisk/tree/master/skeleton/config#config"> for more information.


Example: /path/to/obelisk-app/config



### `obelisks.enableHttps :: boolean`

Description: Enable HTTPS via Let's Encrypt.






### `obelisks.enableNginxReverseProxy :: boolean`

Description: Enable nginx reverse proxy.






### `obelisks.extraBackendArgs :: string`







### `obelisks.obelisk :: package`

Description: The derivation containing the obelisk application that forms the basis of this service. This is usually the 'exe' attribute of the obelisk app.

Example: (import /path/to/obeliskapp {}).exe



### `obelisks.port :: 16 bit unsigned integer; between 0 and 65535 (both inclusive)`

Description: The port this service should listen on.

Example: 8080



### `obelisks.userHome :: null or string`

Description: The home directory for the user that will run the service. Defaults to /var/lib/name-of-obelisk


Example: /var/lib/example



### `obelisks.userName :: null or string`

Description: The name of the user that will run the service. This user will be created. Defaults to the name of the obelisk.






### `obelisks.virtualHostName :: string`

Description: The nginx vhost name for the application. See
services.nginx.virtualHosts in the NixOS manual for more
information.


Example: app.example.com





## User-level systemd service

### `obelisks :: attribute set of submodules`

Description: An attrset of obelisk applications to run as user systemd services.

Example: 
```
obelisks."myapp" = {
  obelisk = (import /path/to/myapp {}).exe;
  configSource = "/path/to/config";
  port = 8080;
};

```


### `obelisks.configSource :: string`

Description: The path to the obelisk application configuration folder. Configs will be copied from this folder every time the configuration is rebuilt. See <link xlink:heref="https://github.com/obsidiansystems/obelisk/tree/master/skeleton/config#config"> for more information.


Example: /path/to/obelisk-app/config



### `obelisks.obelisk :: package`

Description: The derivation containing the obelisk application that forms the basis of this service. This is usually the 'exe' attribute of the obelisk app.

Example: (import /path/to/obeliskapp {}).exe



### `obelisks.port :: 16 bit unsigned integer; between 0 and 65535 (both inclusive)`

Description: The port this service should listen on.

Example: 8080




