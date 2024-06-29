lib=asm_io
nasm -f elf32 -g -F dwarf -o fargier_moerdijk_v2.o fargier_moerdijk_v2.asm
nasm -f elf32 -g -F dwarf -o $lib.o $lib.asm
ld -m elf_i386 -o fargier_moerdijk_v2.bin fargier_moerdijk_v2.o $lib.o
