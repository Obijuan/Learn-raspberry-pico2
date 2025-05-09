
.include "boot.h"
.include "regs.h"

.section .rodata
v1:  .word 0xBEBECAFE 

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

loop:
    #--- Imprimir variable v1 (Palabra)
    la t0, v1
    lw a0, 0(t0)
    jal print_hex32

    #--- Salto de linea
    jal print_nl

    #-- Esperar a que se reciba un caracter
    jal getchar

    #-- Cambiar estado del led
    jal led_toggle

    j loop

