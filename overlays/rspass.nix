final: prev:

let
  version = "1.0.3";
  system = final.stdenv.hostPlatform.system;
  assets = {
    aarch64-darwin = {
      platform = "macos-aarch64";
      hash = "sha256-zcuPyG/yms8sA/nTzop+gBlFb4DO2faB9jHGwLzGAz4=";
    };
    x86_64-darwin = {
      platform = "macos-x86_64";
      hash = "sha256-q0HZuEQhxNFke0rXyf6gToiWgs3hXm+JPI+6VpIa3qc=";
    };
    aarch64-linux = {
      platform = "linux-aarch64";
      hash = "sha256-n0VCFhwH4j1LN7KgPDuLxjjXzfP/kecUmJPjFg3kcxg=";
    };
    x86_64-linux = {
      platform = "linux-x86_64";
      hash = "sha256-YaWbizr4tM/5295labd0pjCuRPyto4KRlqhGuHgHn6w=";
    };
  };
  asset = assets.${system} or (throw "rspass: unsupported platform ${system}");
in
{
  rspass = final.stdenv.mkDerivation {
    pname = "rspass";
    inherit version;

    src = final.fetchurl {
      url = "https://github.com/erning/rspass/releases/download/v${version}/rspass-${version}-${asset.platform}.tar.gz";
      inherit (asset) hash;
    };

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      install -Dm755 rspass $out/bin/rspass
      runHook postInstall
    '';

    meta = {
      description = "Minimal age-only command-line secret manager";
      homepage = "https://github.com/erning/rspass";
      license = final.lib.licenses.mit;
      mainProgram = "rspass";
      platforms = builtins.attrNames assets;
    };
  };
}
