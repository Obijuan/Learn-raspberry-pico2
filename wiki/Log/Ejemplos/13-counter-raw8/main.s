 # ----------------------------------------------
 # -- Programa de ECO
 # -- Todo lo recibido se reenvía de nuevo al PC
 # -- Además se cambia el estado del LED con cada
 # -- caracter recibido
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

    #-- Inicializar la UART
    #-- Velocidad: 115200 (con runtime actual)
    jal uart_init 

    #-- Encender el LED
    jal led_on

    #-- Inicializar contador
    li s0, 0

main_loop:

    #-- Imprimir el contador
     mv a0, s0
    jal print_raw8

    #-- Cambiar de estado el led
    jal led_toggle

    #-- Incrementar contador
    addi s0, s0, 1

    #-- Esperar
    jal delay

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
