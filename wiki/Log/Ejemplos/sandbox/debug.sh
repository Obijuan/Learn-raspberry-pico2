#!/bin/bash


#-- Directorio donde esta la toolchain
TOOLCHAIN="/home/obijuan/Develop/pico/corev-openhw-gcc-ubuntu2204-20240530"

# -- Nombre del fichero fuente (sin extension)
MAIN="main"

# -- Depurador
GDB=$TOOLCHAIN"/bin/riscv32-corev-elf-gdb"

#-- Parametros del OpenOCD
OPENOCD_PARAM1="-s tcl -f interface/cmsis-dap.cfg -f target/rp2350-riscv.cfg"


#-- Lanzar el OpenOCD
openocd $OPENOCD_PARAM1 -c "adapter speed 5000" &  

#-- Lanzar el depurador
$GDB -q -ex 'target extended-remote :3333' $MAIN.elf
