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
            version = "0.9.39";
            src = {
              inherit version;

              x86_64-linux = fetchurl {
                url = "https://github.com/inlets/inlets-pro/releases/download/${version}/inlets-pro";
                sha256 = "sha256-usOdUd52Tgm5fJjmuP6ZqncGHUBS5jC+B1wgZkx4x1I=";
              };

              x86_64-darwin = fetchurl {
                url = "https://github.com/inlets/inlets-pro/releases/download/${version}/inlets-pro-darwin";
                sha256 = "sha256-Q1rVQ+FaeYmAY5Uu9FvLT0Qh3v0XIEUvVEWnps0n70k=";
              };

              aarch64-linux = fetchurl {
                url = "https://github.com/inlets/inlets-pro/releases/download/${version}/inlets-pro-arm64";
                sha256 = "sha256-gPI18BtRuHJY0WO2aVd5amkjg2WYigi66y2ATn5NfEk=";
              };

              aarch64-darwin = fetchurl {
                url = "https://github.com/inlets/inlets-pro/releases/download/${version}/inlets-pro-darwin-arm64";
                sha256 = "sha256-QKbBkIK4Y3O8M4IKsIkccBe2tqSXsmZ8C8pG5+upZmM=";
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
