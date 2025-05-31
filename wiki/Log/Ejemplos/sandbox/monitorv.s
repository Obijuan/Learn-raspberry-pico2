# -------------------------------
# -- Funciones de interfaz
# -------------------------------
.global monitorv_main

.include "riscv.h"
.include "regs.h"
.include "uart.h"
.include "ansi.h"


# -----------------------
# -- MAIN 
# -----------------------
monitorv_main:
FUNC_START4
 

 main_loop:

    #-- Borrar pantalla
    CLS

    #-- Imprimir cabecera
    jal monitorv_print_header

    COLOR WHITE 

    PRINT "1. Mostrar direcciones relevantes\n"
    PRINT "2. Volcar la flash\n"
    PRINT "3. Volcar las Variables de solo lectura\n"
    PRINT "4. READ TIMER\n"
    PRINT "5. Start timer\n"
    PRINT "6. Stop timer\n"
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
    beq a0, t0, main_loop

    #-- Tecla 1: Mostrar direcciones
    li t0, '1'
    beq a0, t0, opcion1

    #-- Tecla 2: Volcado flash
    li t0, '2'
    beq a0, t0, opcion2

    #-- Tecla 3: Volcado flash: Variables de solo lectura
    li t0, '3'
    beq a0, t0, opcion3

    #-- Tecla 4: LPOSC
    li t0, '4'
    beq a0, t0, opcion4

    #-- Tecla 5: TEST
    li t0, '5'
    beq a0, t0, opcion5

    li t0, '6'
    beq a0, t0, opcion6

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

opcion4:

    CPRINT WHITE, "Registros del LPOSC\n"
    CPRINT YELLOW, "* LPOSC_FREQ_KHZ_INT:  "

    COLOR LBLUE
    li t0, LPOSC_FREQ_KHZ_INT
    lw a0, 0(t0)
    jal print_hex32
    NL

    CPRINT YELLOW, "* LPOSC_FREQ_KHZ_FRAC: "

    COLOR LBLUE
    li t0, LPOSC_FREQ_KHZ_FRAC
    lw a0, 0(t0)
    jal print_hex32
    NL

    CPRINT YELLOW, "* POWMAN_TIMER:    "
    COLOR LBLUE
    li t0, POWMAN_TIMER
    lw a0, 0(t0)
    jal print_hex32
    NL

    CPRINT YELLOW, "* READ_TIME_LOWER: "
    COLOR LBLUE
    li t0, READ_TIME_LOWER
    lw a0, 0(t0)
    jal print_hex32
    NL

    j prompt

opcion5:
    PRINT "Timer ON\n"
    li t0, POWMAN_TIMER
    li t1, 0x5afe0000 + BIT1
    sw t1, 0(t0)

    j prompt

opcion6:
    PRINT "Timer OFF\n"
    li t0, POWMAN_TIMER
    li t1, 0x5afe0000
    sw t1, 0(t0)

    j prompt

FUNC_END4


# ---------------------------------------------
# -- Imprimir cabecera de MONITOR-V
# ---------------------------------------------

.section .text

monitorv_print_header:
FUNC_START4

    CPRINT LYELLOW, "Monitor-V "
    CPRINT LRED, "0.4\n"
    CPRINT BLUE, "──────────────────────────────────\n"

FUNC_END4


# -------------------------------------------------------------------
# - Imprimir informacion sobre las direcciones disponibles
# - Las direcciones importantes están definidas en el linker script
# - y estan accesibles a traves de etiquetas que comienzan por __   
# - Las etiquetas que comienzan solo por `_` estan definidas en 
# - el programa principal
# -------------------------------------------------------------------
# - Simbolos creados en el linker script:
# -   __flash_ini  
# -   __flash_ro_vars
# -   __flash_end
# -   __data_ram_ini
# -   __data_ram_end
# -   __var_no_init
# -   __data_end
# -   __stack_top
# -
# - Simbolos creados en el main
# -   _start
# -------------------------------------------------------------------
monitorv_print_memory_info:

.section .text
FUNC_START4

    #-- Comienzo de la flash
    CPRINT WHITE, "Comienzo flash:          "
    CPRINT0x LBLUE, __flash_ini
    NL

    #-- Punto de entrada
    CPRINT WHITE, "Punto de entrada:        "
    CPRINT0x LBLUE, _start
    NL

    #-- VARIABLES DE SOLO LECTURA
    CPRINT WHITE, "Variables read-only:     "
    CPRINT0x LBLUE, __flash_ro_vars
    NL

    #-- FINAL DEL PROGRAMA
    CPRINT WHITE, "Final del programa:      "
    CPRINT0x LBLUE, __flash_end
    NL

    #-- VARIABLES INICIALIZADAS
    CPRINT WHITE, "Variables inicializadas: "
    CPRINT0x LBLUE, __data_ram_ini
    NL

    #-- FIN VARIABLES INICIALIZADAS
    CPRINT WHITE, "Fin vars. inicializadas: "
    CPRINT0x LBLUE, __data_ram_end
    NL

    #-- VARIABLES NO INICIALIZADAS
    CPRINT WHITE, "Variables no inicializ.: "
    CPRINT0x LBLUE, __var_no_init
    NL

    #-- FIN DE LA RAM
    CPRINT WHITE, "Fin vars. no inicializ.: "
    CPRINT0x LBLUE, __data_end
    NL

    #-- PILA
    CPRINT WHITE, "Puntero de pila:         "
    CPRINT0x LBLUE, __stack_top
    NL

FUNC_END4

    