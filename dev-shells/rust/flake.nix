{
  description = "A Nix-flake-based Rust development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      rust-overlay,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # rust-bin.stable."1.87.0".default
            rust-bin.stable.latest.default
            cargo
            rustc
            clippy
            rustfmt
            rust-analyzer
          ];

          buildInputs = with pkgs; [
            libiconv
          ];

          env = {
          };

          shellHook = ''
            echo "Happy coding! Rust - 🦀"
          '';
        };

        # For compatibility with older nix versions
        devShell = self.devShells.${system}.default;
      }
    );
}
