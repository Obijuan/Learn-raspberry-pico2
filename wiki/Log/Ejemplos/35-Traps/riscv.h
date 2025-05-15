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
.equ ECALL, 0xB
.equ ILEGAL_INST, 0x2
