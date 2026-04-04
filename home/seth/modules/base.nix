{ pkgs, ... }:
{
  xdg.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "kitty";
    BROWSER = "firefox";
    NIXOS_OZONE_WL = "1";
  };

  programs.git = {
    enable = true;
    userName = "seth";
    userEmail = "seth@example.com";
    lfs.enable = true;
    delta.enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      rebase.autoStash = true;
      rerere.enabled = true;
      core.editor = "nvim";
    };
    aliases = {
      s = "status -sb";
      c = "commit";
      a = "add";
      sw = "switch";
      tree = "log --graph --abbrev-commit --decorate --oneline --all";
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

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[>](bold green)";
        error_symbol = "[>](bold red)";
      };
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      save = 50000;
      size = 50000;
      ignoreDups = true;
      ignoreSpace = true;
      path = "$HOME/.local/state/zsh/history";
    };

    shellAliases = {
      v = "nvim";
      ls = "eza --group-directories-first";
      ll = "eza -lah --git --group-directories-first";
      lt = "eza --tree --level=2 --git-ignore";
      cat = "bat";
      grep = "rg";
      nrs = "sudo nixos-rebuild switch --flake /etc/nixos#default";
      nrt = "sudo nixos-rebuild test --flake /etc/nixos#default";
      fenos-switch = "sudo nixos-rebuild switch --flake /home/seth/work/nixos-project/feninstall-home#pc";
      fenos-test = "sudo nixos-rebuild test --flake /home/seth/work/nixos-project/feninstall-home#pc";
      fss = "sudo nixos-rebuild switch --flake /home/seth/work/nixos-project/feninstall-home#pc";
      fst = "sudo nixos-rebuild test --flake /home/seth/work/nixos-project/feninstall-home#pc";
      switch = "sudo nixos-rebuild switch --flake /home/seth/work/nixos-project/feninstall-home#pc";
    };

    initContent = ''
      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word
      bindkey '^H' backward-kill-word
    '';
  };

  home.packages = with pkgs; [
    alejandra
    bash-language-server
    clang-tools
    fd
    gh
    jq
    lua-language-server
    nil
    nixd
    nodePackages.prettier
    ripgrep
    ruff
    shellcheck
    shfmt
    stylua
    tree
    unzip
    wget
    zip
  ];
}
