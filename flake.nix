{
  description = "Cloud Native Tunnel";

  inputs = {
    nixpkgs.follows = "nix/nixpkgs";
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
      supportedSystems = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
        "aarch64-darwin"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
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

      defaultPackage = forAllSystems (system: (import nixpkgs {
        inherit system;
        overlays = [ self.overlay nix.overlay ];
      }).inlets);

      nixosModules.inlets = {
        imports = [ ./inlets-module.nix ];
        nixpkgs.overlays = [ self.overlay nix.overlay ];
      };
    };
}
