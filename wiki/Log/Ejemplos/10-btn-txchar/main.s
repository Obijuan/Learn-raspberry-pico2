 # ----------------------------------------------
 # -- Envío de un carácter por la UART
 # -- Con cada pulsación del pulsador GPIO15
 # ----------------------------------------------
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

    #-- Configurar el pulsador
    jal button_init15

    #-- Inicializar la UART
    #-- Velocidad: 115200 (con runtime actual)
    jal uart_init 

main_loop:

    #-- Transmitir un asterisco inicial
    li a0, '*'
    jal putchar

    #-- Esperar a que se apriete el pulsador
    jal button_press15

    #-- Cambiar de estado el LED
    jal led_toggle

    #-- Repetir
    j main_loop


# -----------------------------------------------
# -- Delay
# -- Realizar una pausa de medio segundo aprox.
# -----------------------------------------------
delay:
    # -- Usar t0 como contador descendente
    li t0, 0xFFFFFF
delay_loop:
    beq t0,zero, delay_end_loop
    addi t0, t0, -1
    j delay_loop

    # -- Cuando el contador llega a cero
    # -- se termina
delay_end_loop:
    ret

