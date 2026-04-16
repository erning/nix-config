{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    inputs.agenix.homeManagerModules.default
  ];

  home.packages = with pkgs; [
    age
    ssh-to-age
  ];

  xdg.configFile."age/pub" = {
    source = "${inputs.secrets}/age";
    recursive = true;
  };

  age.identityPaths = [
    "${config.home.homeDirectory}/.config/age/keys.txt"
    "/etc/age/keys.txt"
    "/etc/age/ssh_host_ed25519.txt"
  ];
}
