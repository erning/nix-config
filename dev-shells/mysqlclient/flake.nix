{
  description = "A development shell with MySQL client and pkg-config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          # Add the required packages to the buildInputs
          buildInputs = with pkgs; [
            # For mysql client libraries, mariadb is the common package
            libmysqlclient
            pkg-config
          ];

          # Optional: Use a shell hook to verify the setup
          shellHook = ''
            echo "Nix development environment ready!"
            echo "mysql client version:"
            mysql --version
            echo "pkg-config available."
          '';
        };

        # For compatibility with older nix versions
        devShell = self.devShells.${system}.default;
      }
    );
}
