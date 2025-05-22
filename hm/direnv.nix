{ config, lib, ... }:

{
  options = {
    sys.direnv.enable = lib.mkOption {
      description = "Whether to enable direnv, a per-directory environment variable loader.";
      type = lib.types.bool;
      default = true;
    };
  };
  config = lib.mkIf config.sys.direnv.enable {
    programs.direnv = {
      enable = true;
      config = {
        global.hide_env_diff = true;
      };
      stdlib = ''
        # https://github.com/direnv/direnv/wiki/Customizing-cache-location#human-readable-directories
        # NB: we use sha256sum rather than sha1sum
        : "''${XDG_CACHE_HOME:="''${HOME}/.cache"}"
        declare -A direnv_layout_dirs
        direnv_layout_dir() {
            local hash path
            echo "''${direnv_layout_dirs[$PWD]:=$(
                hash="$(sha256sum - <<< "$PWD" | head -c40)"
                path="''${PWD//[^a-zA-Z0-9]/-}"
                echo "''${XDG_CACHE_HOME}/direnv/layouts/''${hash}''${path}"
            )}"
        }
      '';
    };
  };
}
