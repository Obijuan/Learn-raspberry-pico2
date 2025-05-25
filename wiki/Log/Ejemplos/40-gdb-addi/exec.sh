#!/bin/bash

openocd -s tcl -f interface/cmsis-dap.cfg -f target/rp2350-riscv.cfg -c "adapter speed 5000" -c "program main.elf verify reset exit"
