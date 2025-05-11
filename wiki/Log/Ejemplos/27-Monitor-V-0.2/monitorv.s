# -------------------------------
# -- Funciones de interfaz
# -------------------------------
.global monitorv_print_header
.global monitorv_print_memory_info

.include "riscv.h"
.include "uart.h"
.include "ansi.h"


# ---------------------------------------------
# -- Imprimir cabecera de MONITOR-V
# ---------------------------------------------
.section .rodata
name:    .string "Monitor-V "
version: .string "0.2"
lineah:  .string "──────────────────────────────────"

.section .text
monitorv_print_header:
FUNC_START4

    CPRINT YELLOW, name    #-- Nombre del programa
    CPRINT RED, version    #-- Version
    NL

    #-- Imprimir linea
    CPRINT BLUE, lineah
    NL

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

.section .rodata
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
FUNC_START4

    #-- Comienzo de la flash
    CPRINT WHITE, info1
    CPRINT0x LBLUE, __flash_ini
    NL

    #-- Punto de entrada
    CPRINT WHITE, info2
    CPRINT0x LBLUE, _start
    NL

    #-- VARIABLES DE SOLO LECTURA
    CPRINT WHITE, info3
    CPRINT0x LBLUE, __flash_ro_vars
    NL

    #-- FINAL DEL PROGRAMA
    CPRINT WHITE, info4
    CPRINT0x LBLUE, __flash_end
    NL

    #-- VARIABLES INICIALIZADAS
    CPRINT WHITE, info5
    CPRINT0x LBLUE, __data_ram_ini
    NL

    #-- FIN VARIABLES INICIALIZADAS
    CPRINT WHITE, info6
    CPRINT0x LBLUE, __data_ram_end
    NL

    #-- VARIABLES NO INICIALIZADAS
    CPRINT WHITE, info7
    CPRINT0x LBLUE, __var_no_init
    NL

    #-- FIN DE LA RAM
    CPRINT WHITE, info8
    CPRINT0x LBLUE, __data_end
    NL

    #-- PILA
    CPRINT WHITE, info9
    CPRINT0x LBLUE, __stack_top
    NL

FUNC_END4

    