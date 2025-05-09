
.include "boot.h"
.include "regs.h"

.section .rodata
head1:  .ascii  "Monitor-V   0.1\n"
        .ascii  "──────────────────────────────────\n\0"
info1:  .string "Comienzo flash:          "
info2:  .string "Punto de entrada:        "
info3:  .string "Variables read-only:     "
info4:  .string "Final del programa:      "
info5:  .string "Variables inicializadas: "
info6:  .string "Fin vars. inicializadas: "
info7:  .string "Variables no inicializ.: "
info8:  .string "Fin vars. no inicializ.: "
info9:  .string "Puntero de pila:         "


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

    #-- VARIABLES DE SOLO LECTURA
    la a0, info3
    jal print
    la a0, __flash_ro_vars
    jal print_0x_hex32
    li a0, '\n'
    jal putchar

    #-- FINAL DEL PROGRAMA
    la a0, info4
    jal print
    la a0, __flash_end
    jal print_0x_hex32
    li a0, '\n'
    jal putchar

    #-- VARIABLES INICIALIZADAS
    la a0, info5
    jal print
    la a0, __data_ram_ini
    jal print_0x_hex32
    li a0, '\n'
    jal putchar

    #-- FIN VARIABLES INICIALIZADAS
    la a0, info6
    jal print
    la a0, __data_ram_end
    jal print_0x_hex32
    li a0, '\n'
    jal putchar

    #-- VARIABLES NO INICIALIZADAS
    la a0, info7
    jal print
    la a0, __var_no_init
    jal print_0x_hex32
    li a0, '\n'
    jal putchar

    #-- FIN DE LA RAM
    la a0, info8
    jal print
    la a0, __data_end
    jal print_0x_hex32
    li a0, '\n'
    jal putchar

    #-- PILA
    la a0, info9
    jal print
    la a0, _stack_top
    jal print_0x_hex32
    li a0, '\n'
    jal putchar



    #-- Esperar a que se reciba un caracter
    jal getchar

    #-- Cambiar estado del led
    jal led_toggle

    j main

