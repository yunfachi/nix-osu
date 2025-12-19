{ delib, ... }:
{
  denix.modules."programs.osu" =
    { cfg, ... }:
    {
      options = with delib; {
        extraGameSettings = attrsOption { };

        gameIniOverridesFile =
          let
            fromPercent = x: if x != null then x / 100.0 else null;
          in
          pathOption (
            builtins.toFile "game_overrides.ini" (
              delib.nix-osu.generators.toOsuINI (
                {
                  ReleaseStream = if cfg.releaseStream != null then {lazer = "Lazer"; tachyon = "Tachyon";}.${cfg.releaseStream} else null;

                  Prefer24HourTime = cfg.settings.prefer24HourTime;

                  DimLevel = cfg.settings.gameplay.background.dimLevel;
                  BlurLevel = cfg.settings.gameplay.background.blurLevel;
                  LightenDuringBreaks = cfg.settings.gameplay.background.lightenDuringBreaks;

                  MenuCursorSize = fromPercent cfg.settings.cursor.menuSize;
                  GameplayCursorSize = fromPercent cfg.settings.cursor.gameplaySize;
                  CursorRotation = cfg.settings.cursor.rotateWhenDragging;

                  # ui
                  UIScale = fromPercent cfg.settings.ui.scale;
                  MenuParallax = cfg.settings.ui.parallax;
                  UIHoldActivationDelay = cfg.settings.ui.holdToConfirmDelay;
                  ## ui.mainMenu
                  MenuTips = cfg.settings.ui.mainMenu.menuTips;
                  MenuVoice = cfg.settings.ui.mainMenu.interfaceVoices;
                  MenuMusic = cfg.settings.ui.mainMenu.osuMusicTheme;

                  IntroSequence = cfg.settings.ui.mainMenu.introSequence;
                  ### ui.mainMenu.background
                  MenuBackgroundSource = cfg.settings.ui.mainMenu.background.source;
                  SeasonalBackgroundMode = cfg.settings.ui.mainMenu.background.seasonalMode;
                  ## ui.songSelect
                  ShowConvertedBeatmaps = cfg.settings.ui.songSelect.showConvertedBeatmaps;
                  RandomSelectAlgorithm = cfg.settings.ui.songSelect.randomSelectionAlgorithm;
                  SongSelectBackgroundBlur = cfg.settings.ui.songSelect.backgroundBlur;
                  ## ui.modSelect
                  ModSelectHotkeyStyle = cfg.settings.ui.modSelect.hotkeyStyle;
                  ModSelectTextSearchStartsActive = cfg.settings.ui.modSelect.autoFocusSearch;

                  # graphics
                  ShowFpsDisplay = cfg.settings.graphics.showFps;
                }
                // cfg.extraGameSettings
              )
            )
          );
      };
    };
}
