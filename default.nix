with import <nixpkgs> {};

stdenv.mkDerivation rec {
  name = "yao-env";
  env = buildEnv {
    name = name;
    paths = buildInputs;
  };
  buildInputs = with pkgs; [
    (import ./tools/gcc.nix)
    (import ./tools/binutils.nix)
    nasm

    # Formatting
    astyle

    # Emulation
    qemu
    OVMF

    # UEFI
    gnu-efi

    # Image creation
    bc
    coreutils
    mtools
    parted
  ];

  GNU_EFI_DIR=pkgs.gnu-efi; # GNU EFI dir for headers
  OVMF_DIR="${pkgs.OVMF.fd}/FV"; # OVMF dir for qemu bios
}
