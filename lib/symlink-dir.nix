{
  src,
  dst,
  prefix,
  mkSymlink,
  host,
}:

let
  parseAlternate =
    name:
    let
      m = builtins.match "(.+)##(.+)" name;
    in
    if m == null then
      {
        base = name;
        condition = null;
      }
    else
      {
        base = builtins.elemAt m 0;
        condition = builtins.elemAt m 1;
      };

  isHostMatch =
    condition: condition == host || condition == "h.${host}" || condition == "hostname.${host}";

  readDirRec =
    base: rel:
    let
      entries = builtins.readDir base;
      names = builtins.attrNames entries;

      # Collect base names that have a host-matched alternate
      hostMatched = builtins.foldl' (
        acc: name:
        let
          p = parseAlternate name;
        in
        if entries.${name} != "directory" && p.condition != null && isHostMatch p.condition then
          acc // { ${p.base} = true; }
        else
          acc
      ) { } names;
    in
    builtins.concatMap (
      name:
      let
        type = entries.${name};
        p = parseAlternate name;
        actualRel = if rel == "" then name else "${rel}/${name}";
        baseRel = if rel == "" then p.base else "${rel}/${p.base}";
      in
      if type == "directory" then
        readDirRec (base + "/${name}") (if rel == "" then name else "${rel}/${name}")

      else if p.condition != null && isHostMatch p.condition then
        # Host-matched alternate: deploy under the base name
        [
          {
            name = "${prefix}/${baseRel}";
            value.source = mkSymlink "${dst}/${actualRel}";
          }
        ]

      else if p.condition != null then
        # Non-matching alternate: skip
        [ ]

      else if hostMatched ? ${name} then
        # Base file superseded by a host alternate: skip
        [ ]

      else
        # Regular file: include as-is
        [
          {
            name = "${prefix}/${actualRel}";
            value.source = mkSymlink "${dst}/${actualRel}";
          }
        ]
    ) names;
in
builtins.listToAttrs (readDirRec src "")
