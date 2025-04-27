cmake_minimum_required(VERSION 3.13)
include(pico_sdk_import.cmake)
project(01-Ejemplos-asm C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
pico_sdk_init()

#-- Ejemplo 01-blinky-gpio15
add_executable(01-blinky-gpio15
01-blinky-gpio15.S
)
pico_enable_stdio_usb(01-blinky-gpio15 1)
pico_enable_stdio_uart(01-blinky-gpio15 1)
pico_add_extra_outputs(01-blinky-gpio15)
target_link_libraries(01-blinky-gpio15 pico_stdlib)

#-- Ejemplo 02-ledon-gpio15
add_executable(02-ledon-gpio15
02-ledon-gpio15.S
)
pico_enable_stdio_usb(02-ledon-gpio15 1)
pico_enable_stdio_uart(02-ledon-gpio15 1)
pico_add_extra_outputs(02-ledon-gpio15)
target_link_libraries(02-ledon-gpio15 pico_stdlib)

#-- Ejemplo 03-ledon-gpio15
add_executable(03-ledon-gpio15
03-ledon-gpio15.S
)
pico_enable_stdio_usb(03-ledon-gpio15 1)
pico_enable_stdio_uart(03-ledon-gpio15 1)
pico_add_extra_outputs(03-ledon-gpio15)
target_link_libraries(03-ledon-gpio15 pico_stdlib)

#-- Ejemplo 04-ledon-gpio0
add_executable(04-ledon-gpio0
04-ledon-gpio0.S
)
pico_enable_stdio_usb(04-ledon-gpio0 1)
pico_enable_stdio_uart(04-ledon-gpio0 1)
pico_add_extra_outputs(04-ledon-gpio0)
target_link_libraries(04-ledon-gpio0 pico_stdlib)

#-- Ejemplo 05-ledon
add_executable(05-ledon
05-ledon.S
)
pico_enable_stdio_usb(05-ledon 1)
pico_enable_stdio_uart(05-ledon 1)
pico_add_extra_outputs(05-ledon)
target_link_libraries(05-ledon pico_stdlib)