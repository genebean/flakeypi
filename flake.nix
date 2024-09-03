{
  description = "A flake for my pi";
  inputs = {
    # Where we get most of our software. Giant mono repo with recipes
    # called derivations that say how to build software.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = inputs@{ self, nixpkgs, nixos-hardware }: let
    pi4Image = { system, hostname, additionalModules, additionalSpecialArgs }: nixpkgs.lib.nixosSystem {
      specialArgs = { inherit inputs hostname;
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
      } // additionalSpecialArgs;
      modules = [
        ./configuration.nix
        nixos-hardware.nixosModules.raspberry-pi-4
      ] ++ additionalModules;
    }; # end nixosSystem
  in {
    nixosConfigurations = {
      pi-screen-01 = pi4Image {
        system = "aarch64-linux";
        hostname = "pi-screen-01";
        additionalModules = [];
        additionalSpecialArgs = {};
      };
    };
    images = {
      pi-screen-01 = (self.nixosConfigurations.pi-screen-01.extendModules {
        modules = [
          "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
          {
            disabledModules = [ "profiles/base.nix" ];
          }
        ];
      }).config.system.build.sdImage;
    };
  };
}

