#!/bin/bash

# -- Nombre del fichero fuente (sin extension)
SRC="blinky"

# -- Ensamblador
AS="/home/obijuan/Develop/pico/corev-openhw-gcc-ubuntu2204-20240530/bin/riscv32-corev-elf-as"

# -- Linker
LD="/home/obijuan/Develop/pico/corev-openhw-gcc-ubuntu2204-20240530/bin/riscv32-corev-elf-ld"

# -- Picotool
PICOTOOL="/home/obijuan/Develop/pico/picotool/build/picotool"

# -- Ensamblado 
$AS -g -march=rv32imac -mabi=ilp32 -I.. -o led.o led.S
$AS -g -march=rv32imac -mabi=ilp32 -I.. -o delay.o delay.S
$AS -g -march=rv32imac -mabi=ilp32 -I.. -o $SRC.o $SRC.S

# -- Linkado
$LD -g -m elf32lriscv -T linker.ld -o $SRC.elf $SRC.o led.o delay.o 

# -- Convertir a UF2
$PICOTOOL uf2 convert $SRC.elf $SRC.uf2 --family rp2350-riscv --abs-block

