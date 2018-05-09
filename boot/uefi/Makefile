UEFI_BUILD_DIR=build/boot/uefi
UEFI_SRC_DIR=boot/uefi

UEFI_SRC_FILES=$(wildcard $(UEFI_SRC_DIR)/*.c)
UEFI_OBJ_FILES=$(patsubst $(UEFI_SRC_DIR)/%.c,$(UEFI_BUILD_DIR)/%.o, $(UEFI_SRC_FILES))

GNU_EFI_CFLAGS=-I ${GNU_EFI_DIR}/include/efi -I ${GNU_EFI_DIR}/include/efi/x86_64
GNU_EFI_LDFLAGS=${GNU_EFI_DIR}/lib/crt0-efi-$(ARCH).o -T ${GNU_EFI_DIR}/lib/elf_$(ARCH)_efi.lds -L ${GNU_EFI_DIR}/lib -l:libgnuefi.a -l:libefi.a

UEFI_CFLAGS=-c -Werror -ffreestanding -fno-builtin -fno-stack-protector -fpic -fshort-wchar -mno-red-zone -DEFI_FUNCTION_WRAPPER $(GNU_EFI_CFLAGS)
UEFI_LDFLAGS=-nostdlib -znocombreloc -shared -Bsymbolic $(GNU_EFI_LDFLAGS)

UEFI_OBJCOPY_SECTIONS=.text .sdata .data .dynamic .dynsym .rel .rela .reloc
UEFI_OBJCOPY_FLAGS=$(foreach s,$(UEFI_OBJCOPY_SECTIONS),-j $(s)) --target=$(EFI_TARGET)

.SECONDEXPANSION:
$(UEFI_BUILD_DIR)/%.o: $(UEFI_SRC_DIR)/%.c | $$(@D)/.
	$(CC) $< $(UEFI_CFLAGS) -o $@

$(UEFI_BUILD_DIR)/main.so: $(UEFI_OBJ_FILES)
	$(LD) $^ $(UEFI_LDFLAGS) -o $@

$(UEFI_BUILD_DIR)/main.efi: $(UEFI_BUILD_DIR)/main.so
	$(OBJCOPY) $(UEFI_OBJCOPY_FLAGS) $< $@

