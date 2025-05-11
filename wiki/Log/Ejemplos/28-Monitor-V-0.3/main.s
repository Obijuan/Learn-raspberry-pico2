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

    la a0, WHITE
    jal print 

    PRINT "1. Mostrar direcciones relevantes\n"
    PRINT "2. Volcar la flash\n"
    PRINT "3. Volcar las Variables de solo lectura\n"
    PRINT "\nESP. Mostrar este menu\n"


prompt:
    CPRINT BLUE, "\n> "

    #-- Esperar a que se reciba un caracter
    jal getchar

    #-- Salvar la tecla
    mv s0, a0

    #-- Eco de al tecla
    jal putchar
    PUTCHAR '\n'

    #-- Recuperar tecla
    mv a0, s0

    #-- Tecla Espacio: Mostrar el menu
    li t0, ' ' 
    beq a0, t0, main

    #-- Tecla 1: Mostrar direcciones
    li t0, '1'
    beq a0, t0, opcion1

    #-- Tecla 2: Volcado flash
    li t0, '2'
    beq a0, t0, opcion2

    #-- Tecla 3: Volcado flash: Variables de solo lectura
    li t0, '3'
    beq a0, t0, opcion3

    #------- Caracter desconocido
    #-- Cambiar estado del led
    jal led_toggle

    #-- Ignorar caracter
    j prompt
    
    
opcion1:
    jal monitorv_print_memory_info
    j prompt
    

opcion2:
    la a0, __flash_ini
    li a1, 16
    jal dump16
    j prompt

opcion3:
    la a0, __flash_ro_vars
    li a1, 16
    jal dump16
    j prompt

