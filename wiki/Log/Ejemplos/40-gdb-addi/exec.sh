#!/bin/bash

#-- Script para programar la pico2 a través del depurador del DEBUG PROBE

openocd -s tcl -f interface/cmsis-dap.cfg -f target/rp2350-riscv.cfg -c "adapter speed 5000" -c "program main.elf verify reset exit"
