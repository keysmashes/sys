{ config, inputs, lib, pkgs, ... }:

let
  krisp-patcher = pkgs.writers.writePython3Bin "krisp-patcher" {
    libraries = with pkgs.python3Packages; [ capstone pyelftools ];
    flakeIgnore = [
      "E501" # line too long (82 > 79 characters)
      "F403" # ‘from module import *’ used; unable to detect undefined names
      "F405" # name may be undefined, or defined from star imports: module
    ];
  } (builtins.readFile ./krisp-patcher.py);
in
{
  options = {
    sys.discord.enable = lib.mkOption {
      description = "Whether to install Discord, a voice and text chat platform.";
      type = lib.types.bool;
      default = false;
    };
    sys.discord.moonlight = lib.mkOption {
      description = "Whether to enable the moonlight client mod.";
      type = lib.types.bool;
      default = false;
    };
    sys.discord.vencord = lib.mkOption {
      description = "Whether to enable the Vencord client mod.";
      type = lib.types.bool;
      default = false;
    };
  };
  config = lib.mkIf config.sys.discord.enable {
    assertions = [
      { assertion = config.sys.discord.moonlight -> !config.sys.discord.vencord; }
      { assertion = config.sys.discord.vencord -> !config.sys.discord.moonlight; }
    ];
    home.packages = [
      (pkgs.discord.override {
        withVencord = config.sys.discord.vencord;
        withMoonlight = config.sys.discord.moonlight;
        moonlight = inputs.moonlight.packages.${pkgs.system}.moonlight;
      })
      krisp-patcher
    ];
  };
}
