{ delib, ... }:
{
  denix.modules."programs.osu" =
    { cfg, ... }:
    {
      options = with delib; {
        extraFrameworkSettings = attrsOption { };

        frameworkIniOverridesFile = pathOption (
          builtins.toFile "framework_overrides.ini" (
            delib.nix-osu.generators.toOsuINI (
              {

              }
              // cfg.extraFrameworkSettings
            )
          )
        );
      };
    };
}
