ARCH=x86_64
TARGET=$(ARCH)-elf
EFI_TARGET=efi-app-x86_64

BUILD_DIR=build
FORMAT_DIRS=uefi/src

CC=$(TARGET)-gcc
LD=$(TARGET)-ld
OBJCOPY=$(TARGET)-objcopy
QEMU=qemu-system-$(ARCH)

QEMU_FLAGS=-s -cpu qemu64 -bios ${OVMF_DIR}/OVMF.fd -net none -m 1G

.PHONY: all
all:
	@echo "There is no sensible default"

include boot/mbr/Makefile
include boot/uefi/Makefile
include kernel/Makefile

.PHONY: format
format:
	astyle --options=.astylerc $(wildcard $(FORMAT_DIRS)/*)

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)

.PHONY: run
run: $(BUILD_DIR)/uefi.img
	$(QEMU) $(QEMU_FLAGS) -drive file=$<,if=ide,format=raw

$(BUILD_DIR)/uefi.img: $(UEFI_BUILD_DIR)/main.efi
	dd if=/dev/zero of=$@ bs=512 count=93750
	parted $@ -s -a minimal mklabel gpt
	parted $@ -s -a minimal mkpart EFI FAT16 2048s 93716s
	parted $@ -s -a minimal toggle 1 boot
	dd if=/dev/zero of=$(BUILD_DIR)/tmp.img bs=512 count=91669
	mformat -i $(BUILD_DIR)/tmp.img -h 32 -t 32 -n 64 -c 1
	mcopy -i $(BUILD_DIR)/tmp.img $< ::
	dd if=$(BUILD_DIR)/tmp.img of=$@ bs=512 count=91669 seek=2048 conv=notrunc
