MBR_BUILD_DIR=build/boot/mbr
MBR_SRC_DIR=boot/mbr

.SECONDEXPANSION:
$(MBR_BUILD_DIR)/mbr: $(MBR_SRC_DIR)/mbr.asm | $$(@D)/.
	nasm -f bin $(MBR_SRC_DIR)/mbr.asm -o $@
