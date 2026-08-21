{ config, ... }:
{
  _description = "pi coding agent config with rspass-backed API keys";

  # auth.json is intentionally not symlinked: subscription/OAuth providers
  # write tokens into it at login time, so it must stay a regular, writable
  # file rather than a nix-managed one. API-key providers are configured via
  # auth.env instead, sourced by the .local/bin/pi wrapper below.
  home.file = config.lib.dotfiles.homeFiles [
    ".pi/agent/auth.env"
  ];
}
