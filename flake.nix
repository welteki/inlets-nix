{
  description = "Cloud Native Tunnel";

  inputs = {
    utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, utils, ... }:
    let
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    in
    {
      overlays.default = final: prev:
        let
          inherit (final) fetchurl buildGoModule stdenv system;

          inlets-pro = rec {
            version = "0.9.9";
            src = {
              inherit version;

              x86_64-linux = fetchurl {
                url = "https://github.com/inlets/inlets-pro/releases/download/${version}/inlets-pro";
                sha256 = "sha256-jZHynTXzt/7TcivhM4RRqH8RQHDoM349CjkUouuocBU=";
              };

              x86_64-darwin = fetchurl {
                url = "https://github.com/inlets/inlets-pro/releases/download/${version}/inlets-pro-darwin";
                sha256 = "sha256-CD7kTRMfN1ZzzorR3o/ub6pKFElz6+jOEFGRzmmhMpM=";
              };

              aarch64-linux = fetchurl {
                url = "https://github.com/inlets/inlets-pro/releases/download/${version}/inlets-pro-arm64";
                sha256 = "sha256-endv45vc5J4GenxeunpN6jxW7IJCI/allESO+D3MOhU=";
              };

              aarch64-darwin = fetchurl {
                url = "https://github.com/inlets/inlets-pro/releases/download/${version}/inlets-pro-darwin-arm64";
                sha256 = "sha256-DFZgulu+X8TfrBnTh0v8+knY2A3IAEnGd0yrSXCxLA4=";
              };
            };
          };
        in
        {
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

    } // utils.lib.eachSystem supportedSystems (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
      in
      {
        packages = rec {
          inherit (pkgs) inlets-pro;

          default = inlets-pro;
        };
      });
}
