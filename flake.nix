{
  description = "Home Manager configuration of erning";

  inputs = {
    # stable
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
    nix-darwin-stable.url = "github:lnl7/nix-darwin/nix-darwin-24.11";
    nix-darwin-stable.inputs.nixpkgs.follows = "nixpkgs-stable";
    home-manager-stable.url = "github:nix-community/home-manager/release-24.11";
    home-manager-stable.inputs.nixpkgs.follows = "nixpkgs-stable";

    # unstable
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-darwin-unstable.url = "github:lnl7/nix-darwin/master";
    nix-darwin-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";
    home-manager-unstable.url = "github:nix-community/home-manager/master";
    home-manager-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # secrets
    agenix.url = "github:ryantm/agenix";

    secrets = {
      url = "git+ssh://git@github.com/erning/nix-secrets.git";
      flake = false;
    };
  };

  outputs =
    { self, ... }@inputs:
    let
      nixpkgs = inputs.nixpkgs-unstable;
      nix-darwin = inputs.nix-darwin-unstable;
      home-manager = inputs.home-manager-unstable;
      config = self;

      mkSystem = import ./lib/mkSystem.nix {
        inherit nixpkgs;
        inherit nix-darwin;
        inherit inputs;
        inherit config;
      };

      mkHomeSystem = import ./lib/mkHomeSystem.nix {
        inherit nixpkgs;
        inherit nix-darwin;
        inherit home-manager;
        inherit inputs;
        inherit config;
      };

      mkHome = import ./lib/mkHome.nix {
        inherit nixpkgs;
        inherit nix-darwin;
        inherit home-manager;
        inherit inputs;
        inherit config;
      };
    in
    {
      #
      # dragon
      #
      darwinConfigurations."dragon" = mkSystem {
        host = "dragon";
        system = "aarch64-darwin";
      };

      homeConfigurations."erning@dragon" = mkHome {
        user = "erning";
        host = "dragon";
        system = "aarch64-darwin";
      };

      #
      # phoenix
      #
      nixosConfigurations."erning@phoenix" = mkHomeSystem {
        user = "erning";
        host = "phoenix";
        system = "x86_64-linux";
      };

      #
      # pineapple
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

      #
      # mango
      #
      darwinConfigurations."erning@mango" = mkHomeSystem {
        user = "erning";
        host = "mango";
        system = "x86_64-darwin";
      };

      #
      # orbstack
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

      nixosConfigurations."erning@orb-aarch64" = mkHomeSystem {
        user = "erning";
        host = "orbstack";
        system = "aarch64-linux";
      };

      #
      # vmware
      #
      nixosConfigurations."erning@vm-aarch64" = mkHomeSystem {
        user = "erning";
        host = "vmfusion";
        system = "aarch64-linux";
      };
    };
}
