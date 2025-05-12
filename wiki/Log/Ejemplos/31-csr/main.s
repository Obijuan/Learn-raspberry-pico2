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

    CLS
    CPRINT LYELLOW, "MSTATUS: "

    #-- Leer el registro MSTATUS
    COLOR BLUE
    csrrw a0, mstatus, zero
    mv s0, a0
    jal print_0x_hex32
    NL 

    #-- Imprimir bit TW
    CPRINT YELLOW, "  TW:   "
    COLOR LBLUE
    mv a0, s0
    srli a0, a0, 21
    jal print_bin1
    CPRINT WHITE, "  (Timeout Wait)"
    NL

    #-- Imprimir bit MPRV
    CPRINT YELLOW, "  MPRV: "
    COLOR BLUE
    mv a0, s0
    srli a0, a0, 17
    jal print_bin1
    CPRINT WHITE, "  (Modify PRiVilegde)"
    NL
    
    #-- Imprimir campo MPP
    CPRINT YELLOW, "  MPP:  "
    COLOR BLUE
    mv a0, s0
    srli a0, a0, 11
    jal print_bin2
    CPRINT WHITE, " (Previous Privilegde level)"
    NL 

    #-- Imprimir bit MPIE
    CPRINT YELLOW, "  MPIE: "
    COLOR BLUE
    mv a0, s0
    srli a0, a0, 7
    jal print_bin1
    CPRINT WHITE, "  (Previous Interrupt Enable)"
    NL

    #-- Imprimir bit MIE
    CPRINT YELLOW, "  MIE:  "
    COLOR BLUE
    mv a0, s0
    srli a0, a0, 3
    jal print_bin1
    CPRINT WHITE, "  (Interrupt enable)"
    NL


loop: 

    #-- Esperar
    DELAY_MS 200

    #-- Cambiar de estado el LED
    jal led_toggle

    j loop
    
