{ src, dst, prefix, mkSymlink }:

let
  readDirRec = base: rel:
    builtins.concatMap (
      name:
      let
        childRel = if rel == "" then name else "${rel}/${name}";
        childSrc = base + "/${name}";
        type = (builtins.readDir base).${name};
      in
      if type == "directory" then
        readDirRec childSrc childRel
      else
        [
          {
            name = "${prefix}/${childRel}";
            value.source = mkSymlink "${dst}/${childRel}";
          }
        ]
    ) (builtins.attrNames (builtins.readDir base));
in
builtins.listToAttrs (readDirRec src "")
