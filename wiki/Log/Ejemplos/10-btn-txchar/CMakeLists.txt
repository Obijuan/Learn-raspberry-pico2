cmake_minimum_required(VERSION 3.13)
include(pico_sdk_import.cmake)
project(txchar_c C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
pico_sdk_init()

add_executable(txchar_c txchar.c)
pico_enable_stdio_usb(txchar_c 1)
pico_enable_stdio_uart(txchar_c 1)
pico_add_extra_outputs(txchar_c)
target_link_libraries(txchar_c pico_stdlib)

