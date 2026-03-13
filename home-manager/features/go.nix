{ pkgs, lib, options, ... }:
({
  _description = "Go programming language";
  home.packages = with pkgs; [
    go
  ];
  programs.go.enable = true;
} // lib.optionalAttrs (options.programs.go ? env) {
  programs.go.env = {
    GOPATH = ".go";
  };
})
