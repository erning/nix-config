{ pkgs, ... }:
{
  _description = "fonts - Maple Mono (Nerd Font, with and without CN)";

  home.packages = with pkgs.unstable; [
    maple-mono.NF-CN
    maple-mono.NL-NF-CN
    maple-mono.Normal-NF-CN
    maple-mono.NormalNL-NF-CN
    maple-mono.NF
    maple-mono.NL-NF
    maple-mono.Normal-NF
    maple-mono.NormalNL-NF
  ];
}
