{
  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";
  nix.settings.substituters = [
    "https://mirrors.ustc.edu.cn/nix-channels/store"
    "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
  ];
}
