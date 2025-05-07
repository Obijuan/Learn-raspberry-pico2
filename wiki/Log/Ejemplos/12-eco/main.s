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

main_loop:

    #-- Esperar a recibir un caracter
    jal getchar

    #-- Eco
    jal putchar

    #-- Cambiar de estado el led
    jal led_toggle

    #-- Repetir
    j main_loop 


