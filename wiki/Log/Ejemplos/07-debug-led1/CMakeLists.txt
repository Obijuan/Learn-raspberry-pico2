cmake_minimum_required(VERSION 3.13)
include(pico_sdk_import.cmake)
project(btn0-led_c C CXX ASM)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
pico_sdk_init()

add_executable(btn0-led_c btn0-led.c)
pico_enable_stdio_usb(btn0-led_c 1)
pico_enable_stdio_uart(btn0-led_c 1)
pico_add_extra_outputs(btn0-led_c)
target_link_libraries(btn0-led_c pico_stdlib)

