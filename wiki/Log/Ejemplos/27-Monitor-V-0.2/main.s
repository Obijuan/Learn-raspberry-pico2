
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

    j main


.section .rodata
name:    .string "Monitor-V "
version: .string "0.2"
lineah:  .string "──────────────────────────────────"

.section .text

# ---------------------------------------------
# -- Imprimir cabecera de MONITOR-V
# ---------------------------------------------
monitorv_print_header:
    FUNC_START4

    CPRINT YELLOW, name    #-- Nombre del programa
    CPRINT RED, version    #-- Version
    NL

    #-- Imprimir linea
    CPRINT BLUE, lineah
    NL

    FUNC_END4





# ------------------------------------------------------------
# - Imprimir informacion sobre las direcciones disponibles
# ------------------------------------------------------------
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
    addi sp, sp, -16
    sw ra, 12(sp)

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

    lw ra, 12(sp)
    addi sp, sp, 16
    ret

    