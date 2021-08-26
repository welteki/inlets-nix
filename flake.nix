{
  description = "Cloud Native Tunnel";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }:
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
          inherit (final) buildGoModule fetchFromGitHub;
        in
        {
          inlets = buildGoModule rec {
            pname = "inlets";
            version = "4.0.1-archived";
            commit = "ae9a0f82a8914c12b338f5c310e3fcf9750e0309";

            src = fetchFromGitHub {
              owner = "inlets";
              repo = "inlets-archived";
              rev = "${commit}";
              sha256 = "1vbp718zcrwavz95h55pa97pyimyg3rkna0lrfbgyblcr81zq32i";
            };

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
        overlays = [ self.overlay ];
      }).inlets);

      nixosModules.inlets = {
        imports = [ ./inlets-module.nix ];
        nixpkgs.overlays = [ self.overlay ];
      };
    };
}
