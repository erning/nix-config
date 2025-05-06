{ config, pkgs, ... }:

{
  home.sessionVariables = {
    HOMEBREW_PREFIX = if pkgs.stdenv.hostPlatform.isAarch64 then "/opt/homebrew" else "/usr/local";

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
