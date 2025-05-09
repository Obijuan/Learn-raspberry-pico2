
.include "boot.h"
.include "regs.h"

.section .data
msg:   .string "Hola Mundo!!!!\n"

.section .text

# -- Punto de entrada
.global _start
_start:

    #-- Inicializar la pila
    la sp, _stack_top

    #-- Inicializar el sistema
    jal	runtime_init

    #-- Inicializar las variables
    jal runtime_init_vars

    #-- Configurar el LED
    jal led_init

    #-- Inicializar la UART
    #-- Velocidad: 115200 (con runtime actual)
    jal uart_init 

    #-- Encender el LED
    jal led_on

main: 
    #-- Imprimir cadena!
    la a0, msg
    jal print

    #-- Esperar a que se reciba un caracter
    jal getchar

    #-- Cambiar estado del led
    jal led_toggle

    j main

