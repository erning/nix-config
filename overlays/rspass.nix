final: prev:

let
  version = "1.0.2";
  system = final.stdenv.hostPlatform.system;
  assets = {
    aarch64-darwin = {
      platform = "macos-aarch64";
      hash = "sha256-57vUfsDbwh/Za8F30AFsQ64Zxr+IuyfPpkda7S8Du/E=";
    };
    x86_64-darwin = {
      platform = "macos-x86_64";
      hash = "sha256-QzzJ9zw+ZVYEUs2BDe8i7si6+ATdJJxorTWcvBf9nXA=";
    };
    aarch64-linux = {
      platform = "linux-aarch64";
      hash = "sha256-ZJo+IxxcSXpQRIzYHxCU8dg8Z7nNI9Nuie87BcXwI9w=";
    };
    x86_64-linux = {
      platform = "linux-x86_64";
      hash = "sha256-5GdTMjAKSqpvAcrBqOkQ+hmywaCcU3XoCDzdT5t++UA=";
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
