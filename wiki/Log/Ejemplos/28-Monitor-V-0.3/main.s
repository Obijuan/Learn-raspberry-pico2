#---------------------------
#-- Funciones de interfaz
#---------------------------
.global _start   #-- Punto de entrada

.include "riscv.h"
.include "regs.h"
.include "uart.h"
.include "ansi.h"

.section .text

# -- Punto de entrada
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
    #jal monitorv_print_memory_info

    la a0, WHITE
    jal print 

    PRINT "1. Mostrar direcciones relevantes\n"
    PRINT "\nESP. Mostrar este menu\n"


prompt:
    CPRINT BLUE, "\n> "

    #-- Esperar a que se reciba un caracter
    jal getchar

    #-- Tecla Espacio: Mostrar el menu
    li t0, ' ' 
    beq a0, t0, main

    #-- Tecla 1: Mostrar direcciones
    li t0, '1'
    beq a0, t0, opcion1

    #------- Caracter desconocido
    #-- Cambiar estado del led
    jal led_toggle

    #-- Ignorar caracter
    j prompt
    
    
opcion1:
    PUTCHAR '1'
    PUTCHAR '\n'
    jal monitorv_print_memory_info
    j prompt
    

    #-- Repetir
    j main

