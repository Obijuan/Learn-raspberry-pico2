#!/bin/bash

#-- Directorio donde esta la toolchain
TOOLCHAIN="/home/obijuan/Develop/pico/corev-openhw-gcc-ubuntu2204-20240530"

# -- Nombre del fichero fuente (sin extension)
MAIN="main"

# -- Ensamblador
AS=$TOOLCHAIN"/bin/riscv32-corev-elf-as"

# -- Linker
LD=$TOOLCHAIN"/bin/riscv32-corev-elf-ld"

# -- Picotool
PICOTOOL="/home/obijuan/Develop/pico/picotool/build/picotool"

# -- Ensamblado 
$AS -g -march=rv32i -mabi=ilp32 -I.. -o led.o led.s
$AS -g -march=rv32i -mabi=ilp32 -I.. -o button.o button.s
$AS -g -march=rv32i -mabi=ilp32 -I.. -o debug.o debug.s
$AS -g -march=rv32i -mabi=ilp32 -I.. -o runtime.o runtime.s
$AS -g -march=rv32i -mabi=ilp32 -I.. -o uart.o uart.s
$AS -g -march=rv32imac_zicsr_zifencei_zba_zbb_zbs_zbkb -mabi=ilp32 -I.. -o $MAIN.o $MAIN.s

# -- Linkado
$LD -g -m elf32lriscv -T linker.ld -o $MAIN.elf $MAIN.o  runtime.o \
     led.o button.o debug.o uart.o 

# -- Convertir a UF2
$PICOTOOL uf2 convert $MAIN.elf $MAIN.uf2 --family rp2350-riscv --abs-block

