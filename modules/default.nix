{
  delib,
  lib,
  self,
  ...
}:
{
  denix.modules."programs.osu" =
    {
      cfg,
      ...
    }:
    {
      options =
        with delib;
        { pkgs, ... }:
        {
          enable = boolOption false;

          package = allowNull (
            packageOption (
              self.packages.${pkgs.stdenv.hostPlatform.system}.osu-lazer-bin.override (
                lib.optionalAttrs (cfg.releaseStream != null) {
                  inherit (cfg) releaseStream;
                }
                // {
                  extraShellArgs =
                    lib.optionals (cfg.proxy.http != null) [
                      "--set"
                      "http_proxy"
                      cfg.proxy.http
                    ]
                    ++ lib.optionals (cfg.proxy.https != null) [
                      "--set"
                      "https_proxy"
                      cfg.proxy.https
                    ]
                    ++ lib.optionals (cfg.proxy.socks != null) [
                      "--set"
                      "all_proxy"
                      cfg.proxy.socks
                    ];
                }
              )
            )
          );
          releaseStream = allowNull (enumOption [ "lazer" "tachyon" ] null);

          proxy = {
            http = allowNull (strOption null);
            https = allowNull (strOption cfg.proxy.http);
            socks = allowNull (strOption null);
          };
        };

      home.ifEnabled =
        { lib, pkgs, ... }:
        {
          home.packages = lib.optionals (cfg.package != null) [ cfg.package ];

          home.activation.nix-osu = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            mkdir -p $XDG_DATA_HOME/osu
            cd $XDG_DATA_HOME/osu

            ${lib.getExe pkgs.crudini} --merge framework.ini < ${cfg.frameworkIniOverridesFile}
            ${lib.getExe pkgs.crudini} --merge game.ini < ${cfg.gameIniOverridesFile}
            ${
              pkgs.writers.writePython3 "mergeInputJsonOverridesFileIntoInputJson.py" { } ''
                import json
                import sys


                def deep_merge(target, patch):
                    for key, value in patch.items():
                        if key in target and isinstance(target[key], dict) and \
                                             isinstance(value, dict):
                            deep_merge(target[key], value)
                        else:
                            target[key] = value


                try:
                    with open("input.json", "r", encoding="utf-8") as f:
                        config = json.load(f)
                except FileNotFoundError:
                    config = {}

                with open(sys.argv[1], "r", encoding="utf-8") as f:
                    overrides = json.load(f)

                handlers = config.get("InputHandlers", [])
                handlers_by_type = {handler["$type"]: handler for handler in handlers}

                for handler_type, new_fields in overrides.items():
                    if handler_type in handlers_by_type:
                        deep_merge(handlers_by_type[handler_type], new_fields)
                    else:
                        handlers.append({"$type": handler_type, **new_fields})

                with open("input.json", "w", encoding="utf-8") as f:
                    json.dump(config, f, indent=2, ensure_ascii=False)
              ''
            } ${cfg.inputJsonOverridesFile}
          '';
        };
    };
}
