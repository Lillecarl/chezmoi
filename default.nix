# default.nix
let
  pkgs = import <nixpkgs> {};

  packages = with pkgs;
    [
      # Sourced directly from Nixpkgs
      curl
      htop
      nix
      tree
      #terraform
      keychain
      powershell
    ];

in packages
