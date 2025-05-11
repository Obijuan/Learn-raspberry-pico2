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

    