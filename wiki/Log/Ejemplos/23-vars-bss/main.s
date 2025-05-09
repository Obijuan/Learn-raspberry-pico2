
.include "boot.h"
.include "regs.h"

#---------------------------------------
#-- VARIABLES NO INICIALIZADAS
#---------------------------------------
    .section .bss
    .align 2  #-- Alinear a palabra
v1: .space 4


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

    #-- Inicializar variable v1
    la s0, v1
    li t1, 0xCAFEBACA
    sw t1, 0(s0)

loop:
    #--- Imprimir variable v1 (Palabra)
    lw a0, 0(s0)
    jal print_hex32

    #--- Salto de linea
    jal print_nl

    #-- Esperar a que se reciba un caracter
    jal getchar

    #-- Cambiar estado del led
    jal led_toggle

    j loop

