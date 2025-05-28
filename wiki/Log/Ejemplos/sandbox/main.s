#---------------------------
#-- Funciones de interfaz
#---------------------------
.global _start   #-- Punto de entrada

.include "riscv.h"
.include "regs.h"
.include "delay.h"
.include "led.h"
.include "uart.h"
.include "ansi.h"

.section .text

# -- Punto de entrada
_start:

    #-- Acciones de arranque
    la sp, __stack_top
    jal runtime_init

main:
    #-- Configurar perifericos
    jal led_init
    LED_INIT(2)
    LED_INIT(3)
    jal uart_init

    #-- Estados iniciales de los LEDs
    jal led_off
    LED_ON(2)
    LED_OFF(3)

    #-- ¡Que comiencen las pruebas!
    j mtime_main_test


