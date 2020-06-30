{
  description = "logicless, language-agnostic, pattern-matching templates";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-20.03;
  inputs.utils.url = github:numtide/flake-utils;

  outputs = {self, nixpkgs, utils}:
    utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in rec {
        defaultPackage = pkgs.haskellPackages.callPackage ./default.nix {};
        devShell = defaultPackage.env;
      }
    );
}
