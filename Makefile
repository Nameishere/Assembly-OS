ASM=nasm
LINKER=ld

SRC_DIR=src
BUILD_DIR=bin

all: bootloader floppy_image Header

#
# Floppy image
#

Converter:  $(SRC_DIR)/Converter.asm
	$(ASM) -f elf64 ./$(SRC_DIR)/Converter.asm -o ./$(BUILD_DIR)/Converter.o

Link: $(SRC_DIR)/Converter.asm Converter
	$(LINKER) ./$(BUILD_DIR)/Converter.o -o ./$(BUILD_DIR)/Converter


Test:  $(SRC_DIR)/Test.asm
	$(ASM) -f elf64 ./$(SRC_DIR)/Test.asm -o ./$(BUILD_DIR)/Test.o

Test_link: $(SRC_DIR)/Test.asm Test
	$(LINKER) ./$(BUILD_DIR)/Test.o -o ./$(BUILD_DIR)/Test



bootloader:  $(SRC_DIR)/boot.asm
	$(ASM) -f bin ./$(SRC_DIR)/boot.asm -o ./$(BUILD_DIR)/boot.bin


Header:  $(SRC_DIR)/GPTHeader.asm
	$(ASM) -f bin ./$(SRC_DIR)/GPTHeader.asm -o ./$(BUILD_DIR)/GPTHeader.bin


clean: 
	rm -f ./bin/* 


floppy_image: $(BUILD_DIR)/boot.bin bootloader Header
	cat $(BUILD_DIR)/boot.bin $(BUILD_DIR)/GPTHeader.bin > $(BUILD_DIR)/floppy.iso

