cmake_minimum_required(VERSION 3.13)
include(pico_sdk_import.cmake)
project(txchar_c C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
pico_sdk_init()

add_executable(rxchar_c rxchar.c)
pico_enable_stdio_usb(rxchar_c 1)
pico_enable_stdio_uart(rxchar_c 1)
pico_add_extra_outputs(rxchar_c)
target_link_libraries(rxchar_c pico_stdlib)

