with import <nixpkgs> {};

stdenv.mkDerivation rec {
  name = "yao-env";
  env = buildEnv {
    name = name;
    paths = buildInputs;
  };
  buildInputs = [
    (import ./tools/gcc.nix)
  ];
}
