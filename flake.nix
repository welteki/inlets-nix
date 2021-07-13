{
  description = "Cloud Native Tunnel";

  inputs = {
    nixpkgs.follows = "nix/nixpkgs";
    utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, nix, utils, ... }:
    let
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
    in
    {
      overlay = final: prev:
        let
          inherit (final) fetchurl buildGoModule stdenv system;

          inlets-pro = rec {
            version = "0.8.9";
            src = {
              inherit version;

              x86_64-linux = fetchurl {
                url = "https://github.com/inlets/inlets-pro/releases/download/${version}/inlets-pro";
                sha256 = "07521b2g7saavda1m2jkva631s80f14ik9h9dg755whjqyx343lj";
              };

              x86_64-darwin = fetchurl {
                url = "https://github.com/inlets/inlets-pro/releases/download/${version}/inlets-pro-darwin";
                sha256 = "1wawrmi74y43l6x6bmdsdyxav45r4miia3v070kis3jq20r8pc9m";
              };
            };
          };
        in
        {
          inlets = buildGoModule rec {
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

          inlets-pro = stdenv.mkDerivation rec {
            pname = "inlets-pro";
            version = "${inlets-pro.version}";

            src = inlets-pro.src.${system};

            dontUnpack = true;

            installPhase = ''
              install -m755 -D ${src} $out/bin/inlets-pro
            '';
          };
        };

      nixosModules.inlets = {
        imports = [ ./inlets-module.nix ];
        nixpkgs.overlays = [ self.overlay ];
      };

    } // utils.lib.eachSystem supportedSystems (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlay nix.overlay ];
        };
      in
      rec {
        packages = utils.lib.flattenTree {
          inlets = pkgs.inlets;
          inlets-pro = pkgs.inlets-pro;
        };
        defaultPackage = packages.inlets-pro;
      });
}
