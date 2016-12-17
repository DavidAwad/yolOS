
default: kernel.bin

multiboot_header.o: multiboot_header.asm
	nasm -f elf64 multiboot_header.asm

boot.o: boot.asm
	nasm -f elf64 boot.asm

kernel.bin: multiboot_header.o boot.o linker.ld
	x86_64-pc-elf-ld -n -o kernel.bin -T linker.ld multiboot_header.o boot.o
