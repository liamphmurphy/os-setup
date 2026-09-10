{
  config,
  pkgs,
  lib,
  ...
}:

{

  programs.git = {
    enable = true;
    settings = {
      user = {
        email = "liam@phmurphy.com";
        name = "Liam Murphy";
      };
    };
  };

}
