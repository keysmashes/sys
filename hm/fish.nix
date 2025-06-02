{ config, lib, pkgs, ... }:

{
  options = {
    sys.fish.enable = lib.mkOption {
      description = "Whether to install fish, the friendly interactive shell.";
      type = lib.types.bool;
      default = true;
    };
  };
  config = lib.mkIf config.sys.fish.enable {
    programs.fish = {
      enable = true;
      functions = {
        bang_binding = ''
          switch (commandline -t)
            case "!"
              commandline -t $history[1]
              commandline -f repaint
            case "*"
              commandline -i !
          end
        '';
        copy = {
          wraps = "xclip";
          body = "xclip -sel clip $argv";
        };
        diff = {
          wraps = "diff";
          body = "command diff -u $argv"; # TODO: maybe use colordiff or kitty's diff here?
        };
      } // lib.attrsets.genAttrs [ "ffmpeg" "ffplay" "ffprobe" ] (binary: {
        wraps = binary;
        body = "command ${binary} -hide_banner $argv";
      }) // {
        fish_user_key_bindings = ''
          # https://github.com/fish-shell/fish-shell/wiki/Bash-Style-Command-Substitution-and-Chaining-
          bind ! bang_binding
          # https://github.com/fish-shell/fish-shell/pull/10213, https://github.com/fish-shell/fish-shell/commit/5de6f4bb3d8c3d4db1fd0b66c2ebfa59682ccc84
          for mode in (bind --list-modes); bind -M $mode ctrl-c cancel-commandline; end
          # https://github.com/fish-shell/fish-shell/issues/3011
          bind \cf accept-autosuggestion
          # we have fzf for more sophisticated searching
          bind \e\[A history-prefix-search-backward
          bind \e\[B history-prefix-search-forward
          # repaint the prompt on return (both "when a command is executed" as well as "any other time return is pressed at a prompt")
          # see https://github.com/fish-shell/fish-shell/pull/8142 for inspiration, though we don't actually need that feature
          # this means that the time shown in the prompt is the time the command was run, not the time the prompt was first printed
          bind \r repaint execute
          bind ctrl-shift-r repaint
        '';
        icat = "kitty +kitten icat --align left --place (math $COLUMNS - 2)x(math $LINES - 2)@0x(math $LINES - 1) $argv";
        kd = {
          wraps = "fd";
          body = "kitty +kitten hyperlinked_fd $argv";
        };
        kg = {
          wraps = "rg";
          body = "kitty +kitten hyperlinked_rg $argv";
        };
        l = ''
          if test -n $argv[1]
            if test -d $argv[1]
              ls $argv[2..] -- $argv[1]
            else if test -f $argv[1]
              less -N $argv[2..] -- $argv[1]
            else
              ls $argv
            end
          else
            ls
          end
        '';
        la = ''
          if test -n $argv[1]
            if test -d $argv[1]
              ls -aa $argv[2..] -- $argv[1]
            else if test -f $argv[1]
              less -N $argv[2..] -- $argv[1]
            else
              ls -aa $argv
            end
          else
            ls -aa
          end
        '';
        less = {
          wraps = "less";
          body = "command less -N $argv";
        };
        ll = {
          wraps = "eza";
          body = "ls -al $argv";
        };
        ls = {
          wraps = "eza";
          body = "eza --group -F $argv"; # TODO: only set this if eza is installed
        };
        lsof = {
          wraps = "lsof";
          body = "command lsof -P $argv";
        };
        man = { # https://hachyderm.io/@leftpaddotpy/112681918759377740
          wraps = "man";
          body = ''
            set -l cols (tput cols)
            test -z $cols; and set -l cols $COLUMNS
            test -z $cols; and set -l cols $MANWIDTH
            test -z $cols; and set -l cols 80
            if test $cols -gt 100
              MANWIDTH=100 command man $argv
            else
              MANWIDTH="$cols" command man $argv
            end
          '';
        };
        mkcd = {
          wraps = "mkdir";
          body = "mkdir -p -- $argv[1] && cd -- $argv[1]";
        };
        nix-meta = "nix eval --json $argv[1].meta | jq 'del(.platforms)'";
        now = "date +%s";
        oops = "history delete --exact --case-sensitive -- $history[1]";
        rm = {
          wraps = "rm";
          body = "command rm --interactive=never $argv"; # TODO: make this work with darwin's rm
        };
        rn = ''
          set filename (date +"%Y-%m-%d-%H%M%S")
          if test (count $argv) -gt 0
            set filename "$filename"-(string join -- - $argv)
          end
          mkdir -p ~/.rn
          mkdir ~/.rn/$filename
          cd ~/.rn/$filename
        '';
        v = {
          wraps = "nvim";
          body = "nvim $argv";
        };
        venv = ''
          set dir $argv[1]
          test -z "$dir"; and set dir "venv"
          source "./$dir/bin/activate.fish"
        '';
        whenis = "date -d @$argv[1]";
        yeet = ''
          echo "really yeet "(pwd)"? (ctrl-c if not)"
          if read
            rm -r (pwd)
            cd ..
          end
        '';
      };
      interactiveShellInit = ''
        # Most modern terminals automatically rewrap text, don't try and preempt them.
        set -g fish_handle_reflow 0
      '';
      shellInit = ''
        function fish_greeting
        end
        if set -q KITTY_INSTALLATION_DIR
          set --global KITTY_SHELL_INTEGRATION enabled
          source "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_conf.d/kitty-shell-integration.fish"
          set --prepend fish_complete_path "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_completions.d"
        end
      '';
      plugins = [
        {
          name = "fish-async-prompt";
          src = pkgs.applyPatches {
            src = pkgs.fetchFromGitHub {
              owner = "acomagu";
              repo = "fish-async-prompt";
              rev = "316aa03c875b58e7c7f7d3bc9a78175aa47dbaa8";
              hash = "sha256-J7y3BjqwuEH4zDQe4cWylLn+Vn2Q5pv0XwOSPwhw/Z0=";
            };
            patches = [
              (pkgs.fetchpatch {
                url = "https://github.com/acomagu/fish-async-prompt/commit/23e416fdece97c388173ba2c0065a10d185a0821.patch";
                hash = "sha256-S+5ZBSJ28dSp0iEfSkHFMLg6gLr8SPQDjUp4+Jo8U+U=";
                revert = true;
              })
              (pkgs.writeText "fish-async-prompt-tmp-path.patch" ''
                --- a/conf.d/__async_prompt.fish
                +++ b/conf.d/__async_prompt.fish
                @@ -1,7 +1,9 @@
                 status is-interactive
                 or exit 0

                +set -q TMPDIR; or set -l TMPDIR /tmp
                +mkdir -p $TMPDIR/fish-async-prompt
                -set -g __async_prompt_tmpdir (command mktemp -d)
                +set -g __async_prompt_tmpdir (command mktemp --tmpdir -d fish-async-prompt/tmp.XXXXXXXXXX)

                 # Setup after the user defined prompt functions are loaded.
                 function __async_prompt_setup_on_startup --on-event fish_prompt
              '')
            ];
          };
        }
      ];
    };
  };
}
