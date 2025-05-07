#!/bin/bash

# -- Configuracion del proyecto para los ejemplos en C

#-- Path hacia el pico-sdk
export PICO_SDK_PATH=/home/obijuan/Develop/pico/pico-sdk

#-- Path hacia las toolchains del riscv
export PICO_TOOLCHAIN_PATH=/home/obijuan/Develop/pico/corev-openhw-gcc-ubuntu2204-20240530

mkdir -p build
cd build

#-- Generar el Makefile
cmake -DPICO_PLATFORM=rp2350-riscv ..


