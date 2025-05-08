
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


    #-- Inicializar contador
    li s0, 0
loop:

    mv a0, s0
    jal print_hex4

    li a0, ' '
    jal putchar

    #-- Incrementar contador
    addi s0, s0, 1

    li t0, 16
    blt s0, t0, loop

    #-- Hemos llegado a F
    #-- Imprimir un salto de linea
    li a0, '\n'
    jal putchar 

    li a0, '\r'
    jal putchar

    #-- Cambiar estado del led
    jal led_toggle

    #-- Reiniciar contador
    li s0, 0

    #-- Esperar a que se apriete el pulsador
    jal button_press15

    j loop

    

