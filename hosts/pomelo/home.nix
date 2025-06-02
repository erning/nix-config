{
  config,
  lib,
  pkgs,
  inputs,
  settings,
  ...
}:

let
  features = import "${inputs.self}/lib/features.nix" { inherit lib; };
  ssh-key = (import "${inputs.self}/lib/ssh-key.nix" { inherit config inputs; }) settings.host;
in
{
  imports = [
    (ssh-key "id_ed25519")
  ];

  features = lib.mkMerge [
    features.console
    features.desktop
    features.develop
  ];

  home.packages = with pkgs; [
    ffmpeg
    yt-dlp
  ];

  home.sessionVariables = {
    HOMEBREW_PREFIX = "/home/linuxbrew/.linuxbrew";

    # HOMEBREW_VERBOSE = 1
    HOMEBREW_NO_ANALYTICS = 1;
    HOMEBREW_NO_AUTO_UPDATE = 1;
    HOMEBREW_AUTO_UPDATE_SECS = 86400;
    HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK = 1;
    HOMEBREW_CURL_RETRIES = 3;

    HOMEBREW_MIRROR_PREFIX = "https://mirrors.ustc.edu.cn";
    HOMEBREW_BOTTLE_DOMAIN = "${config.home.sessionVariables.HOMEBREW_MIRROR_PREFIX}/homebrew-bottles";
    # HOMEBREW_BREW_GIT_REMOTE = "$HOMEBREW_MIRROR_PREFIX/brew.git"
    # HOMEBREW_CORE_GIT_REMOTE = "$HOMEBREW_MIRROR_PREFIX/homebrew-core.git"
  };

  home.sessionPath = [
    "$HOMEBREW_PREFIX/bin"
    "$HOMEBREW_PREFIX/sbin"
  ];
}
