{ pkgs, lib, options, ... }:
({
  home.packages = with pkgs; [
    go
  ];
  programs.go.enable = true;
} // lib.optionalAttrs (options.programs.go ? env) {
  programs.go.env = {
    GOPATH = ".go";
  };
})
