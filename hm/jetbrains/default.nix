{ config, lib, pkgs, ... }:

{
  options = {
    sys.jetbrains.clion.enable = lib.mkOption {
      description = "Whether to install CLion, a JetBrains IDE for C/C++.";
      type = lib.types.bool;
      default = false;
    };
    sys.jetbrains.dataspell.enable = lib.mkOption {
      description = "Whether to install DataSpell, a JetBrains IDE for Jupyter notebooks.";
      type = lib.types.bool;
      default = false;
    };
    sys.jetbrains.rider.enable = lib.mkOption {
      description = "Whether to install Rider, a JetBrains IDE for C#.";
      type = lib.types.bool;
      default = false;
    };
    sys.jetbrains.rustrover.enable = lib.mkOption {
      description = "Whether to install RustRover, a JetBrains IDE for Rust.";
      type = lib.types.bool;
      default = false;
    };
    sys.jetbrains.webstorm.enable = lib.mkOption {
      description = "Whether to install WebStorm, a JetBrains IDE for JavaScript.";
      type = lib.types.bool;
      default = false;
    };
  };
  config = lib.mkMerge [
    (lib.mkIf config.sys.jetbrains.clion.enable {
      home.packages = [ pkgs.jetbrains.clion ];
    })
    (lib.mkIf config.sys.jetbrains.dataspell.enable {
      home.packages = [ pkgs.jetbrains.dataspell ];
    })
    (lib.mkIf config.sys.jetbrains.rider.enable {
      home.packages = [ pkgs.jetbrains.rider ];
    })
    (lib.mkIf config.sys.jetbrains.rustrover.enable {
      home.packages = [ pkgs.jetbrains.rust-rover ];
    })
    (lib.mkIf config.sys.jetbrains.webstorm.enable {
      home.packages = [ pkgs.jetbrains.webstorm ];
    })
    ({
      home.file.".ideavimrc".source = ./ideavimrc;
    })
  ];
}
