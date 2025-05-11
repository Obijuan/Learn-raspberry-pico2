# -------------------------------
# -- Funciones de interfaz
# -------------------------------
.global monitorv_print_header

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

