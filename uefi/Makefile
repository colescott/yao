BUILD_DIR=build
SRC_DIR=src
TARGET=x86_64

CC=gcc
LD=ld
OBJCOPY=objcopy
QEMU=qemu-system-$(TARGET)

SRC_FILES=$(wildcard $(SRC_DIR)/*.c)
OBJ_FILES=$(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o, $(SRC_FILES))

GNU_EFI_CFLAGS=-I ${GNU_EFI_DIR}/include/efi -I ${GNU_EFI_DIR}/include/efi/x86_64
GNU_EFI_LDFLAGS=${GNU_EFI_DIR}/lib/crt0-efi-$(TARGET).o -T ${GNU_EFI_DIR}/lib/elf_$(TARGET)_efi.lds -L ${GNU_EFI_DIR}/lib -l:libgnuefi.a -l:libefi.a

CFLAGS=-c -fno-stack-protector -fpic -fshort-wchar -mno-red-zone -DEFI_FUNCTION_WRAPPER $(GNU_EFI_CFLAGS)
LDFLAGS=-nostdlib -znocombreloc -shared -Bsymbolic $(GNU_EFI_LDFLAGS)

OBJCOPY_SECTIONS=.text .sdata .data .dynamic .dynsym .rel .rela .reloc
OBJCOPY_FLAGS=$(foreach s,$(OBJCOPY_SECTIONS),-j $(s)) --target=efi-app-$(TARGET)

QEMU_FLAGS=-s -cpu qemu64 -bios ${OVMF_DIR}/OVMF.fd -net none

.PHONY: run
run: $(BUILD_DIR)/uefi.img
	$(QEMU) $(QEMU_FLAGS) -drive file=$<,if=ide

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c $(BUILD_DIR)
	$(CC) $< $(CFLAGS) -o $@

$(BUILD_DIR)/main.so: $(OBJ_FILES)
	ld $^ $(LDFLAGS) -o $@

$(BUILD_DIR)/main.efi: $(BUILD_DIR)/main.so
	objcopy $(OBJCOPY_FLAGS) $< $@

$(BUILD_DIR)/uefi.img: $(BUILD_DIR)/main.efi
	dd if=/dev/zero of=$@ bs=512 count=93750
	parted $@ -s -a minimal mklabel gpt
	parted $@ -s -a minimal mkpart EFI FAT16 2048s 93716s
	parted $@ -s -a minimal toggle 1 boot
	dd if=/dev/zero of=$(BUILD_DIR)/tmp.img bs=512 count=91669
	mformat -i $(BUILD_DIR)/tmp.img -h 32 -t 32 -n 64 -c 1
	mcopy -i $(BUILD_DIR)/tmp.img $< ::
	dd if=$(BUILD_DIR)/tmp.img of=$@ bs=512 count=91669 seek=2048 conv=notrunc
	rm $(BUILD_DIR)/tmp.img

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

