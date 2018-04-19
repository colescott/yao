with import <nixpkgs> {};

let
  target = "x86_64-elf";
  version = "7.3.0";
in
  stdenv.mkDerivation {
    name = "${target}-gcc-${version}";
    src = fetchurl {
      url = "ftp://ftp.gnu.org/gnu/gcc/gcc-${version}/gcc-${version}.tar.gz";
      sha256 = "0w2q80fry6442769iaz0lxmbdkzp9hwjmpsdx88xr38rr9ay81ps";
    };
    buildInputs = [ (import ./binutils.nix) gmp mpfr libmpc libelf ];
    hardeningDisable = [ "all" ];

    TARGET = target;
    VERSION = version;

    builder = ./gcc-builder.sh;
  }
