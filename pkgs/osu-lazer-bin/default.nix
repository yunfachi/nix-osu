{
  lib,
  stdenvNoCC,
  fetchzip,
  fetchurl,
  appimageTools,
  makeWrapper,
  nativeWayland ? true,
  # "tachyon" means using the latest release, NOT JUST the latest Tachyon release.
  # Sometimes, Lazer is newer than Tachyon, and that's how the osu! update check works.
  releaseStream ? "lazer",
  extraShellArgs ? [ ],
  ...
}:
let
  fullData = builtins.fromJSON (builtins.readFile ./data.json);
  # https://github.com/ppy/osu/blob/e68bab4f4b4bcd4ba5705d5bfddc6979859a9b35/osu.Game/Updater/NoActionUpdateManager.cs#L43
  data =
    if releaseStream == "tachyon" then fullData.${fullData.latest} else fullData.${releaseStream};

  pname = "osu-lazer-bin";
  version = data.version;

  src =
    {
      aarch64-darwin = fetchzip {
        url = "https://github.com/ppy/osu/releases/download/${version}/osu.app.Apple.Silicon.zip";
        hash = data.darwin-apple-silicon-hash;
        stripRoot = false;
      };
      x86_64-darwin = fetchzip {
        url = "https://github.com/ppy/osu/releases/download/${version}/osu.app.Intel.zip";
        hash = data.darwin-intel-hash;
        stripRoot = false;
      };
      x86_64-linux = fetchurl {
        url = "https://github.com/ppy/osu/releases/download/${version}/osu.AppImage";
        hash = data.appimage-hash;
      };
    }
    .${stdenvNoCC.system} or (throw "osu-lazer-bin: ${stdenvNoCC.system} is unsupported.");

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Rhythm is just a *click* away (AppImage version for score submission and multiplayer, and binary distribution for Darwin systems)";
    homepage = "https://osu.ppy.sh";
    license = with lib.licenses; [
      mit
      cc-by-nc-40
      unfreeRedistributable # osu-framework contains libbass.so in repository
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ yunfachi ];
    mainProgram = "osu!";
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
      "x86_64-linux"
    ];
  };

  shared = {
    inherit
      pname
      version
      src
      passthru
      meta
      ;
  };
in
if stdenvNoCC.hostPlatform.isDarwin then
  stdenvNoCC.mkDerivation (
    shared
    // {
      nativeBuildInputs = [ makeWrapper ];

      installPhase = ''
        runHook preInstall
        OSU_WRAPPER="$out/Applications/osu!.app/Contents"
        OSU_CONTENTS="osu!.app/Contents"
        mkdir -p "$OSU_WRAPPER/MacOS"
        cp -r "$OSU_CONTENTS/Info.plist" "$OSU_CONTENTS/Resources" "$OSU_WRAPPER"
        cp -r "osu!.app" "$OSU_WRAPPER/Resources/osu-wrapped.app"
        makeWrapper "$OSU_WRAPPER/Resources/osu-wrapped.app/Contents/MacOS/osu!" "$OSU_WRAPPER/MacOS/osu!" ${lib.escapeShellArgs extraShellArgs} \
          --set OSU_EXTERNAL_UPDATE_PROVIDER 1
        runHook postInstall
      '';
    }
  )
else
  lib.fix (
    self:
    let
      contents = appimageTools.extract { inherit (self) pname version src; };
    in
    appimageTools.wrapType2 (
      shared
      // {
        extraPkgs = pkgs: with pkgs; [ icu ];

        # fix OpenGL renderer on nvidia + wayland
        extraBwrapArgs = [
          "--ro-bind-try /etc/egl/egl_external_platform.d /etc/egl/egl_external_platform.d"
        ];

        extraInstallCommands = ''
          . ${makeWrapper}/nix-support/setup-hook
          mv -v $out/bin/${self.pname} $out/bin/osu!

          wrapProgram $out/bin/osu! ${lib.escapeShellArgs extraShellArgs} \
            ${lib.optionalString nativeWayland "--set SDL_VIDEODRIVER wayland"} \
            --set OSU_EXTERNAL_UPDATE_PROVIDER 1

          install -Dm444 ${contents}/osu!.desktop -t $out/share/applications
          install -Dm644 ${./osu-mime.xml} $out/share/mime/packages/osu.xml
          for i in 16 32 48 64 96 128 256 512 1024; do
            install -Dm644 ${contents}/osu.png $out/share/icons/hicolor/''${i}x$i/apps/osu.png
          done
        '';
      }
    )
  )
