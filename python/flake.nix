{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-20.09-small;

  outputs = { self, nixpkgs }: let
    inherit (nixpkgs.lib) flip mapAttrs mapAttrsToList;
    inherit (pkgs.nix-gitignore) gitignoreSourcePure gitignoreSource;
    getSrc = dir: gitignoreSourcePure [./.gitignore] dir;

    pkgs = import nixpkgs {
      system = "x86_64-linux";
      overlays = [ self.overlay ];
    };
  in {
    overlay = final: prev: {
      python38 = prev.python38.override {
        packageOverrides = pyself: pysuper: {
          pandas-datareader = pkgs.python38Packages.buildPythonPackage rec {
            pname = "pandas-datareader";
            version = "0.9.0";
            src = pkgs.python38Packages.fetchPypi {
              inherit pname version;
              sha256 = "ssvB4Wpquf8e0WeuLqkoOb6rmiCCO9AL37eBVfoE+JE=";
            };
            propagatedBuildInputs = with pkgs.python38Packages; [
              pandas requests lxml
            ];
            doCheck = false;
          };
        };
      };
    };

    devShell.x86_64-linux = pkgs.mkShell {
      buildInputs = [
        (pkgs.python38.withPackages (ps: with ps; [
          pandas
          requests
          numpy
          matplotlib
          pandas-datareader
        ]))
      ];
    };
  };
}
