#---------------------------
#-- Funciones de interfaz
#---------------------------
.global _start   #-- Punto de entrada

.include "riscv.h"
.include "regs.h"
.include "uart.h"
.include "ansi.h"
.include "delay.h"

.section .text

# -- Punto de entrada
_start:

    #-- Acciones de arranque
    la sp, __stack_top

main:
    #-- Configurar perifericos
    jal led_init

    #-- Encender el LED
    jal led_on

loop: 

    #-- Esperar
    DELAY_MS 200

    #-- Cambiar de estado el LED
    jal led_toggle

    j loop
    
