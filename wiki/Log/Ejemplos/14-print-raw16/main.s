 # ----------------------------------------------
 # -- Contador de 8-bits
 # -- Se imprime en la consola hexadecimal del tio
 # -- un contador que arranca en 00
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

    #-- Configurar el boton
    jal button_init15

    #-- Inicializar la UART
    #-- Velocidad: 115200 (con runtime actual)
    jal uart_init 

    #-- Encender el LED
    jal led_on


loop:
    #-- Imprimir varios numeros de 16bits
    li a0, 0x1234
    jal print_raw16

    li a0, 0xABCD
    jal print_raw16

    li a0, 0xBACA
    jal print_raw16

    li a0, 0x0
    jal print_raw16

    #-- Esperar a que se apriete el pulsador
    jal button_press15

    #-- Cambiar estado del led
    jal led_toggle

    j loop

    

