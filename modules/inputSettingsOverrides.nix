{ delib, lib, ... }:
{
  denix.modules."programs.osu" =
    { cfg, ... }:
    {
      options = with delib; {
        extraInputSettings = attrsOption { };

        inputJsonOverridesFile =
          let
            fromPercent = x: if x != null then x / 100.0 else null;
          in
          pathOption (
            builtins.toFile "input_overrides.json" (
              builtins.toJSON (
                lib.recursiveUpdate {
                  "osu.Framework.Input.Handlers.Keyboard.KeyboardHandler, osu.Framework" = {

                  };
                  "osu.Framework.Input.Handlers.Tablet.OpenTabletDriverHandler, osu.Framework" = {

                  };
                  "osu.Framework.Input.Handlers.Mouse.MouseHandler, osu.Framework" = {

                  };
                  "osu.Framework.Input.Handlers.Touch.TouchHandler, osu.Framework" = {

                  };
                  "osu.Framework.Input.Handlers.Joystick.JoystickHandler, osu.Framework" = {

                  };
                  "osu.Framework.Input.Handlers.Midi.MidiHandler, osu.Framework" = {

                  };
                } cfg.extraInputSettings
              )
            )
          );
      };
    };
}
