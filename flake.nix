{
  description = "Cloud Native Tunnel";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    inlets-src = {
      url = "https://github.com/inlets/inlets/archive/refs/tags/3.0.2.tar.gz";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, nix, ... }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ self.overlay nix.overlay ];
      };
    in
    {
      overlay = final: prev: {
        inlets = with final; buildGoModule rec {
          pname = "inlets";
          version = "3.0.2";
          commit = "7b18a394b74390133e511957d954b1ba3b7d01a2";

          src = "${inputs.inlets-src}";

          vendorSha256 = null;

          subPackages = [ "." ];

          CGO_ENABLED = 0;
          buildFlagsArray = [
            ''
              -ldflags=
              -s -w 
              -X main.GitCommit=${commit}
              -X main.Version=${version}
            ''
            "-a"
          ];
        };
      };

      package.x86_64-linux.inlets = pkgs.inlets;
      defaultPackage.x86_64-linux = pkgs.inlets;

      nixosModules.inlets = {
        imports = [ ./inlets-module.nix ];
        nixpkgs.overlays = [ self.overlay nix.overlay ];
      };
    };
}
