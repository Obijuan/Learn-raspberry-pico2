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


    #-- Bucle principal
loop:

    #-- Esperar hasta que se apriete el pulsador
    jal button_press

    #-- Cambiar el estado del LED
    jal led_toggle

    #-- Repetir
    j loop

