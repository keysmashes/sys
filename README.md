**New repository: <https://codeberg.org/keysmashes/sys>**

---

# sys

dependency flake for my system configurations

## Usage

usually you should write a new machine flake based on [sys-tem](https://github.com/keysmashes/sys-tem).

if you need a one-off barebones system configuration right now, you can try one or more of the following, as applicable:

- `nixos-rebuild --flake github:keysmashes/sys#default switch`
- `darwin-rebuild --flake github:keysmashes/sys#default switch`
- `home-manager --flake github:keysmashes/sys#default switch`

you might need `--extra-experimental-features nix-command --extra-experimental-features flakes` too.
