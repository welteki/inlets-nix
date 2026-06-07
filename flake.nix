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
          inherit (final.lib) licenses;
          inherit (final) fetchurl buildGoModule stdenv system;

          inlets-pro = rec {
            version = "0.11.11";
            src = {
              inherit version;

              x86_64-linux = fetchurl {
                url = "https://github.com/inlets/inlets-pro/releases/download/${version}/inlets-pro";
                sha256 = "sha256-7/Gwl0ZZPvMXCzkhSisGXYhqQ9q69vkrU59AC4yYjDI=";
              };

              x86_64-darwin = fetchurl {
                url = "https://github.com/inlets/inlets-pro/releases/download/${version}/inlets-pro-darwin";
                sha256 = "sha256-qTmsc1VljCT4Ju7sGLCOXKf8bovDQjd2cvGJGgc+iCo=";
              };

              aarch64-linux = fetchurl {
                url = "https://github.com/inlets/inlets-pro/releases/download/${version}/inlets-pro-arm64";
                sha256 = "sha256-beeXrfkzSZOtkf7EtE33Xqbor0JvcxZF8dUA2DeZciY=";
              };

              aarch64-darwin = fetchurl {
                url = "https://github.com/inlets/inlets-pro/releases/download/${version}/inlets-pro-darwin-arm64";
                sha256 = "sha256-2fR47qTALCDuyT8WQS/CcoX7x5FzYBoc/PeTIV+SPZc=";
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

            meta = {
              description = "Cloud Native Tunnel for HTTP and TCP";
              homepage = "https://inlets.dev";
              license = licenses.unfree;
            };
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
