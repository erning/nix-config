final: prev:

let
  version = "1.0.0";
  system = final.stdenv.hostPlatform.system;
  assets = {
    aarch64-darwin = {
      platform = "darwin-arm64";
      hash = "sha256-w12Q38JKRcnPP+NKt2iMH4o6I6NODROd/3FFfohGApU=";
    };
    x86_64-darwin = {
      platform = "darwin-amd64";
      hash = "sha256-qZeebAmodxrfX5JrnqgsZK2BkKzWM72bP2J/paZeksE=";
    };
    aarch64-linux = {
      platform = "linux-arm64";
      hash = "sha256-AF4dsq6ZSBeyqygwIJQBzHcwgx5qiO+zV1mRRsS79Xs=";
    };
    x86_64-linux = {
      platform = "linux-amd64";
      hash = "sha256-MrwSBwlqPFygE9zDeR+9FNsnUfDFrlQTMr8E23r3h3U=";
    };
  };
  asset = assets.${system} or (throw "translate-script: unsupported platform ${system}");
in
{
  translate-script = final.stdenv.mkDerivation {
    pname = "translate-script";
    inherit version;

    src = final.fetchurl {
      url = "https://github.com/erning/translate-script/releases/download/v${version}/translate-${asset.platform}";
      inherit (asset) hash;
    };

    dontUnpack = true;

    installPhase = ''
      runHook preInstall
      install -Dm755 $src $out/bin/translate
      runHook postInstall
    '';

    meta = {
      description = "CLI that wraps the pi CLI to translate text between English and Simplified Chinese";
      homepage = "https://github.com/erning/translate-script";
      mainProgram = "translate";
      platforms = builtins.attrNames assets;
    };
  };
}
