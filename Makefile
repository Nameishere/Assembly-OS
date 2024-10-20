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



clean: 
	rm -f ./bin/* 
