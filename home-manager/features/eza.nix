{ ... }:
{
  _description = "eza (modern ls replacement)";
  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
  };
}
