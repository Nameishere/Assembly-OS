ASM=nasm
LINKER=ld

SRC_DIR=src
BUILD_DIR=bin

all: bootloader floppy_image Header

#
# Floppy image
#

OS: $(SRC_DIR)/BOOTX64.asm
	$(ASM) -f elf64 ./$(SRC_DIR)/BOOTX64.asm -o ./$(BUILD_DIR)/BOOTX64.o

File: $(SRC_DIR)/BOOTX64.asm OS
	$(LINKER) ./$(BUILD_DIR)/BOOTX64.o -o ./$(BUILD_DIR)/BOOTX64.EFI -m i386pep --subsystem 10 

Converter:  $(SRC_DIR)/Converter.asm
	$(ASM) -f elf64 ./$(SRC_DIR)/Converter.asm -o ./$(BUILD_DIR)/Converter.o

Link: $(SRC_DIR)/Converter.asm Converter
	$(LINKER) ./$(BUILD_DIR)/Converter.o -o ./$(BUILD_DIR)/Converter



clean: 
	rm -f ./bin/* 
	rm -f test.hdd
