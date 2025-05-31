#----------------------------
#-- FUNCIONES DE INTERFAZ
#----------------------------
.global print_mstatus
.global print_misa
.global print_mie
.global print_mtvec
.global print_mip
.global print_mcause

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
    csrrs a0, mstatus, zero
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
    csrrs a0, misa, zero
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

# ---------------------------------------------------
# - print_mie
# - Imprimir el registro MIE y todos sus bits  
# - (Interrupt Enable)
# ---------------------------------------------------
print_mie:
FUNC_START4

    CPRINT LYELLOW, "MIE: "

    #-- Leer el registro MIE
    COLOR BLUE
    csrrs a0, mie, zero
    mv s0, a0
    jal print_0x_hex32
    CPRINT WHITE, "  (Interrupt Enable)\n"

    #-- Imprimir bit MEIE
    CPRINT YELLOW, "  MEIE:  "
    COLOR LBLUE
    mv a0, s0
    srli a0, a0, 11
    jal print_bin1
    CPRINT WHITE, " (External interrupt enable)"
    NL

    #-- Imprimir bit MTIE
    CPRINT YELLOW, "  MTIE:  "
    COLOR LBLUE
    mv a0, s0
    srli a0, a0, 7
    jal print_bin1
    CPRINT WHITE, " (Timer interrupt enable)"
    NL

    #-- Imprimir bit MSIE
    CPRINT YELLOW, "  MSIE:  "
    COLOR LBLUE
    mv a0, s0
    srli a0, a0, 3
    jal print_bin1
    CPRINT WHITE, " (Software interrupt enable)"
    NL

FUNC_END4


# ---------------------------------------------------
# - print_mtvec
# - Imprimir el registro MTVEC y todos sus bits  
# - (Trap handler base address)
# ---------------------------------------------------
print_mtvec:
FUNC_START4

    CPRINT LYELLOW, "MTVEC: "

    #-- Leer el registro MTVEC
    COLOR LBLUE
    csrrs a0, mtvec, zero
    mv s0, a0
    jal print_0x_hex32
    CPRINT WHITE, "  (Trap handler base address)\n"

    #-- Poner a 0 los dos ultimos bits
    mv a0, s0
    li t1, 0xFFFFFFFC
    and a0, a0, t1
    mv s1, a0

    #-- Imprimir campo BASE
    CPRINT YELLOW, "  BASE:  "
    COLOR BLUE
    mv a0, s1
    jal print_0x_hex32
    CPRINT WHITE, " (Trap vector address)"  
    NL

    #-- Imprimir campo MODE
    CPRINT YELLOW, "  MODE:  "
    COLOR BLUE
    mv a0, s0
    jal print_bin2
    CPRINT WHITE, " (Trap mode)"
    NL 

FUNC_END4

# ---------------------------------------------------
# - print_mip
# - Imprimir el registro MIP y todos sus bits  
# - (Interrupt Pending)
# ---------------------------------------------------
print_mip:
FUNC_START4

    CPRINT LYELLOW, "MEIP: "

    #-- Leer el registro MIP
    COLOR BLUE
    csrrs a0, mip, zero
    mv s0, a0
    jal print_0x_hex32
    CPRINT WHITE, "  (External interrupt pending)\n"

    #-- Imprimir bit MEIE
    CPRINT YELLOW, "  MEIE:  "
    COLOR LBLUE
    mv a0, s0
    srli a0, a0, 11
    jal print_bin1
    CPRINT WHITE, " (External interrupt enable)"
    NL

    #-- Imprimir bit MTIE
    CPRINT YELLOW, "  MTIP:  "
    COLOR LBLUE
    mv a0, s0
    srli a0, a0, 7
    jal print_bin1
    CPRINT WHITE, " (Timer interrupt pending)"
    NL

    #-- Imprimir bit MSIE
    CPRINT YELLOW, "  MSIP:  "
    COLOR LBLUE
    mv a0, s0
    srli a0, a0, 3
    jal print_bin1
    CPRINT WHITE, " (Software interrupt pending)"
    NL

FUNC_END4


# ---------------------------------------------------
# - print_mcause
# - Imprimir el registro MCAUSE y todos sus bits  
# ---------------------------------------------------
print_mcause:
FUNC_START4
    CPRINT LYELLOW, "MCAUSE: "

    #-- Leer el registro MCAUSE
    COLOR BLUE
    csrrs a0, mcause, zero
    mv s0, a0
    jal print_0x_hex32
    NL 

    #-- Imprimir bit INTERRUPT
    CPRINT YELLOW, "  INTERRUPT: "
    COLOR LBLUE
    mv a0, s0
    srli a0, a0, 31
    jal print_bin1
    CPRINT WHITE, "  (Exception(0)/Interrupt(1))"
    NL

    #-- Imprimir campo CODE
    CPRINT YELLOW, "  CODE:      "
    COLOR LBLUE
    mv a0, s0
    jal print_hex4
    CPRINT WHITE, "  (Cause of the trap)"
    NL

FUNC_END4
