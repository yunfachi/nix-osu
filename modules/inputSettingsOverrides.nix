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
                lib.recursiveUpdate (delib.nix-osu.filterNullAttrs {
                  "osu.Framework.Input.Handlers.Mouse.MouseHandler, osu.Framework" = {
                    # https://github.com/ppy/osu/blob/master/osu.Game/Overlays/Settings/Sections/Input/MouseSettings.cs
                    Enabled = cfg.settings.input.mouse.enable;
                    UseRelativeMode = cfg.settings.input.mouse.highPrecision;
                    Sensitivity = cfg.settings.input.mouse.sensitivity;
                  };

                  "osu.Framework.Input.Handlers.Tablet.OpenTabletDriverHandler, osu.Framework" = {
                    # https://github.com/ppy/osu/blob/master/osu.Game/Overlays/Settings/Sections/Input/TabletSettings.cs
                    Enabled = cfg.settings.input.tablet.enable;
                    AreaOffset = {
                      x = cfg.settings.input.tablet.areaOffset.x;
                      y = cfg.settings.input.tablet.areaOffset.y;
                    };
                    AreaSize = {
                      x = cfg.settings.input.tablet.areaSize.x;
                      y = cfg.settings.input.tablet.areaSize.y;
                    };
                    # OutputAreaOffset = {
                    #   x = 0.5;
                    #   y = 0.5;
                    # };
                    # OutputAreaSize = {
                    #   x = 1;
                    #   y = 1;
                    # };
                    Rotation = cfg.settings.input.tablet.rotation;
                    PressureThreshold = fromPercent cfg.settings.input.tablet.pressureThreshold;
                    # Tablet = ...;
                  };

                  "osu.Framework.Input.Handlers.Joystick.JoystickHandler, osu.Framework" = {
                    # https://github.com/ppy/osu/blob/master/osu.Game/Overlays/Settings/Sections/Input/JoystickSettings.cs
                    Enabled = cfg.settings.input.joystick.enable;
                    DeadzoneThreshold = fromPercent cfg.settings.input.joystick.deadzoneThreshold;
                  };

                  "osu.Framework.Input.Handlers.Keyboard.KeyboardHandler, osu.Framework" = {
                    Enabled = cfg.settings.input.keyboard.enable;
                  };

                  "osu.Framework.Input.Handlers.Touch.TouchHandler, osu.Framework" = {
                    # https://github.com/ppy/osu/blob/master/osu.Game/Overlays/Settings/Sections/Input/TouchSettings.cs
                    Enabled = cfg.settings.input.touch.enable;
                  };

                  "osu.Framework.Input.Handlers.Midi.MidiHandler, osu.Framework" = {
                    Enabled = cfg.settings.input.midi.enable;
                  };
                }) cfg.extraInputSettings
              )
            )
          );
      };
    };
}
