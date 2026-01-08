{
  description = "Pure Nix Super Shell (No Homebrew Dependencies)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
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
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
          ];

          buildInputs = with pkgs; [
            libiconv
            libmysqlclient
            #   openssl.dev
            #   openssl
            #   sqlite
            #   zlib
            #   zstd
          ];

          shellHook = ''
            # --- Rust OpenSSL 修复 ---
            # 即使有 pkg-config，有些 crate 还是喜欢读环境变量
            # export OPENSSL_DIR="${pkgs.openssl.dev}"
            # export OPENSSL_LIB_DIR="${pkgs.openssl.out}/lib"
            # export OPENSSL_INCLUDE_DIR="${pkgs.openssl.dev}/include"

            # --- Bindgen (Rust C-FFI) 修复 ---
            # 如果你要编译类似 aggressive-indent 或其它依赖 bindgen 的工具
            # export LIBCLANG_PATH="${pkgs.llvmPackages.libclang.lib}/lib"

            # --- Python 修复 ---
            # 让 pip 安装带有 C 扩展的包时能找到库
            # export LDFLAGS="-L${pkgs.libiconv}/lib"
            # export CPPFLAGS="-I${pkgs.libiconv}/include"

            echo "🛡️ Pure Nix Environment Activated"
          '';
        };
      }
    );
}
