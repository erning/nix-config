final: prev:

let
  version = "1.0.1";
  system = final.stdenv.hostPlatform.system;
  assets = {
    aarch64-darwin = {
      platform = "macos-aarch64";
      hash = "sha256-r7yfb/M6A8CUvL0VKymRWDiNiD0M6hxPaoAIV1e06tI=";
    };
    x86_64-darwin = {
      platform = "macos-x86_64";
      hash = "sha256-AIUj+ODsgwBgNLgpTOhZLPWHU3izxwvBNZU094Okz+0=";
    };
    aarch64-linux = {
      platform = "linux-aarch64";
      hash = "sha256-ZjIZrvf7OUvgjyfGKUPOuJiCWhWCkxdE5U1HW0jupxE=";
    };
    x86_64-linux = {
      platform = "linux-x86_64";
      hash = "sha256-CXJLEC8sknbPvHTfOklzjwN9NN46pbrw5H0h1MlcwYQ=";
    };
  };
  asset =
    assets.${system}
      or (throw "rspass: unsupported platform ${system}");
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
