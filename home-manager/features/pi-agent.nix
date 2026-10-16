{ config, ... }:
{
  _description = "pi coding agent model configuration";

  # auth.json is intentionally not managed: subscription/OAuth providers write
  # tokens into it at login time, so it must stay a regular, writable file
  # rather than a nix-managed one.
  home.file = config.lib.dotfiles.homeFiles [
    ".pi/agent/models.magpie.json"
  ];
}
