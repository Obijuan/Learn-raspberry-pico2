cmake_minimum_required(VERSION 3.13)
include(pico_sdk_import.cmake)
project(01-Ejemplos-asm C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
pico_sdk_init()
add_executable(01-blinky-gpio15
01-blinky-gpio15.S
)
pico_enable_stdio_usb(01-blinky-gpio15 1)
pico_enable_stdio_uart(01-blinky-gpio15 1)
pico_add_extra_outputs(01-blinky-gpio15)
target_link_libraries(01-blinky-gpio15 pico_stdlib)

