{
  description = "Cloud Native Tunnel";

  inputs = {
    nixpkgs.follows = "nix/nixpkgs";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    inlets-src = {
      url = "https://github.com/inlets/inlets-archived/archive/refs/tags/4.0.1.tar.gz";
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
          version = "4.0.1";
          commit = "883e3c42be9c1f53d63c8cb47407644387966f33";

          src = "${inputs.inlets-src}";

          vendorSha256 = "0jqkfjpvfwhx9dn58liawsyyn01bydp970fifc79vx126g0fczm9";

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
