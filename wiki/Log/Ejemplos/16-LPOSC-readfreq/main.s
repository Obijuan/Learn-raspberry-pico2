
.include "boot.h"
.include "regs.h"

.section .text

# -- Punto de entrada
.global _start
_start:

    #-- Inicializar la pila
    la sp, _stack_top

    #-- Inicializar el sistema
    jal	runtime_init

    #-- Configurar el LED
    jal led_init

    #-- Configurar el boton
    jal button_init15

    #-- Inicializar la UART
    #-- Velocidad: 115200 (con runtime actual)
    jal uart_init 

    #-- Encender el LED
    jal led_on


loop:
   
    li t0, LPOSC_FREQ_KHZ_INT
    lw a0, 0(t0)
    jal print_raw32

    li t0, LPOSC_FREQ_KHZ_FRAC
    lw a0, 0(t0)
    jal print_raw32

    #-- Esperar a que se apriete el pulsador
    jal button_press15

    #-- Cambiar estado del led
    jal led_toggle

    j loop

    

