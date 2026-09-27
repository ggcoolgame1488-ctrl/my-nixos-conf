 {

  description = "NixOS configuration for ilusha / COLORFUL P15 24";


  inputs = {

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";


    minegrub-world-sel-theme = {

      url = "github:Lxtharia/minegrub-world-sel-theme";

      inputs.nixpkgs.follows = "nixpkgs";

    };


    # Exact driver tree used by the original COLORFUL P15 project.

    colorful-p15-driver = {

      url = "gitlab:commown/tuxedo-drivers/4e1fb3a8897708676ba76603f15e20ce7e9ad5fe";

      flake = false;

    };


    colorful-p15 = {

      url = "github:JAmanOG/colorful-p15-keyboard-backlight";

      flake = false;

    };

  };


  outputs = { self, nixpkgs, minegrub-world-sel-theme

    , colorful-p15-driver, colorful-p15, ... }:

  {

    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {

      system = "x86_64-linux";


      specialArgs = {

        inherit colorful-p15-driver colorful-p15;

      };


      modules = [

        ./configuration.nix

        minegrub-world-sel-theme.nixosModules.default

        ./colorful-p15-backlight.nix

      ];

    };

  };

} 
