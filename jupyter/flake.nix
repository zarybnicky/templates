{
  inputs.jupyter-src = { url = github:tweag/jupyterWith/master; flake = false; };

  outputs = { self, nixpkgs, jupyter-src }: {
    devShell.x86_64-linux = let
      jupyter = import jupyter-src {
        pkgs = import nixpkgs {
          localSystem = "x86_64-linux";
          overlays = [
            (import (jupyter-src + "/nix/haskell-overlay.nix"))
            (import (jupyter-src + "/nix/python-overlay.nix"))
          ];
        };
      };
      pythonPkgs = p: with p; [
        flake8
        mypy
        numpy
        pylint
        python-dateutil
        requests
        numpy
        matplotlib
        pymongo
        psycopg2
        pandas
      ];
    in (jupyter.jupyterlabWith {
      extraPackages = p: [(p.python38.withPackages pythonPkgs)];
      kernels = [(jupyter.kernels.iPythonWith {
        name = "python";
        packages = p: with p; pythonPkgs p ++ [
          ipywidgets
          ipympl
          scipy
          widgetsnbextension
        ];
      })];
    }).env;
  };
}
