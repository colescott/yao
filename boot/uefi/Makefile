BOOT_UEFI_BUILD_DIR=build/boot/uefi
BOOT_UEFI_SRC_DIR=boot/uefi

BOOT_UEFI_SRC_FILES=$(wildcard $(BOOT_UEFI_SRC_DIR)/*.c)
BOOT_UEFI_OBJ_FILES=$(patsubst $(BOOT_UEFI_SRC_DIR)/%.c,$(BOOT_UEFI_BUILD_DIR)/%.o, $(BOOT_UEFI_SRC_FILES))

GNU_EFI_CFLAGS=-I ${GNU_EFI_DIR}/include/efi -I ${GNU_EFI_DIR}/include/efi/x86_64
GNU_EFI_LDFLAGS=${GNU_EFI_DIR}/lib/crt0-efi-$(TARGET).o -T ${GNU_EFI_DIR}/lib/elf_$(TARGET)_efi.lds -L ${GNU_EFI_DIR}/lib -l:libgnuefi.a -l:libefi.a

BOOT_UEFI_CFLAGS=-c -Werror -fno-builtin -fno-stack-protector -fpic -fshort-wchar -mno-red-zone -DEFI_FUNCTION_WRAPPER $(GNU_EFI_CFLAGS)
BOOT_UEFI_LDFLAGS=-nostdlib -znocombreloc -shared -Bsymbolic $(GNU_EFI_LDFLAGS)

BOOT_UEFI_OBJCOPY_SECTIONS=.text .sdata .data .dynamic .dynsym .rel .rela .reloc
BOOT_UEFI_OBJCOPY_FLAGS=$(foreach s,$(BOOT_UEFI_OBJCOPY_SECTIONS),-j $(s)) --target=efi-app-$(TARGET)

$(BOOT_UEFI_BUILD_DIR)/%.o: $(BOOT_UEFI_SRC_DIR)/%.c $(BOOT_UEFI_BUILD_DIR)
	$(CC) $< $(BOOT_UEFI_CFLAGS) -o $@

$(BOOT_UEFI_BUILD_DIR)/main.so: $(BOOT_UEFI_OBJ_FILES)
	$(LD) $^ $(BOOT_UEFI_LDFLAGS) -o $@

$(BOOT_UEFI_BUILD_DIR)/main.efi: $(BOOT_UEFI_BUILD_DIR)/main.so
	$(OBJCOPY) $(BOOT_UEFI_OBJCOPY_FLAGS) $< $@

$(BOOT_UEFI_BUILD_DIR):
	mkdir -p $(BOOT_UEFI_BUILD_DIR)

