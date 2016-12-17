# yolOS
a "just-for-fun" operating system built from the ground up. Currently Boots. That's about it. 

It is lazy and uses the grand unified boot loader to save some time, it currently just writes information to the screen. namely, Hello World.

## How it works
Take a look at `linker.ld`, it sends the multiboot header as the first portion of the program. This ensures to GRUB that this operating system is bootable, and then proceeds to run the text section in `boot.asm`. 

