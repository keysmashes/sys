{ inputs, lib, ... }:

if inputs ? nix-index-database
then {
  programs.command-not-found.enable = false;
  imports = [ inputs.nix-index-database.homeModules.nix-index ];
}
else {}
