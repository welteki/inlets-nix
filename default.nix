with (import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/80fcac0b311031657783b721c935d2d9348dffee.tar.gz") {} );

buildGoModule rec {
  pname = "inlets";
  version = "3.0.1";
  commit = "dbccc1ee8edfa0a06e4f7b258bbee4a959bc18af";

  src = fetchFromGitHub {
    rev = "${version}";
    owner = "inlets";
    repo = "inlets";
    sha256 = "0d7q476x3w1c251dz627026y4mlzmnzrrmnrp0jzaxf95yh6fdk5";
  };

  vendorSha256 = null;

  subPackages = [ "." ];

  CGO_ENABLED = 0;
  buildFlagsArray = [ ''
    -ldflags=
    -s -w 
    -X main.GitCommit=${commit}
    -X main.Version=${version}
    '' 
    "-a"
  ];
}
