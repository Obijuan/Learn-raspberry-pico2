
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

    #-- Imprimir el byte
    mv a0, s0
    jal print_hex8

    li a0, ' '
    jal putchar

    #-- Incrementar contador
    addi s0, s0, 1

    #-- Comprobar si se han impreso 16 bytes
    #-- correspondientes a una línea
    #-- Ailar los 4 bits de menor peso
    andi t1, s0, 0xF

    #-- Cuando sean cero, hemos terminado la linea
    #-- De lo contrario seguimos imprimiendo bytes
    bne t1, zero, loop

    #-- Hemos llegado a 16 bytes (linea completa)
    #-- Imprimir un salto de linea
    li a0, '\n'
    jal putchar 

    li a0, '\r'
    jal putchar

    #-- Esperar a que se apriete el pulsador
    jal button_press15

    #-- Cambiar estado del led
    jal led_toggle

    j loop


    

