#!/bin/bash

# -- Nombre del fichero fuente (sin extension)
MAIN="main"

echo "QEMU RISC-V lanzado...."

#-- Lanzar el QEMU
qemu-riscv32 -g 3333 $MAIN.elf 



