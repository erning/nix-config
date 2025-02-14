path:

with builtins;
map (n: path + ("/" + n)) (
  filter (n: n != "default.nix") (
    filter (n: match ".*\\.nix" n != null || pathExists (path + ("/" + n + "/default.nix"))) (
      attrNames (readDir path)
    )
  )
)
