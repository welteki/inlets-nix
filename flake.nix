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

  outputs = { self, nixpkgs, flake-utils, flake-compat, inlets-src }:
    with flake-utils.lib;
    eachSystem (defaultSystems ++ [ "aarch64-darwin" "armv7l-linux" ]) (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      {
        defaultPackage = pkgs.buildGoModule
          rec {
            pname = "inlets";
            version = "3.0.2";
            commit = "7b18a394b74390133e511957d954b1ba3b7d01a2";

            src = "${inlets-src}";

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
      }
    );
}
