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
$AS -g -march=rv32i -mabi=ilp32  -o led.o led.s
$AS -g -march=rv32i -mabi=ilp32  -o button.o button.s
$AS -g -march=rv32i -mabi=ilp32  -o debug.o debug.s
$AS -g -march=rv32i -mabi=ilp32  -o runtime.o runtime.s
$AS -g -march=rv32i -mabi=ilp32  -o uart.o uart.s
$AS -g -march=rv32i -mabi=ilp32  -o delay.o delay.s
$AS -g -march=rv32i -mabi=ilp32  -o dump.o dump.s
$AS -g -march=rv32i -mabi=ilp32  -o ansi.o ansi.s
$AS -g -march=rv32i -mabi=ilp32  -o monitorv.o monitorv.s
$AS -g -march=rv32i -mabi=ilp32  -o boot.o boot.s
$AS -g -march=rv32i_zicsr -mabi=ilp32  -o csr.o csr.s
$AS -g -march=rv32imac_zicsr_zifencei_zba_zbb_zbs_zbkb -mabi=ilp32  -o $MAIN.o $MAIN.s
# $AS -g -march=rv32imac_zicsr_zifencei_zba_zbb_zbs_zbkb -mabi=ilp32 -I.. -o $MAIN.o $MAIN.s

# -- Linkado
$LD -g -m elf32lriscv -T linker.ld -o $MAIN.elf \
     boot.o $MAIN.o  led.o

# -- Convertir a UF2
$PICOTOOL uf2 convert $MAIN.elf $MAIN.uf2 --family rp2350-riscv --abs-block

