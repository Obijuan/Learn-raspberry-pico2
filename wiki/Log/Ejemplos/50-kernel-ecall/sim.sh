#!/bin/bash

#-- Directorio donde esta la toolchain
TOOLCHAIN="/home/obijuan/Develop/pico/corev-openhw-gcc-ubuntu2204-20240530"

# -- Nombre del fichero fuente (sin extension)
MAIN="main"

# -- Depurador
GDB=$TOOLCHAIN"/bin/riscv32-corev-elf-gdb"

#-- Lanzar el QEMU
qemu-riscv32 -g 3333 $MAIN.elf &

#-- Lanzar el depurador
$GDB -q -ex 'target remote :3333' $MAIN.elf


