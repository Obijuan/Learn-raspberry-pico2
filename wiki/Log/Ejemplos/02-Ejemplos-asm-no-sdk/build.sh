#!/bin/bash

# -- Ensamblador
AS="/home/obijuan/Develop/pico/corev-openhw-gcc-ubuntu2204-20240530/bin/riscv32-corev-elf-as"

# -- Linker
LD="/home/obijuan/Develop/pico/corev-openhw-gcc-ubuntu2204-20240530/bin/riscv32-corev-elf-ld"

# -- Picotool
PICOTOOL="/home/obijuan/Develop/pico/picotool/build/picotool"

# -- Ensamblado 
$AS -g -march=rv32imac -mabi=ilp32 -I.. -o 09-ledon.o 09-ledon.S

# -- Linkado
$LD -g -m elf32lriscv -T linker.ld -o 09-ledon.elf 09-ledon.o

# -- Convertir a UF2
$PICOTOOL uf2 convert 09-ledon.elf 09-ledon.uf2 --family rp2350-riscv --abs-block

