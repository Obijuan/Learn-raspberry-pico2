
.include "riscv.h"
.include "boot.h"
.include "regs.h"
.include "uart.h"
.include "ansi.h"


.section .rodata
test:    .string "TESTING...\n"

.section .text

# -- Punto de entrada
.global _start
_start:

    #-- Inicializar la pila
    la sp, __stack_top

    #-- Inicializar el sistema
    jal	runtime_init

    #-- Inicializar las variables
    #jal runtime_init_vars

    #-- Configurar el LED
    jal led_init

    #-- Inicializar la UART
    #-- Velocidad: 115200 (con runtime actual)
    jal uart_init 

    #-- Encender el LED
    jal led_on

main: 
    #-- Borrar pantalla
    CLS

    #-- Imprimir cabecera
    jal monitorv_print_header

    #-- Mostrar informacion sobre las direciones
    jal monitorv_print_memory_info

    #-- Esperar a que se reciba un caracter
    jal getchar

    #-- Cambiar estado del led
    jal led_toggle

    #-- Repetir
    j main

