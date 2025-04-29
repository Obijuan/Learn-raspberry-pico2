#!/bin/bash

PROG=build/btn0-led_c

PICO_TOOLCHAIN_PATH=/home/obijuan/Develop/pico/corev-openhw-gcc-ubuntu2204-20240530/bin

$PICO_TOOLCHAIN_PATH/riscv32-corev-elf-objdump -d $PROG.elf > $PROG.dasm

