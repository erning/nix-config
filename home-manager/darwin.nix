{ lib, ... }:
{
  # Suppress warning: generateCaches has no effect when package is null (Darwin)
  # Fish sets generateCaches = true by default, but macOS uses system man (package = null)
  programs.man.generateCaches = lib.mkForce false;
}
