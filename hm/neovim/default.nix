{ config, lib, pkgs, ... }:

{
  options = {
    sys.neovim.enable = lib.mkOption {
      description = "Whether to install neovim, a modal text editor.";
      type = lib.types.bool;
      default = false;
    };
  };
  config = lib.mkIf config.sys.neovim.enable (let
    essence-vim = pkgs.vimUtils.buildVimPlugin {
      name = "essence.vim";
      src = pkgs.fetchFromGitHub {
        owner = "niklasdewally";
        repo = "conjure.nvim";
        rev = "d3c33d881aace32b636a2393afa595ff7b75d1c4";
        sha256 = "sha256-0DA7gS6N827U+pszXfJ29kC3Q6+RBNhECbsfc2CWi8s=";
      };
    };
    vim-angry = pkgs.vimUtils.buildVimPlugin {
      name = "vim-angry";
      src = pkgs.fetchFromGitHub {
        owner = "b4winckler";
        repo = "vim-angry";
        rev = "08e9e9a50e6683ac7b0c1d6fddfb5f1235c75700";
        sha256 = "0cxfvzlka0pgqs2ij4vwfv97yqks2ncnzk86a5psv985i8qmba30";
      };
    };
    vim-buffet = pkgs.vimUtils.buildVimPlugin {
      name = "vim-buffet";
      src = pkgs.fetchFromGitHub {
        owner = "bagrat";
        repo = "vim-buffet";
        rev = "3ee5c836cd7ded3526902122e06110cd3f8549cb";
        sha256 = "sha256-cyZN06Dn+qaL5AjbZfBZIj9Est7b+Q8BYemmWpCt7Gs=";
      };
    };
    vim-crystalline = pkgs.vimUtils.buildVimPlugin {
      name = "vim-crystalline";
      src = pkgs.fetchFromGitHub {
        owner = "rbong";
        repo = "vim-crystalline";
        rev = "3d1b744439f5fcdae9b58d58639fc85c37e1e0a6";
        sha256 = "sha256-XvEPEBCvJIocIu12ZF8aqncjoBd2H4JX365MnvsD3zI=";
      };
    };
    vim-gml = pkgs.vimUtils.buildVimPlugin {
      name = "vim-gml";
      src = pkgs.fetchFromGitHub {
        owner = "JafarDakhan";
        repo = "vim-gml";
        rev = "382f7aecf6da88c077f34df2f863e750b4d0fdd3";
        sha256 = "sha256-xIchBiNEZbrz0LRIWorJEac8y4DBa4akuM4JPqM0Yp4=";
      };
    };
    vim-pythonsense = pkgs.vimUtils.buildVimPlugin {
      name = "vim-pythonsense";
      src = pkgs.fetchFromGitHub {
        owner = "jeetsukumaran";
        repo = "vim-pythonsense";
        rev = "9200a57629c904ed2ab8c9b2e8c5649d311794ba";
        sha256 = "1m2qz3j05f3y99wjjcnkhbpj8j3hdsnwjc33skzldv5khspg011d";
      };
    };
    vim-textobj-line = pkgs.vimUtils.buildVimPlugin {
      name = "vim-textobj-line";
      src = pkgs.fetchFromGitHub {
        owner = "kana";
        repo = "vim-textobj-line";
        rev = "1a6780d29adcf7e464e8ddbcd0be0a9df1a37339";
        sha256 = "sha256-h7c6PMg4rJMH1f+NibOuQW/ComTmtCMpkCqntezwKTY=";
      };
    };
    vim-textobj-quote = pkgs.vimUtils.buildVimPlugin {
      name = "vim-textobj-quote";
      src = pkgs.fetchFromGitHub {
        owner = "preservim";
        repo = "vim-textobj-quote";
        rev = "e99ad285c950576a394a64ff334106b32b23418a";
        sha256 = "sha256-SkQavbxgq9WSeoZZnwRWHaHtku82xdgBjHrTz02kNKk=";
      };
    };
  in {
    home.sessionVariables.EDITOR = "nvim";
    # https://stackoverflow.com/a/61368522/5951320
    xdg.configFile."nvim/after/syntax/nix.vim".text = ''
      syntax match nixFunctionCall /lib\.\&lib/ conceal cchar=𝕃
      syntax match nixFunctionCall /pkgs\.\&pkgs/ conceal cchar=ℙ
      syntax match nixFunctionCall /builtins\.\&builtins/ conceal cchar=𝔹
      syntax match nixFunctionCall /unstable\.\&unstable/ conceal cchar=𝕌
    '';
    xdg.configFile."nvim/after/ftplugin/rust.vim".text = ''
      nnoremap <buffer> <leader>f :call rustfmt#Format()<CR>
    '';
    programs.neovim = {
      enable = true;
      extraConfig = builtins.readFile ./init.vim;
      plugins = with pkgs.vimPlugins; [
        # Tim Pope
        vim-commentary
        vim-eunuch
        vim-fugitive
        vim-repeat
        vim-scriptease
        vim-sensible
        vim-sleuth
        vim-speeddating
        vim-surround
        # Appearance
        {
          plugin = gruvbox-community;
          config = ''
            " https://github.com/gruvbox-community/gruvbox/pull/201#issuecomment-2867888183
            augroup my_gruvbox_colors
              au!
              autocmd ColorScheme gruvbox hi! Normal guibg=NONE ctermbg=NONE
            augroup END
            let g:gruvbox_italic = 1
            let g:gruvbox_contrast_light = 'hard'
            let g:gruvbox_contrast_dark = 'hard'
            let g:gruvbox_invert_selection = 0
            colorscheme gruvbox
          '';
        }
        {
          plugin = vim-buffet;
          config = ''
            " Set up custom colours for vim-buffet.
            function! s:gruvbox(x)
              return synIDattr(hlID(a:x), 'fg')
            endfunction
            function! g:BuffetSetCustomColors()
              exec 'hi! BuffetCurrentBuffer guifg='.s:gruvbox('GruvboxBg0').' guibg='.s:gruvbox('GruvboxFg4')
              exec 'hi! BuffetActiveBuffer guifg='.s:gruvbox('GruvboxFg4').' guibg='.s:gruvbox('GruvboxBg2')
              exec 'hi! BuffetBuffer guifg='.s:gruvbox('GruvboxFg4').' guibg='.s:gruvbox('GruvboxBg2')
              hi! link BuffetModCurrentBuffer BuffetCurrentBuffer
              hi! link BuffetModActiveBuffer BuffetActiveBuffer
              hi! link BuffetModBuffer BuffetBuffer
              exec 'hi! BuffetTrunc guifg='.s:gruvbox('GruvboxBg4').' guibg='.s:gruvbox('GruvboxBg1')
              exec 'hi! BuffetTab guifg='.s:gruvbox('GruvboxBg2').' guibg='.s:gruvbox('GruvboxBlue')
            endfunction
          '';
        }
        {
          plugin = vim-crystalline;
          config = ''
            function! g:CrystallineGroupSuffix()
              if mode() ==# 'i' && &paste
                return '2'
              endif
              if &modified
                return '1'
              endif
              return ""
            endfunction
            function! g:CrystallineStatuslineFn(winnr)
              let l:s = ""
              let l:current = a:winnr == winnr()
              let l:width = winwidth(a:winnr)
              let g:crystalline_group_suffix = g:CrystallineGroupSuffix()
              if l:current
                let l:s .= crystalline#ModeSection(0, 'A', 'B')
              else
                let l:s .= crystalline#HiItem('Fill')
              endif
              let l:s .= ' %f%h%w%m%r '
              if l:current
                let l:s .= crystalline#Sep(0, 'B', 'Fill') . ' %{FugitiveHead()}'
              endif
              let l:s .= '%='
              if l:current
                let l:s .= crystalline#Sep(1, 'Fill', 'B') . ' %{&paste ?"PASTE ":""}%{&spell?"SPELL ":""}'
                let l:s .= crystalline#Sep(1, 'B', 'A')
              endif
              if l:width > 80
                let l:s .= ' %{&ft}[%{&fenc!=#""?&fenc:&enc}][%{&ff}] %l/%L %c%V %P '
              else
                let l:s .= ' '
              endif
              return l:s
            endfunction
            function! g:CrystallineTablineFn()
              let l:max_width = &columns
              let l:right = '%='
              let l:right .= crystalline#Sep(1, 'TabFill', 'TabType')
              let l:max_width -= 1
              let l:vimlabel = has('nvim') ?  ' NVIM ' : ' VIM '
              let l:right .= l:vimlabel
              let l:max_width -= strchars(l:vimlabel)
              return crystalline#DefaultTabline({'enable_sep': 1, 'max_width': l:max_width}) . l:right
            endfunction
            let g:crystalline_theme = 'gruvbox'
            set showtabline=2
            set guioptions-=e
            set laststatus=2
            set noshowmode
          '';
        }
        essence-vim
        vim-gml
        vim-just
        # Text objects
        vim-angry
        {
          plugin = vim-pythonsense;
          config = ''
            " Disable the vim-pythonsense keymaps, so we can enable just the docstring text object.
            let g:is_pythonsense_suppress_keymaps = 1
          '';
        }
        vim-textobj-comment
        vim-textobj-entire
        vim-textobj-line
        {
          plugin = vim-textobj-quote;
          config = ''
            let g:textobj#quote#educate = 0
            augroup textobj_quote
              au!
              au FileType * call textobj#quote#init()
            augroup END
          '';
        }
        vim-textobj-user
        # Keybinds
        conflict-marker-vim
        {
          plugin = ctrlp;
          config = ''
            " Make CtrlP ignore files that Git ignores, when in a Git repository.
            let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']
            " When not in a Git repository, don't show uninteresting stuff.
            let g:ctrlp_custom_ignore = '\v\.(aux|fdb_latexmk|fls|mypy_cache)$'
            " Do show hidden files (when ctrlp_user_command doesn't apply).
            let g:ctrlp_show_hidden = 1
          '';
        }
        {
          plugin = splitjoin-vim;
          config = ''
            let g:splitjoin_trailing_comma = 1
            let g:splitjoin_python_brackets_on_separate_lines = 1
          '';
        }
        vim-table-mode
        # Behaviour
        editorconfig-vim
        {
          plugin = pear-tree;
          config = ''
            " Stop pear-tree unpredictably erasing brackets, we don't care about repeating that much.
            let g:pear_tree_repeatable_expand = 0
            " Do be clever about maintaining balance.
            let g:pear_tree_smart_openers = 1
            let g:pear_tree_smart_closers = 1
            let g:pear_tree_smart_backspace = 1
          '';
        }
        {
          plugin = vim-gitgutter;
          config = ''
            " Disable the vim-gitgutter keymaps, we will enable the interesting ones ourselves.
            let g:gitgutter_map_keys = 0
            " Slimmed-down and modified mappings from vim-gitgutter.
            nmap ]h <plug>(GitGutterNextHunk)
            nmap [h <plug>(GitGutterPrevHunk)
            nmap <leader>hs <plug>(GitGutterStageHunk)
            nmap <leader>hu <plug>(GitGutterUndoHunk)
            omap ih <Plug>(GitGutterTextObjectInnerPending)
            omap ah <Plug>(GitGutterTextObjectOuterPending)
            xmap ih <Plug>(GitGutterTextObjectInnerVisual)
            xmap ah <Plug>(GitGutterTextObjectOuterVisual)
          '';
        }
        {
          plugin = vim-rooter;
          config = ''
            " Stop vim-rooter echoing the working directory it's changing to.
            let g:rooter_silent_chdir = 1
          '';
        }
        # LSP support
        {
          # using unstable.vimPlugins.nvim-lspconfig silently fails
          # https://github.com/NixOS/nixpkgs/pull/136429
          # https://github.com/NixOS/nixpkgs/issues/138084
          plugin = nvim-lspconfig;
          config = ''
            lua <<EOF
            require'lspconfig'.pyright.setup{}
            require'lspconfig'.nil_ls.setup{}
            -- NB: as of 2022-11-06, elixirls, r_language_server, and rnix have some root_dir brokenness, fixed by something like:
            -- require'lspconfig'.rnix.setup{
            --   -- fix the default use of $HOME as root_dir ($PWD is probably more sensible)
            --   root_dir = function(fname)
            --     return require'lspconfig.util'.find_git_ancestor(fname) or vim.fn.getcwd()
            --   end,
            -- }
            EOF
          '';
        }
        cmp-buffer
        cmp-nvim-lsp
        cmp-path
        cmp-vsnip
        {
          plugin = vim-vsnip;
          config = ''
            imap <expr> <Tab> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<Tab>'
            smap <expr> <Tab> vsnip#jumpable(1) ? '<Plug>(vsnip-jump-next)' : '<Tab>'
            imap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>'
            smap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>'
          '';
        }
        {
          plugin = crates-nvim;
          config = ''
            lua require'crates'.setup{popup={autofocus=true}}
          '';
        }
        nvim-cmp
        plenary-nvim
        {
          plugin = rustaceanvim;
          config = ''
            lua <<EOF
            vim.g.rustaceanvim = {
              tools = {
                float_win_config = {
                  auto_focus = true,
                },
              },
            }
            EOF
          '';
        }
        # Linting
        {
          plugin = nvim-lint;
          config = ''
            lua <<EOF
            require'lint'.linters_by_ft = {
              sh = {'shellcheck',},
              bash = {'shellcheck',},
            }
            EOF
            au BufWritePost,CursorHold,CursorHoldI <buffer> lua require'lint'.try_lint()
          '';
        }
      ];
      extraPackages = with pkgs; [
        pyright
        shellcheck
      ];
    };
    home.packages = [
      pkgs.nil
      (
        (pkgs.writeShellScriptBin "nvim" ''
          theme=$(${pkgs.termtheme}/bin/termtheme --force)
          case $theme in
            light|dark)
              ${config.programs.neovim.finalPackage}/bin/nvim --cmd "set bg=$theme" "$@"
              ;;
            *)
              ${config.programs.neovim.finalPackage}/bin/nvim "$@"
              ;;
          esac
        '').overrideAttrs (old: {
          meta = (old.meta or {}) // {
            priority = config.programs.neovim.finalPackage.meta.priority - 1;
          };
        })
      )
    ];
  });
}
