{ config, lib, pkgs, ... }:

{
  options = {
    sys.jj.enable = lib.mkOption {
      description = "Whether to install Jujutsu, a version control system.";
      type = lib.types.bool;
      default = true;
    };
  };
  config = lib.mkIf config.sys.jj.enable {
    home.packages = [ pkgs.watchman ];
    programs.jujutsu = {
      enable = true;
      settings = {
        aliases = let
          mkBashScript = text: [ "util" "exec" "--" "bash" "-c" text "bash" ];
        in {
          aa = [ "log" "-r" "all()" ];
          blame = [ "file" "annotate" ];
          bl = [ "b" "l" ];
          bla = [ "b" "l" "-a" ];
          blt = [ "b" "l" "-t" ];
          bn = mkBashScript ''
            jj b m "$1" -t "($1)+"
          '';
          bnf = mkBashScript ''
            jj b m -f "$1" -t "($1)+"
          '';
          bnew = mkBashScript ''
            jj new --no-edit "$@" && jj bn "''${@:$#}"
          '';
          bp = mkBashScript ''
            jj b m --allow-backwards "$1" -t "($1)-"
          '';
          bpf = mkBashScript ''
            jj b m --allow-backwards -f "$1" -t "($1)-"
          '';
          drop = [ "abandon" ];
          dup = [ "duplicate" ];
          hash = [ "show" "-T" "stringify(commit_id)" ];
          id = [ "show" "-T" "stringify(change_id)" ];
          link = mkBashScript ''
            jj rebase -s "$2" -d "all:($2)-|($1)"
          '';
          n = [ "next" "-e" ];
          p = [ "prev" "-e" ];
          pog = [ "op" "log" "-p" ];
          shop = [ "op" "show" "-p" ];
          slink = mkBashScript ''
            jj link "$1" "$2" && jj simplify-parents -r "$2"
          '';
          stat = [ "show" "--stat" ];
          tug = ["bookmark" "move" "--from" "heads(::@- & bookmarks())" "--to" "@-"];
          unlink = mkBashScript ''
            jj rebase -s "$2" -d "all:($2)- ~ ($1)"
          '';
          unwip = [ "util" "exec" "--" "bash" "-c" ''
            jj log --no-graph -r "''${1:-@}" -T description | sed -e 's/^wip: //' | jj desc --stdin "''${1:-@}"
          '' "bash" ];
          update = [ "git" "fetch" "--all-remotes" ];
          wa = mkBashScript ''
            jj wip "$1" && jj bnew -A "$1"
          '';
          wip = [ "bookmark" "set" "--allow-backwards" "wip" "--revision" ];
          wop = [ "bookmark" "forget" "wip" ];
        };
        core = {
          fsmonitor = "watchman";
        };
        git = {
          private-commits = "description(glob:'wip:*') | description(glob:'private:*')";
        };
        revset-aliases = let
          mkRepeated = char: direction: lib.genAttrs (builtins.genList (x: lib.strings.replicate (x+1) char) 5) (name: "@" + lib.strings.replicate (builtins.stringLength name) direction);
        in {
          i = "@";
        } // mkRepeated "h" "+" // mkRepeated "j" "-";
        templates = {
          draft_commit_description = ''
            concat(
              description,
              if(!description, "\n"),
              "\n",
              surround(
                "JJ: This commit contains the following changes:\n", "",
                indent("JJ:     ", diff.summary()),
              ),
              "JJ:\n",
              "JJ: ignore-rest\n",
              diff.git(),
            )
          '';
          file_annotate = ''
            separate(" ",
              commit.change_id().shortest(8),
              if(first_line_in_hunk, pad_end(14, truncate_end(14, commit.author().email(), '…')), pad_start(14, "")),
              if(first_line_in_hunk, commit_timestamp(commit).local().format('%Y-%m-%d %H:%M:%S'), pad_start(19, "")),
              if(first_line_in_hunk, pad_end(52, truncate_end(52, commit.description().first_line(), '…')), pad_start(52, "")),
              pad_start(4, line_number),
            ) ++ ": " ++ content
          '';
          # based on builtin_log_compact
          log = ''
            if(root,
              format_root_commit(self),
              label(if(current_working_copy, "working_copy"),
                concat(
                  format_short_commit_header(self) ++ "\n",
                  separate(" ",
                    if(empty, label("empty", "(empty)")),
                    if(description,
                      concat(description.first_line(), if(description.lines().len() > 1, " •")),
                      label(if(empty, "empty"), description_placeholder),
                    ),
                  ) ++ "\n",
                ),
              )
            )
          '';
          log_node = ''
            coalesce(
              if(!self, label("elided", "~")),
              label(
                separate(" ",
                  if(current_working_copy, "working_copy"),
                  if(immutable, "immutable"),
                  if(conflict, "conflict"),
                ),
                coalesce(
                  if(current_working_copy, "@"),
                  if(immutable, "◆"),
                  if(conflict, "×"),
                  "·",
                )
              )
            )
          '';
          op_log_node = ''
            coalesce(
              if(current_operation, label("current_operation", "@")),
              "·",
            )
          '';
          show = ''
            concat(
              builtin_log_detailed,
              surround("", "\n", diff.summary()),
            )
          '';
        };
        user = {
          name = config.sys.git.name;
          email = config.sys.git.email;
        };
        ui = {
          default-command = "log";
          diff-editor = ":builtin";
          pager = "some";
        };
      };
    };
    xdg.configFile."fish/completions/jj.fish".text = lib.mkIf config.sys.fish.enable ''
      COMPLETE=fish jj | source
    '';
  };
}
