version=$1
lib=asm_io
nasm -f elf32 -g -F dwarf -o fargier_moerdijk_v$version.o fargier_moerdijk_v$version.asm
nasm -f elf32 -g -F dwarf -o $lib.o $lib.asm
ld -m elf_i386 -o fargier_moerdijk_v$version.bin fargier_moerdijk_v$version.o $lib.o
