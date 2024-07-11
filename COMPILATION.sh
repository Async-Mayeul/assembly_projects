version=$1
lib=asm_io
nasm -f elf32 -g -F dwarf -o progamme_v$version.o programme_v$version.asm
nasm -f elf32 -g -F dwarf -o $lib.o $lib.asm
ld -m elf_i386 -o programme_v$version.bin programme_v$version.o $lib.o
