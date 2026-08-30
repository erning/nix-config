final: prev:

let
  version = "1.0.4";
  system = final.stdenv.hostPlatform.system;
  assets = {
    aarch64-darwin = {
      platform = "macos-aarch64";
      hash = "sha256-M3qcWkAq/zcoAqyx6xKMi9qRdu/vm0aCR8Q6hvmiE44=";
    };
    x86_64-darwin = {
      platform = "macos-x86_64";
      hash = "sha256-SyJ/qDnKggd6kvRn5gZ2HIoQkxpE2bN33zXl+JVQOZ0=";
    };
    aarch64-linux = {
      platform = "linux-aarch64";
      hash = "sha256-/LtydQyMbakUYtfPkAuUYODNSnbUB4XUQY3VqdyccYE=";
    };
    x86_64-linux = {
      platform = "linux-x86_64";
      hash = "sha256-WhrLnA2ogGzetffFpi4dBSyXv5Ak3M/5KatWKqbowJU=";
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
