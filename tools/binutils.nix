with import <nixpkgs> {};

let
  target = "x86_64-elf";
  efi-target = "x86_64-pe";
  version = "2.30";
in
  stdenv.mkDerivation {
    name = "${target}-binutils-${version}";
    src = pkgs.fetchurl {
      url = "https://ftp.gnu.org/gnu/binutils/binutils-${version}.tar.gz";
      sha256 = "1sp9g7zrrcsl25hxiqzmmcrdlbm7rbmj0vki18lks28wblcm0f4c";
    };
    configureFlags = "--target=${target} --enable-targets=${target},${efi-target} --with-sysroot --disable-nls --disable-werror";
  }
