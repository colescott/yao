MBR_BUILD_DIR=build/boot/mbr
MBR_SRC_DIR=boot/mbr

$(MBR_BUILD_DIR)/mbr: $(MBR_BUILD_DIR) $(MBR_SRC_DIR)/mbr.asm
	nasm -f bin $(MBR_SRC_DIR)/mbr.asm -o $@

$(MBR_BUILD_DIR):
	mkdir -p $(MBR_BUILD_DIR)
