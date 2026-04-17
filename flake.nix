{
  description = "Personal NixOS and nix-darwin flake for macOS, Linux, VMs, and home-manager-only hosts";

  # nixConfig here only affects the flake itself (evaluation-time fetches),
  # not the system configuration. System-level mirrors live in
  # modules/nix-settings.nix. priority=10/11 keeps mirrors ahead of
  # cache.nixos.org (priority 40).
  nixConfig = {
    extra-substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store?priority=10"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=11"
    ];
  };

  inputs = {
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    # stable
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    nix-darwin-stable = {
      url = "github:lnl7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    home-manager-stable = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    # pinned for legacy macOS (Monterey, Big Sur 11.3+)
    nixpkgs-2505.url = "github:nixos/nixpkgs/nixos-25.05";
    nix-darwin-2505 = {
      url = "github:lnl7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs-2505";
    };
    home-manager-2505 = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs-2505";
    };

    # unstable
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs-unstable.url = "github:nixos/nixpkgs/master";
    nix-darwin-unstable = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    #
    agenix.url = "github:ryantm/agenix";

    secrets = {
      url = "git+ssh://git@github.com/erning/nix-secrets.git?shallow=1";
      flake = false;
    };
  };

  outputs =
    { ... }@inputs:
    let
      series = {
        default = {
          nixpkgs = inputs.nixpkgs-unstable;
          nix-darwin = inputs.nix-darwin-unstable;
          home-manager = inputs.home-manager-unstable;
        };
        "25.05" = {
          nixpkgs = inputs.nixpkgs-2505;
          nix-darwin = inputs.nix-darwin-2505;
          home-manager = inputs.home-manager-2505;
        };
      };

      mkBuilders =
        name:
        let
          s = series.${name};
        in
        {
          sys = import ./lib/mkSystem.nix {
            inherit (s) nixpkgs nix-darwin;
            inherit inputs;
            nixpkgsSeries = name;
          };
          hm = import ./lib/mkHome.nix {
            inherit (s) nixpkgs home-manager;
            inherit inputs;
            nixpkgsSeries = name;
          };
        };

      builders = {
        default = mkBuilders "default";
        "25.05" = mkBuilders "25.05";
      };

      lib = series.default.nixpkgs.lib;

      isDarwin = system: builtins.match ".*-darwin" system != null;

      hosts = [
        # MacBookPro18,2 (16-inch, 2021) — macOS Tahoe 26.3.1
        {
          name = "dragon";
          system = "aarch64-darwin";
        }

        # MacBookPro16,1 (16-inch, 2019) — macOS Tohoe 26.3.1
        {
          name = "dinosaur";
          system = "x86_64-darwin";
        }

        # MacBookPro6,1 (17-inch, Mid 2010) — NixOS
        {
          name = "phoenix";
          system = "x86_64-linux";
        }

        # MacBookAir8,2 (13-inch, 2019) — Fedora + home-manager only
        {
          name = "pomelo";
          system = "x86_64-linux";
          homeOnly = true;
        }

        # MacBookPro13,3 (15-inch, 2016) — macOS Monterey 12.7.6
        {
          name = "pterosaur";
          system = "x86_64-darwin";
          pinned = "25.05";
        }

        # MacBook8,1 (12-inch, Early 2015) — macOS Big Sur 11.7.10
        {
          name = "mango";
          system = "x86_64-darwin";
          pinned = "25.05";
        }

        # OrbStack VM
        {
          name = "orb-aarch64";
          host = "orbstack";
          system = "aarch64-linux";
        }

        # VMware Fusion VM
        {
          name = "vm-aarch64";
          host = "vmfusion";
          system = "aarch64-linux";
        }
      ];

      hostOutputs = map (
        h:
        let
          user = h.user or "erning";
          host = h.host or h.name;
          system = h.system;
          homeOnly = h.homeOnly or false;
          b = builders.${h.pinned or "default"};
          sysKey = if isDarwin system then "darwinConfigurations" else "nixosConfigurations";
        in
        (if homeOnly then { } else { ${sysKey}.${h.name} = b.sys { inherit host system; }; })
        // {
          homeConfigurations."${user}@${h.name}" = b.hm { inherit user host system; };
        }
      ) hosts;
    in
    lib.foldl' lib.recursiveUpdate { } hostOutputs;
}
