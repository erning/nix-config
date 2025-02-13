{ config, inputs, ... }:

{
  features = {
    fonts.enable = true;

    tmux.enable = true;
    neovim.enable = true;

    build-essential.enable = true;
    nix-support.enable = true;
    rustup.enable = true;
    zig.enable = true;
  };

  age.secrets."ssh/erning/vm/id_ed25519" = {
    file = "${inputs.secrets}/ssh/erning/vm/id_ed25519.age";
    path = "${config.home.homeDirectory}/.ssh/id_ed25519";
    mode = "600";
  };
  home.file.".ssh/id_ed25519.pub".source = "${inputs.secrets}/ssh/erning/vm/id_ed25519.pub";
}

