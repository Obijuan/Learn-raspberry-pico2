#---------------------------
#-- Funciones de interfaz
#---------------------------
.global _start   #-- Punto de entrada

.include "riscv.h"
.include "delay.h"
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
    jal uart_init

    #-- Encender el LED
    jal led_on

    CLS
    jal print_mstatus

loop: 

    #-- Esperar
    DELAY_MS 200

    #-- Cambiar de estado el LED
    jal led_toggle

    j loop
    
