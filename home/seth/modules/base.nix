{ config, pkgs, ... }:
{
  xdg.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "kitty";
    BROWSER = "firefox";
    NIXOS_OZONE_WL = "1";
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
  };

  home.sessionPath = [ "$HOME/.npm-global/bin" ];

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user.name = "seth";
      user.email = "seth@example.com";
      init.defaultBranch = "main";
      pull.rebase = true;
      rebase.autoStash = true;
      rerere.enabled = true;
      core.editor = "nvim";
      alias = {
        s = "status -sb";
        c = "commit";
        a = "add";
        sw = "switch";
        tree = "log --graph --abbrev-commit --decorate --oneline --all";
      };
    };
    ignores = [
      ".DS_Store"
      ".direnv"
      ".idea"
      ".vscode"
      "*.swp"
      "result"
    ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.bat.enable = true;

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    git = true;
    icons = "auto";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.firefox = { enable = true;};

  programs.zsh = {
    enable = true;
    dotDir = config.home.homeDirectory;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    sessionVariables = {
      ZSH_AUTOSUGGEST_USE_ASYNC = true;
      ZSH_AUTOSUGGEST_MANUAL_REBIND = true;
      ZSH_AUTOSUGGEST_STRATEGY = [ "history" "completion" ];
      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=#8b545d,bold";
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
    ];

    history = {
      save = 50000;
      size = 50000;
      ignoreDups = true;
      ignoreSpace = true;
      path = "$HOME/.local/state/zsh/history";
    };

    shellAliases = {
      v = "nvim";
      l = "eza --group-directories-first --icons=auto";
      ls = "l";
      ll = "l -lah --git";
      la = "l -a";
      lal = "l -la";
      lt = "eza --tree --level=2 --git-ignore";
      cat = "bat";
      grep = "rg";
      cd = "cdls";
      gdu = "gdu -c";
      make = "bear -- make";
      valgrind = "valgrind --leak-check=full --show-leak-kinds=all -s";
      gcl = "git clone";
      gitconf = "git config --global --edit";
      edit = "sudoedit";
      nixconf = "cd /etc/nixos && sudo su";
      pixel = "xcolor";
      see = "mupdf";
      t = "tmux";
      gotop = "btop";
      colist = "nmcli dev wifi list";
      coto = "nmcli dev wifi connect";
      nrs = "sudo nixos-rebuild switch --flake /etc/nixos#default";
      nrt = "sudo nixos-rebuild test --flake /etc/nixos#default";
      qs = "quickshell -c ii";
      fenos-switch = "fenos_switch";
      fenos-test = "fenos_test";
      fss = "fenos_switch";
      fst = "fenos_test";
      switch = "fenos_switch";
      upower = "sudo upower -i /org/freedesktop/UPower/devices/battery_BAT0";
      ssh = "TERM=xterm-kitty ssh";
    };

    initContent = ''
      cdls() {
        if [[ -n "$1" ]]; then
          cd "$1"
        else
          cd
        fi
        eza --group-directories-first --icons=auto
      }

      fenos_flake_path() {
        local candidates
        candidates=(
          "''${FENOS_FLAKE_PATH:-}"
          "/etc/nixos"
          "$HOME/work/nixos-project/feninstall-home"
          "$HOME/nixos-project/feninstall-home"
        )

        local p
        for p in "''${candidates[@]}"; do
          if [[ -n "$p" && -f "$p/flake.nix" ]]; then
            printf "%s" "$p"
            return 0
          fi
        done

        return 1
      }

      fenos_switch() {
        local flake
        flake="$(fenos_flake_path)" || {
          echo "fenos: unable to locate flake. Set FENOS_FLAKE_PATH first."
          return 1
        }
        sudo nixos-rebuild switch --flake "$flake#pc"
      }

      fenos_test() {
        local flake
        flake="$(fenos_flake_path)" || {
          echo "fenos: unable to locate flake. Set FENOS_FLAKE_PATH first."
          return 1
        }
        sudo nixos-rebuild test --flake "$flake#pc"
      }

      sudo-command-line() {
        [[ -z $BUFFER ]] && zle up-history
        if [[ $BUFFER != sudo\ * ]]; then
          BUFFER="sudo $BUFFER"
          CURSOR=$(( CURSOR + 5 ))
        fi
      }
      zle -N sudo-command-line
      bindkey '^s' sudo-command-line

      # Disable flow control so Ctrl+S works for zsh widgets.
      stty -ixon

      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi

      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      # Load secrets (ANTHROPIC_API_KEY, etc.) from an untracked file.
      # Create ~/.secrets/anthropic.env with: export ANTHROPIC_API_KEY=sk-ant-...
      [[ -f ~/.secrets/anthropic.env ]] && source ~/.secrets/anthropic.env

      bindkey -e
      bindkey -s '^[e' 'v\n'

      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word
      bindkey '^H' backward-kill-word
    '';
  };

  home.packages = with pkgs; [
    alejandra
    bash-language-server
    bear
    btop
    clang-tools
    claude-code-bin
    fd
    gh
    jq
    mupdf
    lua-language-server
    nil
    nixd
    norminette
    prettier
    ripgrep
    ruff
    shellcheck
    shfmt
    stylua
    tmux
    tree
    unzip
    upower
    valgrind
    wget
    xcolor
    zip
    telegram-desktop
    vscode
    nodejs_22
  ];
}
