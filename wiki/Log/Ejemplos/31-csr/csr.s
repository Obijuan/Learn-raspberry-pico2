#----------------------------
#-- FUNCIONES DE INTERFAZ
#----------------------------
.global print_mstatus
.global print_misa

.include "riscv.h"
.include "uart.h"
.include "ansi.h"

# ---------------------------------------------------
# - print_mstatus
# - Imprimir el registro MSTATUS y todos sus bits  
# ---------------------------------------------------
print_mstatus:
FUNC_START4
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

FUNC_END4


# ---------------------------------------------------
# - print_misa
# - Imprimir el registro MISA y todos sus bits  
# ---------------------------------------------------
print_misa:
FUNC_START4

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
FUNC_END4
