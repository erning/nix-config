{
  src,
  dst,
  prefix,
  mkSymlink,
  matchers,
}:

# Recursively walks `src` and emits one out-of-store symlink per file.
# Honors yadm-style `name##<condition>` alternates via `lib/alternate-match.nix`:
# for each base name, the highest-priority matching variant wins; the base file
# is used only when no alternate matches.

let
  alt = import ./alternate-match.nix { inherit matchers; };

  readDirRec =
    base: rel:
    let
      entries = builtins.readDir base;
      names = builtins.attrNames entries;

      # For each base name, pick the winning alternate (if any).
      # Result: { <baseName> = { name = <actualFileName>; priority = <int>; } }
      winners = builtins.foldl' (
        acc: name:
        let
          p = alt.parse name;
        in
        if entries.${name} == "directory" || p.condition == null || !alt.isMatch p.condition then
          acc
        else
          let
            prio = alt.priority p.condition;
            existing = acc.${p.base} or { priority = -1; };
          in
          if prio > existing.priority then
            acc // { ${p.base} = { inherit name; priority = prio; }; }
          else
            acc
      ) { } names;
    in
    builtins.concatMap (
      name:
      let
        type = entries.${name};
        p = alt.parse name;
        actualRel = if rel == "" then name else "${rel}/${name}";
        baseRel = if rel == "" then p.base else "${rel}/${p.base}";
      in
      if type == "directory" then
        readDirRec (base + "/${name}") (if rel == "" then name else "${rel}/${name}")

      else if p.condition != null then
        # Alternate file: emit only if it's the winning variant for its base.
        if (winners.${p.base} or null) != null && winners.${p.base}.name == name then
          [
            {
              name = "${prefix}/${baseRel}";
              value.source = mkSymlink "${dst}/${actualRel}";
            }
          ]
        else
          [ ]

      else
        # Base file: skip if a winning alternate exists for this base.
        if winners ? ${name} then
          [ ]
        else
          [
            {
              name = "${prefix}/${actualRel}";
              value.source = mkSymlink "${dst}/${actualRel}";
            }
          ]
    ) names;
in
builtins.listToAttrs (readDirRec src "")
