.include "boot.h"
.include "gpio.h"

.section .text

# -- Punto de entrada
.global _start
_start:

    #-- Inicializar la pila
    la sp, _stack_top

    #-- Configurar el LED
    jal led_init  

    #-- Configurar el pulsador
    jal button_init

    #-- Mostrar el valor de la pila por el LED
    #-- Bit a bit, empezando por el bit 31
    #-- Con cada pulsacion se muestra el siguiente bit
    mv a0, sp
    jal debug_led1_MSB

    #-- Al terminar hacer parpadear el LED rápidamente
    jal led_blinky

    #-- Fin
inf:
    j inf

