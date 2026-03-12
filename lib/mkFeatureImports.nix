# Recursively scans a directory for feature modules.
# Derives feature name from filename, wraps each with enable option + mkIf.
# Subdirectories create nested features (fonts/source-han.nix → "fonts.source-han").
dir:

let
  scan =
    prefix: path:
    let
      entries = builtins.readDir path;
      process =
        name: type:
        if name == "default.nix" then
          [ ]
        else if type == "regular" && builtins.match ".*\\.nix" name != null then
          let
            featureName = builtins.replaceStrings [ ".nix" ] [ "" ] name;
            fullName = if prefix == "" then featureName else "${prefix}.${featureName}";
          in
          [ (mkModule fullName (path + "/${name}")) ]
        else if type == "directory" then
          scan (if prefix == "" then name else "${prefix}.${name}") (path + "/${name}")
        else
          [ ];
    in
    builtins.concatLists (
      map (name: process name entries.${name}) (builtins.attrNames entries)
    );

  mkModule =
    name: modulePath:
    { config, lib, pkgs, options, ... }@args:
    let
      featurePath = lib.splitString "." name;
      cfg = lib.getAttrFromPath ([ "features" ] ++ featurePath) config;
      featureModule = import modulePath;
      raw = if builtins.isFunction featureModule then featureModule args else featureModule;
      description = raw._description or name;
      result = removeAttrs raw [ "_description" ];
    in
    {
      options = lib.setAttrByPath ([ "features" ] ++ featurePath) {
        enable = lib.mkEnableOption description;
      };
      config = lib.mkIf cfg.enable result;
    };
in
scan "" dir
