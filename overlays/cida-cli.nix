final: prev:

let
  version = "1.0.0";
  system = final.stdenv.hostPlatform.system;
  assets = {
    aarch64-darwin = {
      platform = "darwin_arm64";
      hash = "sha256-bAuzMZ1bYN425utF4zdJLU7ZsV3HmrV1OqT7w3Jswf0=";
    };
    x86_64-darwin = {
      platform = "darwin_amd64";
      hash = "sha256-szwS1Hmsw40GxPPZeaabctCHOeTd5ALkUcHRQuJBdEM=";
    };
    aarch64-linux = {
      platform = "linux_arm64";
      hash = "sha256-MD91vODyrskCJB45/YIK16HRXk5lmq2cG+mSqy6pOHs=";
    };
    x86_64-linux = {
      platform = "linux_amd64";
      hash = "sha256-cgMj6QHjtuZVXMh3CPlsPYyT4MLoqpcazTg10vHqA+Q=";
    };
  };
  asset = assets.${system} or (throw "cida-cli: unsupported platform ${system}");
in
{
  cida-cli = final.stdenv.mkDerivation {
    pname = "cida-cli";
    inherit version;

    src = final.fetchurl {
      url = "https://github.com/erning/cida-cli/releases/download/v${version}/cida-${asset.platform}-v${version}";
      inherit (asset) hash;
    };

    dontUnpack = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 $src $out/bin/cida
      runHook postInstall
    '';

    meta = {
      description = "Standalone CLI for translating, improving, and processing text with a configured language model";
      homepage = "https://github.com/erning/cida-cli";
      license = final.lib.licenses.mit;
      mainProgram = "cida";
      platforms = builtins.attrNames assets;
    };
  };
}
