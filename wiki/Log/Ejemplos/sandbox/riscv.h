#-----------------------------------------------
#-- Macros de creación de funciones intermedias
#-----------------------------------------------

#-- Crear la pila con espacio para 4 palabras
#-- en los offsets 12, 8, 4 y 0
.macro FUNC_START4
    addi sp, sp, 16
    sw ra, 12(sp)
.endm

#-- Eliminar la pila de 4 palabras
#-- y retornar
.macro FUNC_END4
    lw ra, 12(sp)
    addi sp, sp, -16
    ret
.endm

#---------------------
#-- REGISTROS CSR
#---------------------

#--- MCAUSE
.equ INST_FAULT,      0x1
.equ ILEGAL_INST,     0x2
.equ BREAKPOINT,      0x3
.equ NOT_ALIGN_LOAD,  0x4
.equ LOAD_FAULT,      0x5
.equ NOT_ALIGN_STORE, 0x6
.equ STORE_FAULT,     0x7
.equ ECALL_U,         0x8
.equ ECALL_M,         0xB

#--- MSTATUS
.equ MIE,  0x1 << 3
.equ MPP,  0x3 << 11   #-- Previous Privilege Mode
.equ MPRV, 0x1 << 17
.equ MODO_USER, 0x0
.equ MODO_MACHINE, 0x3
