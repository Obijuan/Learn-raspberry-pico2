
.include "boot.h"
.include "regs.h"

.section .rodata
head1:  .ascii  "Monitor-V   0.1\n"
        .ascii  "──────────────────────────────────\n\0"
info1:  .string "Comienzo flash:   "
info2:  .string "Punto de entrada: "


.section .text

# -- Punto de entrada
.global _start
_start:

    #-- Inicializar la pila
    la sp, _stack_top

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
    jal ansi_cls 

    #-- Imprimir cadena!
    la a0, head1
    jal print

    #-- Imprimir Comienzo de la flash
    la a0, info1
    jal print
    la a0, __flash_ini
    jal print_0x_hex32
    li a0, '\n'
    jal putchar

    #-- Imprimir Punto de entrada
    la a0, info2
    jal print
    la a0, _start
    jal print_0x_hex32
    li a0, '\n'
    jal putchar

    #-- Esperar a que se reciba un caracter
    jal getchar

    #-- Cambiar estado del led
    jal led_toggle

    j main

