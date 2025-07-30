{ unstable, here, moonlight }:

let
  localPath = path: let
    inherit (builtins) stringLength substring;
    # careful here, otherwise we accidentally start copying things to the store
    path' = toString path;
    this' = toString ./.;
    pathLen = stringLength path';
    thisLen = stringLength this';
  in assert substring 0 thisLen path' == this'; here + (substring thisLen pathLen path');
in
[
  (self: super: if moonlight ? overlays then {
    discord-moonlight = (moonlight.overlays.default self super).discord;
  } else {})
  (self: super: {
    # out-of-date software/waiting for backports
    termtheme = assert !(super ? termtheme); super.rustPlatform.buildRustPackage {
      pname = "termtheme";
      version = "0-unstable-2025-01-24";
      src = super.fetchFromGitHub {
        owner = "bash";
        repo = "terminal-colorsaurus";
        rev = "f99ff455e2d3272c9accf3cee6b759c1702d7892";
        hash = "sha256-LZdXKJYEq2L4zhVWVZCJbM9zf3cmNpdBWK4hQv1W4+0=";
      };
      cargoHash = "sha256-dzIjYAizPDe5//YHV7DyxVNHrF7xfLMJdK6x+YI2hQA=";
      buildAndTestSubdir = "crates/termtheme";
    };
    unicode-paracode = assert builtins.compareVersions super.unicode-paracode.version "2.9" != 1; super.unicode-paracode.overrideAttrs (old: { # https://github.com/garabik/unicode/pull/21
      patches = (old.patches or []) ++ [
        (super.fetchpatch {
          name = "show-unicode1-name-as-fallback.patch";
          url = "https://github.com/garabik/unicode/pull/21/commits/2c11b705810a5a3a927e2b36ed6d32ce2867a6f7.patch";
          sha256 = "sha256-cVBXnsi7FGXki7woJj09k8joyP1695HsOTWktPtFg1c=";
        })
      ];
    });
    # custom patches
    gpu-screen-recorder = super.gpu-screen-recorder.overrideAttrs (old: {
      patches = (old.patches or []) ++ [
        (localPath ./patches/gpu-screen-recorder-0001-quiet.patch)
        (localPath ./patches/gpu-screen-recorder-0002-filename.patch)
      ];
    });
    i3 = super.i3.overrideAttrs (old: {
      patches = (old.patches or []) ++ [
        (localPath ./patches/i3-0001-i3bar-border.patch)
        (localPath ./patches/i3-0002-reduce-log-verbosity.patch)
      ];
    });
    i3lock-color = super.i3lock-color.overrideAttrs (old: {
      src = super.fetchFromGitHub {
        owner = "keysmashes";
        repo = "i3lock-color";
        rev = "8ab09b8d3fdd87ac0b14a3f419281a4791fa2c78";
        sha256 = "1l25x4wx3ar6lfpxcm5whzpxyblcs8blf4gqi3vh2ynvn7cn1qib";
      };
    });
    i3status-rust = super.i3status-rust.overrideAttrs (old: {
      patches = (old.patches or []) ++ [
        (localPath ./patches/i3status-rust-0001-uptime-warning.patch)
        (localPath ./patches/i3status-rust-0002-kdeconnect-zero-battery.patch)
        (localPath ./patches/i3status-rust-0003-gpu-use-vram-not-utilisation.patch)
        (localPath ./patches/i3status-rust-0004-kdeconnect-no-cell-network.patch)
      ];
    });
    rhythmbox = super.rhythmbox.overrideAttrs (old: {
      patches = (old.patches or []) ++ [
        (localPath ./patches/rhythmbox-0001-no-pause-notification.patch)
      ];
    });
    rink = super.rink.overrideAttrs (old: {
      patches = (old.patches or []) ++ [
        (localPath ./patches/rink-0001-change-date-formats.patch)
        (localPath ./patches/rink-0002-amp-hour.patch)
      ];
    });
    steam = super.steam.overrideAttrs (old: let # https://github.com/tejing1/nixos-config/blob/78e681e4b823c59751730531468a8e9781593ba1/overlays/steam-fix-screensaver/default.nix
      preloadLibFor = bits: assert bits == 32 || bits == 64; super.runCommandWith {
        stdenv = if bits == 64 then self.stdenv else self.stdenv_32bit;
        runLocal = false;
        name = "filter_SDL_DisableScreenSaver.${toString bits}.so";
        derivationArgs = {};
      } "gcc -shared -fPIC -ldl -m${toString bits} -o $out ${./steam-filter-sdl-disablescreensaver.c}";
      preloadLibs = super.runCommandLocal "filter_SDL_DisableScreenSaver" {} (builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs (platform: bits: ''
        mkdir -p $out/${platform}
        ln -s ${preloadLibFor bits} $out/${platform}/filter_SDL_DisableScreenSaver.so
      '') {
        x86_64 = 64;
        i686 = 32;
      })));
    in {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ self.makeWrapper ];
      buildCommand = (old.buildCommand or "") + ''
        steamBin="$(readlink $out/bin/steam)"
        rm $out/bin/steam
        makeWrapper $steamBin $out/bin/steam --prefix LD_PRELOAD : ${preloadLibs}/\$PLATFORM/filter_SDL_DisableScreenSaver.so
      '';
    });
    xdg-desktop-portal-gtk = super.xdg-desktop-portal-gtk.overrideAttrs (old: {
      patches = (old.patches or []) ++ [
        (localPath ./patches/xdg-desktop-portal-gtk-0001-dont-truncate-urls.patch)
      ];
    });
    # software not in nixpkgs
    binary-ninja = super.callPackage (localPath ./programs/binary-ninja.nix) {};
    display-volume = super.rustPlatform.buildRustPackage {
      pname = "display-volume";
      version = "0.1.0";
      src = super.fetchFromGitHub {
        owner = "keysmashes";
        repo = "display-volume";
        rev = "318a70933869d3a5c50bce06bda2887c3c287e84";
        sha256 = "1gqyxggxwk87ddcsisb4s1rw8f9z8lyxg95py0nn77q18w6f6srg";
      };
      cargoHash = "sha256-lz2FLvSkFSiI0CCm/fJwr3A7lXYpoWrLVM0IClC6t3s=";
      nativeBuildInputs = [
        super.autoPatchelfHook
      ];
      buildInputs = [
        super.libpulseaudio
      ];
    };
    file2img = super.callPackage (localPath ./programs/file2img.nix) {};
    fishPlugins = super.fishPlugins.overrideScope (self': super': let
      meta = {
        pname = "fenv.rs";
        version = "unstable-2023-07-12";
        src = super.fetchFromGitHub {
          owner = "keysmashes";
          repo = "fenv.rs";
          rev = "6bff44ff5b636407149d22dcf4776a22e71908ec";
          sha256 = "sha256-jWaEd6G44j9sZtdBUxp5gCrlcYXrecUXeVo+foyfVfM=";
        };
      };
      fenv = super.rustPlatform.buildRustPackage {
        inherit (meta) pname version src;
        cargoHash = "sha256-aJgmNB6AvQuOGT3NNnai+ClEpH7TLUmegaS0S0y/Bdc=";
      };
    in {
      foreign-env = super'.buildFishPlugin {
        inherit (meta) pname version src;
        preInstall = ''
          sed -i 's|_fenv|${fenv}/bin/_fenv|g' functions/fenv.fish
        '';
      };
    });
  })
]
