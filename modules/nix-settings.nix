{ lib, settings, ... }:
{
  # Necessary for using flakes on this system.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.extra-substituters = [
    "https://mirror.sjtu.edu.cn/nix-channels/store?priority=11"
    "https://mirrors.nju.edu.cn/nix-channels/store?priority=12"
    "https://mirrors.bfsu.edu.cn/nix-channels/store?priority=13"
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=14"
  ];
  nix.settings.trusted-users =
    lib.optional settings.isLinux "@wheel" ++ lib.optional settings.isDarwin "@admin";
  nix.settings.download-buffer-size = 67108864;
}
