{ delib, ... }:
{
  denix.modules."programs.osu".options.settings =
    with delib;
    submoduleOption {
      # https://github.com/ppy/osu/blob/master/osu.Game/Configuration/OsuConfigManager.cs
      options = {
        prefer24HourTime = allowNull (boolOption null);

        # TODO: skin
        gameplay = {
          background = {
            dimLevel = allowNull (intBetweenOption 0 100 null);
            blurLevel = allowNull (intBetweenOption 0 100 null);
            lightenDuringBreaks = allowNull (boolOption null);
          };
        };

        cursor = {
          menuSize = allowNull (intBetweenOption 50 200 null);
          gameplaySize = allowNull (intBetweenOption 10 200 null);
          rotateWhenDragging = allowNull (boolOption null);
        };

        ui = {
          scale = allowNull (intBetweenOption 80 160 null);
          parallax = description (allowNull (boolOption null)) "Show a slight parallax while navigating in-game menus (not during gameplay).";
          holdToConfirmDelay = allowNull (steppedIntBetweenOption 0 500 50 null);

          mainMenu = {
            menuTips = allowNull (boolOption null);
            interfaceVoices = allowNull (boolOption null);
            osuMusicTheme = allowNull (boolOption null);

            introSequence = allowNull (enumOption [ "Circles" "Welcome" "Triangles" "Random" ] null);

            background = {
              source = allowNull (enumOption [ "Skin" "Beatmap" "BeatmapWithStoryboard" ] null);
              seasonalMode = description (allowNull (enumOption [ "Always" "Sometimes" "Never" ] null)) ''
                Always - Seasonal backgrounds are shown regardless of season, if at all available.
                Sometimes - Seasonal backgrounds are shown only during their corresponding season.
                Never - Seasonal backgrounds are never shown.
              '';
            };
          };

          songSelect = {
            showConvertedBeatmaps = allowNull (boolOption null);
            randomSelectionAlgorithm =
              description (allowNull (enumOption [ "RandomPermutation" "Random" ] null))
                ''
                  RandomPermutation - Selects each item exactly once per cycle in a shuffled order. Repeats occur only after every item has been shown.
                  Random - Selects items independently at random. Items can repeat and may appear consecutively.
                '';
            backgroundBlur = allowNull (boolOption null);
          };

          modSelect = {
            hotkeyStyle = description (allowNull (enumOption [ "Sequential" "Classic" ] null)) ''
              Sequential - Each letter row on the keyboard controls one of the three first ModColumns. Individual letters in a row trigger the mods in a sequential fashion.
              Classic - Matches keybindings from stable 1:1. One keybinding can toggle between what used to be MultiMods on stable, and some mods in a column may not have any hotkeys at all.
            '';
            autoFocusSearch = allowNull (boolOption null);
          };
        };

        graphics = {
          showFps = allowNull (boolOption null);
        };
      };
    } { };
}
