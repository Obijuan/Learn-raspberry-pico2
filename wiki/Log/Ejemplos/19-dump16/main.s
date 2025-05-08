
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

    #-- Direccion de volcado
    li s0, 0x10000000

loop:

    #-- Realizar volcado
    mv a0, s0  #-- Dirección
    li a1, 4   #-- Número de bloques
    jal dump16

    #-- s0: Siguiente direccion
    mv s0, a0

    #-- Esperar a que se reciba un caracter
    jal getchar

    #-- Cambiar estado del led
    jal led_toggle

    j loop

