{
  description = "Cloud Native Tunnel";

  inputs = {
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
        "aarch64-linux"
        "aarch64-darwin"
      ];
    in
    {
      overlays.default = final: prev:
        let
          inherit (final) fetchurl buildGoModule stdenv system;

          inlets-pro = rec {
            version = "0.9.6";
            src = {
              inherit version;

              x86_64-linux = fetchurl {
                url = "https://github.com/inlets/inlets-pro/releases/download/${version}/inlets-pro";
                sha256 = "sha256-r0wpGoJo8hVzsD5oveeNQpq/lZsjMPebTAwbbD4ewK4=";
              };

              x86_64-darwin = fetchurl {
                url = "https://github.com/inlets/inlets-pro/releases/download/${version}/inlets-pro-darwin";
                sha256 = "sha256-eaMTh9/f9BiA2RKsW8G3+RU0VvYpI/ahh53766idsO0=";
              };

              aarch64-linux = fetchurl {
                url = "https://github.com/inlets/inlets-pro/releases/download/${version}/inlets-pro-arm64";
                sha256 = "sha256-zQVKKQNCsG2BozrT1XOsp9WMSU+cPo1rhaLXhXfUc30=";
              };

              aarch64-darwin = fetchurl {
                url = "https://github.com/inlets/inlets-pro/releases/download/${version}/inlets-pro-darwin-arm64";
                sha256 = "sha256-J6DE6MNqO9xcNRsWaKJ4hMdgXpWxt7u+9LggC1JIjjk=";
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
