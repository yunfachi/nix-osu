{
  description = "Declarative configuration of osu!";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    denix.url = "github:yunfachi/denix/rewrite";
    denix.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    systems.url = "github:nix-systems/default";

    nuschtos-search.url = "github:NuschtOS/search";
    nuschtos-search.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      flake-parts,
      denix,
      systems,
      nuschtos-search,
      self,
      ...
    }:
    flake-parts.lib.mkFlake
      {
        inherit inputs;
        specialArgs.delib = inputs.denix.lib.recursivelyExtend (_: _: { nix-osu = self.lib; });
      }
      (
        {
          lib,
          delib,
          config,
          modulesPath,
          ...
        }:
        {
          systems = import systems;
          imports = [ denix.flakeModule ] ++ denix.lib.umport { path = ./modules; };

          denix = {
            myconfigPrefix = null;

            imports = [
              denix.denixModules.homeManager
            ];
          };

          denixSettings = {
            generateSystems = false;
            generateModules = false;
          };

          flake = {
            lib = import ./lib {
              inherit delib lib;
            };

            homeModules.default = config.denixConfiguration.genModule {
              moduleSystem = "home";
            };
          };

          perSystem =
            { pkgs, system, ... }:
            {
              packages = {
                osu-lazer-bin = pkgs.callPackage ./pkgs/osu-lazer-bin { };

                documentation = nuschtos-search.packages.${system}.mkSearch {
                  modules = [
                    self.homeModules.default
                    { _module.args.pkgs = pkgs; }
                  ];
                  urlPrefix = "https://github.com/yunfachi/nix-osu/blob/master/";
                  baseHref = "/";
                  title = "Nix-Osu Search";
                };
              };
            };
        }
      );
}
