default: run

.PHONY: clean

ld/multiboot_header.o: src/asm/multiboot_header.asm
	mkdir -p build
	nasm -f elf64 src/asm/multiboot_header.asm -o build/multiboot_header.o

build/boot.o: src/asm/boot.asm
	mkdir -p build
	nasm -f elf64 src/asm/boot.asm -o build/boot.o

build/kernel.bin: build/multiboot_header.o build/boot.o src/asm/linker.ld
	x86_64-pc-elf-ld -n -o build/kernel.bin -T src/asm/linker.ld build/multiboot_header.o build/boot.o

build/os.iso: build/kernel.bin src/asm/grub.cfg
	mkdir -p build/isofiles/boot/grub
	cp src/asm/grub.cfg build/isofiles/boot/grub
	cp build/kernel.bin build/isofiles/boot/
	grub-mkrescue -o build/os.iso build/isofilesbuild/multiboot_header.o: multiboot_header.asm
	mkdir -p build
	nasm -f elf64 multiboot_header.asm -o build/multiboot_header.o

build/boot.o: boot.asm
	mkdir -p build
	nasm -f elf64 boot.asm -o build/boot.o

build/kernel.bin: build/multiboot_header.o build/boot.o linker.ld
	x86_64-pc-elf-ld -n -o build/kernel.bin -t linker.ld build/multiboot_header.o build/boot.o

build/os.iso: build/kernel.bin grub.cfg
	mkdir -p build/isofiles/boot/grub
	cp grub.cfg build/isofiles/boot/grub
	cp build/kernel.bin build/isofiles/boot/
	grub-mkrescue -o build/os.iso build/isofiles

run: build/os.iso
	qemu-system-x86_64 -cdrom build/os.iso

build: build/os.iso

clean:
	cargo clean

