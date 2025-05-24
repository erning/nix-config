{
  description = "";

  # # the nixConfig here only affects the flake itself, not the system configuration!
  # nixConfig = {
  #   # substituers will be appended to the default substituters when fetching packages
  #   # nix com    extra-substituters = [munity's cache server
  #   extra-substituters = [
  #     "https://mirrors.ustc.edu.cn/nix-channels/store"
  #     "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
  #     "https://nix-community.cachix.org"
  #   ];
  # };

  inputs = {
    # stable
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";
    nix-darwin-stable.url = "github:lnl7/nix-darwin/nix-darwin-25.05";
    nix-darwin-stable.inputs.nixpkgs.follows = "nixpkgs-stable";
    home-manager-stable.url = "github:nix-community/home-manager/release-25.05";
    home-manager-stable.inputs.nixpkgs.follows = "nixpkgs-stable";

    # unstable
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-darwin-unstable.url = "github:lnl7/nix-darwin/master";
    nix-darwin-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";
    home-manager-unstable.url = "github:nix-community/home-manager/master";
    home-manager-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";

    #
    agenix.url = "github:ryantm/agenix";

    secrets = {
      url = "git+ssh://git@github.com/erning/nix-secrets.git?shallow=1";
      flake = false;
    };
  };

  outputs =
    { self, ... }@inputs:
    let
      nixpkgs = inputs.nixpkgs-unstable;
      nix-darwin = inputs.nix-darwin-unstable;
      home-manager = inputs.home-manager-unstable;

      mkSystem = import ./lib/mkSystem.nix { inherit nixpkgs nix-darwin inputs; };
      mkHome = import ./lib/mkHome.nix { inherit nixpkgs home-manager inputs; };
    in
    {
      darwinConfigurations."dragon" = mkSystem {
        host = "dragon";
        system = "aarch64-darwin";
      };

      homeConfigurations."erning@dragon" = mkHome {
        user = "erning";
        host = "dragon";
        system = "aarch64-darwin";
      };

      nixosConfigurations."phoenix" = mkSystem {
        host = "phoenix";
        system = "x86_64-linux";
      };

      homeConfigurations."erning@phoenix" = mkHome {
        user = "erning";
        host = "phoenix";
        system = "x86_64-linux";
      };

      homeConfigurations."erning@dinosaur" = mkHome {
        user = "erning";
        host = "dinosaur";
        system = "x86_64-linux";
      };

      #
      #
      #

      nixosConfigurations."orb-aarch64" = mkSystem {
        host = "orbstack";
        system = "aarch64-linux";
      };

      homeConfigurations."erning@orb-aarch64" = mkHome {
        user = "erning";
        host = "orbstack";
        system = "aarch64-linux";
      };

      nixosConfigurations."vm-aarch64" = mkSystem {
        host = "vmfusion";
        system = "aarch64-linux";
      };

      homeConfigurations."erning@vm-aarch64" = mkHome {
        user = "erning";
        host = "vmfusion";
        system = "aarch64-linux";
      };

      #
      #
      #

      darwinConfigurations."pineapple" = mkSystem {
        host = "pineapple";
        system = "x86_64-darwin";
      };

      homeConfigurations."erning@pineapple" = mkHome {
        user = "erning";
        host = "pineapple";
        system = "x86_64-darwin";
      };

      darwinConfigurations."mango" = mkSystem {
        host = "mango";
        system = "x86_64-darwin";
      };

      homeConfigurations."erning@mango" = mkHome {
        user = "erning";
        host = "mango";
        system = "x86_64-darwin";
      };
    };
}
