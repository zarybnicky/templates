{
  outputs = { self }: {
    templates = {
      python = {
        path = ./python;
        description = "Simple Python environment";
      };
      jupyter = {
        path = ./jupyter;
        description = "Simple Jupyter bootstrap";
      };
      haskell = {
        path = ./haskell;
        description = "Simple Haskell project";
      };
    };

    defaultTemplate = self.templates.haskell;
  };
}
