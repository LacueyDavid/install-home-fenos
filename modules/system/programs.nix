{ pkgs, ... }:
{
  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "seth" ];
  };

  environment.systemPackages = with pkgs; [
    curl
    fd
    git
    htop
    neovim
    networkmanager
    psmisc
    ripgrep
    wget
  ];
}
