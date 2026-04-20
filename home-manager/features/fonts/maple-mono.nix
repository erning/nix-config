{ pkgs, ... }:
{
  _description = "fonts - Maple Mono NF CN (ligature + Normal variants)";

  home.packages = with pkgs.unstable; [
    maple-mono.NF-CN
    # Alternate: traditional glyph shapes (a, g, i, l, @ ...) baked in — use
    # directly in apps that don't support font-feature settings (cv01/cv35/...)
    maple-mono.Normal-NF-CN
  ];
}
