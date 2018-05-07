ARCH=x86_64
TARGET=$(ARCH)-elf
EFI_TARGET=efi-app-x86_64

BUILD_DIR=build
FORMAT_DIRS=boot/uefi

CC=$(TARGET)-gcc
LD=$(TARGET)-ld
OBJCOPY=$(TARGET)-objcopy
QEMU=qemu-system-$(ARCH)

QEMU_FLAGS=-s -cpu qemu64 -net none -m 1G

.PHONY: all
all:
	@echo "There is no sensible default"

include boot/mbr/Makefile
include boot/uefi/Makefile
include kernel/Makefile

.PHONY: format
format:
	astyle --options=.astylerc $(wildcard $(FORMAT_DIRS)/*.c)

.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)

.PHONY: run
run:
	@echo "make run is deprecated, use make run-efi or make run-mbr"

run-mbr: $(BUILD_DIR)/boot.img
	$(QEMU) $(QEMU_FLAGS) -drive file=$<,if=ide,format=raw

run-efi: $(BUILD_DIR)/boot.img
	$(QEMU) $(QEMU_FLAGS) -bios ${OVMF_DIR}/OVMF.fd -drive file=$<,if=ide,format=raw

BLOCK_SIZE=512
DISK_SIZE=$(shell echo "48 * 1024 * 1024 / $(BLOCK_SIZE)" | bc)
# Beginning of usable space is at 34 LBA
EFI_START=34
# End of usable disk is at -34 LBA
EFI_END=$(shell echo "$(DISK_SIZE) - 34" | bc)
EFI_SIZE=$(shell echo "$(EFI_END) - $(EFI_START)" | bc)

$(BUILD_DIR)/boot.img: $(UEFI_BUILD_DIR)/main.efi $(MBR_BUILD_DIR)/mbr
	dd if=/dev/zero of=$@ bs=$(BLOCK_SIZE) count=$(DISK_SIZE)
	parted $@ -s -a minimal mklabel gpt
	parted $@ -s -a minimal -- mkpart EFI FAT16 $(EFI_START)s $(EFI_END)s
	parted $@ -s -a minimal toggle 1 boot
	dd if=/dev/zero of=$(BUILD_DIR)/tmp.img bs=$(BLOCK_SIZE) count=$(EFI_SIZE)
	mformat -i $(BUILD_DIR)/tmp.img -h 32 -t 32 -n 64 -c 1
	mmd -i build/tmp.img ::/EFI
	mmd -i build/tmp.img ::/EFI/BOOT
	mcopy -i $(BUILD_DIR)/tmp.img $(UEFI_BUILD_DIR)/main.efi ::/EFI/BOOT/BOOTX64.EFI
	dd if=$(BUILD_DIR)/tmp.img of=$@ bs=$(BLOCK_SIZE) count=$(EFI_SIZE) seek=$(EFI_START) conv=notrunc
	dd if=$(MBR_BUILD_DIR)/mbr of=$@ bs=448 count=1 conv=notrunc
