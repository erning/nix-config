# Shared yadm-style alternate matcher.
#
# A dotfile named "config##<condition>" is deployed in place of "config" only
# when <condition> matches the current `matchers`. When several alternates exist
# for the same base file, the one with the highest priority wins; if none match,
# the base file is used.
#
# Supported conditions (highest priority first):
#
#   ##<host>            -> matchers.host
#   ##h.<host>          -> matchers.host   (alias)
#   ##hostname.<host>   -> matchers.host   (alias)
#   ##os.<os>           -> matchers.os     ("darwin" | "linux")
#   ##series.<series>   -> matchers.series (e.g. "default", "25.05")
#
# Priority order (most specific wins):
#   3. host (and its aliases)
#   2. os
#   1. series
#   0. base file (no condition)
#
# Combinations like "##os.darwin,series.25.05" are intentionally NOT supported.
# Pick the most-specific single tag and let the base file act as fallback.

{ matchers }:

let
  hostConditions = [
    matchers.host
    "h.${matchers.host}"
    "hostname.${matchers.host}"
  ];
  osCondition = "os.${matchers.os}";
  seriesCondition = "series.${matchers.series}";

  parse =
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

  isMatch =
    condition:
    builtins.elem condition hostConditions
    || condition == osCondition
    || condition == seriesCondition;

  # Higher = more specific. 0 means "not a winning alternate" (base or no match).
  priority =
    condition:
    if condition == null then
      0
    else if builtins.elem condition hostConditions then
      3
    else if condition == osCondition then
      2
    else if condition == seriesCondition then
      1
    else
      0;

  # Candidate suffixes ordered by priority (highest first). Used by single-file
  # `resolve`/`exists` lookups that don't walk a directory.
  candidateSuffixes = hostConditions ++ [
    osCondition
    seriesCondition
  ];
in
{
  inherit
    parse
    isMatch
    priority
    candidateSuffixes
    ;
}
