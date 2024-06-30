lib=asm_io
nasm -f elf32 -g -F dwarf -o fargier_moerdijk_v3.o fargier_moerdijk_v3.asm
nasm -f elf32 -g -F dwarf -o $lib.o $lib.asm
ld -m elf_i386 -o fargier_moerdijk_v3.bin fargier_moerdijk_v3.o $lib.o
