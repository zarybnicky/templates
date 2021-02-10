{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/master;

  outputs = inputs@{ self, nixpkgs, ... }: let
    inherit (nixpkgs.lib) flip mapAttrs mapAttrsToList;
    inherit (pkgs.nix-gitignore) gitignoreSourcePure;
    getSrc = dir: gitignoreSourcePure [./.gitignore] dir;

    pkgs = import nixpkgs {
      system = "x86_64-linux";
      overlays = [ self.overlay ];
    };
    compiler = "ghc884";
    hsPkgs = pkgs.haskell.packages.${compiler};
  in {
    overlay = final: prev: let
      inherit (prev.haskell.lib) justStaticExecutables generateOptparseApplicativeCompletion;
    in {
      haskell = prev.haskell // {
        packageOverrides = prev.lib.composeExtensions (prev.haskell.packageOverrides or (_: _: {})) (hself: hsuper: {
          hello = generateOptparseApplicativeCompletion "hello" (
            justStaticExecutables (
              hself.callCabal2nix "hello" (getSrc ./.) {}
            )
          );
        });
      };
      inherit (final.haskell.packages.${compiler}) hello;
    };

    packages.x86_64-linux = {
      inherit (pkgs) hello;
    };

    devShell.x86_64-linux = hsPkgs.shellFor {
      withHoogle = true;
      packages = p: [ p.hello ];
      buildInputs = [
        hsPkgs.cabal-install
        hsPkgs.haskell-language-server
        hsPkgs.stan
      ];
    };
  };
}
