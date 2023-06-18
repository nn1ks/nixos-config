{ config, pkgs, pkgs-unstable, ... }:

{
  home.packages = with pkgs; [
    curl
    wget
    htop
    btop
    tree
    ripgrep
    fd
    jq
  ];

  programs = {
    bash = {
      enable = true;
      shellAliases = {
        ls = "ls -p --color=auto";
        grep = "grep --color=auto";
        mv = "mv --interactive";
        cp = "cp --interactive";
        ln = "ln --interactive";
      };
      sessionVariables = {
        PATH = "\"$HOME/.local/bin:$PATH\"";
        LV2_PATH = "/etc/profiles/per-user/\"$USER\"/lib/lv2"; # LV2 audio plugins
      };
      bashrcExtra = ''source ~/.config/nixos/data/git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM=auto
prompt() {
    local status="$?"
    local directory="\[\e[1;34m\]\w\[\e[0m\]"
    local git="$(__git_ps1 ' \[\e[1;36m\] %s\[\e[0m\]')"
    if [ -n "$IN_NIX_SHELL" ]; then
        local env=" [env]"
    fi
    if [ "$status" = "0" ]; then
        local indicator=" \[\e[1;32m\]$\[\e[0m\]"
    else
        local indicator=" \[\e[1;31m\]$\[\e[0m\]"
    fi
    PS1="''${directory}''${git}''${env}''${indicator} "
}
PROMPT_COMMAND=prompt'';
    };

    git = {
      enable = true;
      userName = "Niklas Sauter";
      userEmail = "niklas@n1ks.net";
      extraConfig = {
        core.ignorecase = false;
        pull.ff = "only";
        status.short = true;
        log.date = "format:%Y-%m-%d %H:%M:%S %z (%A)";
        github.user = "nn1ks";
      };
      aliases = {
        a = "add";
        c = "commit";
        d = "diff";
        l = "log";
        g = "log --all --graph --decorate --oneline";
        s = "status";
      };
    };

    gitui.enable = true;

    tmux = {
      enable = true;
      extraConfig = ''
set -g escape-time 0

set -g status-right ""

# Toggle status bar
bind-key t set-option -g status

# Enable mouse support
set -g mouse on'';
      plugins = with pkgs; [
        tmuxPlugins.resurrect
        tmuxPlugins.yank
      ];
    };

    helix = {
      enable = true;
      package = pkgs-unstable.helix;
      settings = {
        theme = "autumn_night";
        editor = {
          line-number = "relative";
          idle-timeout = 100;
          cursor-shape = {
            insert = "bar";
            normal = "block";
            select = "underline";
          };
          file-picker.hidden = false;
        };
        keys.normal = {
          "ü" = "insert_mode";
          "C-l" = "page_up";
          "C-k" = "page_down";
          "j" = "move_char_left";
          "k" = "move_line_down";
          "l" = "move_line_up";
          "ö" = "move_char_right";
          "h" = "open_below";
          "H" = "open_above";
          "minus" = "search_next";
          "_" = "search_prev";
          # Colemak
          "esc" = "insert_mode";
          "n" = "move_char_left";
          "e" = "move_line_down";
          "i" = "move_line_up";
          "o" = "move_char_right";
          "C-i" = "page_up"; # FIXME
          "C-e" = "page_down";

          "g" = {
            "j" = "goto_line_start";
            "l" = "goto_file_start";
            "k" = "goto_file_end";
            "ö" = "goto_line_end";
            # Colemak
            "n" = "goto_line_start";
            "i" = "goto_file_start";
            "e" = "goto_file_end";
            "o" = "goto_line_end";
          };

          "space" = {
            "c" = "toggle_comments";
            "s" = ":write";
            "z" = "symbol_picker";
            "Z" = "workspace_symbol_picker";
          };
          "space"."w" = {
            "j" = "jump_view_left";
            "k" = "jump_view_down";
            "l" = "jump_view_up";
            "ö" = "jump_view_right";
            "J" = "swap_view_left";
            "K" = "swap_view_down";
            "L" = "swap_view_up";
            "Ö" = "swap_view_right";
            # Colemak
            "n" = "jump_view_left";
            "e" = "jump_view_down";
            "i" = "jump_view_up";
            "o" = "jump_view_right";
            "N" = "swap_view_left";
            "E" = "swap_view_down";
            "I" = "swap_view_up";
            "O" = "swap_view_right";
          };
        };

        keys.select = {
          "ü" = "insert_mode";
          "C-l" = "page_up";
          "C-k" = "page_down";
          "j" = "extend_char_left";
          "k" = "extend_line_down";
          "l" = "extend_line_up";
          "ö" = "extend_char_right";
          "h" = "open_below";
          "H" = "open_above";
          "minus" = "search_next";
          "_" = "search_prev";
          # Colemak
          "esc" = "insert_mode";
          "n" = "extend_char_left";
          "e" = "extend_line_down";
          "i" = "extend_line_up";
          "o" = "extend_char_right";
          "C-i" = "page_up"; # FIXME
          "C-e" = "page_down";

          "g" = {
            "j" = "goto_line_start";
            "l" = "goto_file_start";
            "k" = "goto_file_end";
            "ö" = "goto_line_end";
            # Colemak
            "n" = "goto_line_start";
            "i" = "goto_file_start";
            "e" = "goto_file_end";
            "o" = "goto_line_end";
          };

          "space" = {
            "c" = "toggle_comments";
            "s" = ":write";
            "z" = "symbol_picker";
            "Z" = "workspace_symbol_picker";
          };
        };

        keys.insert = {
          "ü" = "normal_mode";
        };
      };
    };
  };
}
