#---------------------------
#-- Funciones de interfaz
#---------------------------
.global _start   #-- Punto de entrada

.include "riscv.h"
.include "delay.h"
.include "uart.h"
.include "ansi.h"

.section .text

# -- Punto de entrada
_start:

    #-- Acciones de arranque
    la sp, __stack_top
    jal runtime_init

main:
    #-- Configurar perifericos
    jal led_init
    jal uart_init

    #-- Encender el LED
    jal led_on

    #-- Imprimir los registros privilegiados
    CLS
    jal print_mstatus
    NL

    CPRINT LYELLOW, "MISA: "

    #-- Leer el registro MISA
    COLOR BLUE
    csrrw a0, misa, zero
    mv s0, a0
    jal print_0x_hex32
    NL 

    #-- Imprimir bit MXL
    CPRINT YELLOW, "  MXL:  "
    COLOR LBLUE
    mv a0, s0
    srli a0, a0, 30
    jal print_bin2
    CPRINT WHITE, " (Bits del procesador)"
    NL

    #-- Imprimir bit X
    CPRINT YELLOW, "  X:    "
    COLOR LBLUE
    mv a0, s0
    srli a0, a0, 23
    jal print_bin1
    CPRINT WHITE, "  (Non standard extensions)"
    NL

    #-- Imprimir bit U
    CPRINT YELLOW, "  U:    "
    COLOR LBLUE
    mv a0, s0
    srli a0, a0, 20
    jal print_bin1
    CPRINT WHITE, "  (U-mode implemented)"
    NL

    #-- Imprimir bit M
    CPRINT YELLOW, "  M:    "
    COLOR LBLUE
    mv a0, s0
    srli a0, a0, 12
    jal print_bin1
    CPRINT WHITE, "  (M extension)"
    NL

    #-- Imprimir bit I
    CPRINT YELLOW, "  I:    "
    COLOR LBLUE
    mv a0, s0
    srli a0, a0, 8
    jal print_bin1
    CPRINT WHITE, "  (RVI)"
    NL

    #-- Imprimir bit C
    CPRINT YELLOW, "  C:    "
    COLOR LBLUE
    mv a0, s0
    srli a0, a0, 2
    jal print_bin1
    CPRINT WHITE, "  (C Extension)"
    NL

    #-- Imprimir bit B
    CPRINT YELLOW, "  B:    "
    COLOR LBLUE
    mv a0, s0
    srli a0, a0, 1
    jal print_bin1
    CPRINT WHITE, "  (B Extension)"
    NL

    #-- Imprimir bit A
    CPRINT YELLOW, "  A:    "
    COLOR LBLUE
    mv a0, s0
    jal print_bin1
    CPRINT WHITE, "  (A Extension)"
    NL



loop: 

    #-- Esperar
    DELAY_MS 200

    #-- Cambiar de estado el LED
    jal led_toggle

    j loop
    
