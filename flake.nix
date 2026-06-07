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
          inherit (final) fetchurl stdenv system;

          source = builtins.fromJSON (builtins.readFile ./source.json);
        in
        {
          inlets-pro = stdenv.mkDerivation rec {
            pname = "inlets-pro";
            version = source.version;

            src = fetchurl source.${system};

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

        update = pkgs.writeShellApplication {
          name = "update-source";
          runtimeInputs = with pkgs; [ curl jq nix gawk ];
          text = ''
            if [ "$#" -eq 0 ]; then
              echo "Usage: update-source <version>" >&2
              exit 1
            fi

            version="$1"
            base="https://github.com/inlets/inlets-pro/releases/download/$version"

            fetch_hash() {
              nix hash file "$(nix-prefetch-url "$1" --type sha256 --print-path 2>/dev/null | awk 'NR==2')"
            }

            echo "Fetching hashes for $version..."

            sha_linux=$(fetch_hash "$base/inlets-pro")
            echo "  x86_64-linux:   $sha_linux"
            sha_darwin=$(fetch_hash "$base/inlets-pro-darwin")
            echo "  x86_64-darwin:  $sha_darwin"
            sha_linux_arm=$(fetch_hash "$base/inlets-pro-arm64")
            echo "  aarch64-linux:  $sha_linux_arm"
            sha_darwin_arm=$(fetch_hash "$base/inlets-pro-darwin-arm64")
            echo "  aarch64-darwin: $sha_darwin_arm"

            jq -n \
              --arg version        "$version" \
              --arg url_linux      "$base/inlets-pro" \
              --arg sha_linux      "$sha_linux" \
              --arg url_darwin     "$base/inlets-pro-darwin" \
              --arg sha_darwin     "$sha_darwin" \
              --arg url_linux_arm  "$base/inlets-pro-arm64" \
              --arg sha_linux_arm  "$sha_linux_arm" \
              --arg url_darwin_arm "$base/inlets-pro-darwin-arm64" \
              --arg sha_darwin_arm "$sha_darwin_arm" \
              '{
                version: $version,
                "x86_64-linux":   { url: $url_linux,      sha256: $sha_linux },
                "x86_64-darwin":  { url: $url_darwin,     sha256: $sha_darwin },
                "aarch64-linux":  { url: $url_linux_arm,  sha256: $sha_linux_arm },
                "aarch64-darwin": { url: $url_darwin_arm, sha256: $sha_darwin_arm }
              }' > source.json

            echo "Written to source.json"
          '';
        };
      in
      {
        packages = rec {
          inherit (pkgs) inlets-pro;

          default = inlets-pro;
          inherit update;
        };

        apps.update-source = {
          type = "app";
          program = "${update}/bin/update-source";
        };
      });
}
