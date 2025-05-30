
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

    #--- Imprimir palabras
    li a0, 0xCAFEBACA
    jal print_hex32

    li a0, ','
    jal putchar

    li a0, ' '
    jal putchar

    li a0, 0xBEBECAFE
    jal print_hex32

    li a0, ','
    jal putchar

    li a0, ' '
    jal putchar

    li a0, 0x12345678
    jal print_hex32
   
    #--- Salto de linea
    li a0, '\n'
    jal putchar

    li a0, '\r'
    jal putchar

    #-- Esperar a que se reciba un caracter
    jal getchar

    #-- Cambiar estado del led
    jal led_toggle

    j loop

