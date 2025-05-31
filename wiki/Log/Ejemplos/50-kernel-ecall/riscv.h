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

#-------- BUCLE INFINITO
.macro HALT
    j .
.endm

#---------------------
#-- REGISTROS CSR
#---------------------

#-------------------- MCAUSE

#-- Codigos de excepcion
.equ INST_FAULT,      0x1
.equ ILEGAL_INST,     0x2
.equ BREAKPOINT,      0x3
.equ NOT_ALIGN_LOAD,  0x4
.equ LOAD_FAULT,      0x5
.equ NOT_ALIGN_STORE, 0x6
.equ STORE_FAULT,     0x7
.equ ECALL_U,         0x8
.equ ECALL_M,         0xB

#-- Codigos de interrupcion
.equ INT_MTIMER,      0x7

#--- MSTATUS
.equ MSTATUS_MIE,  0x1 << 3
.equ MPP,  0x3 << 11   #-- Previous Privilege Mode
.equ MPRV, 0x1 << 17
.equ MODO_USER, 0x0
.equ MODO_MACHINE, 0x3

#--- MIE
.equ MIE_MEIE, 0x1 << 11  #-- Machine External Interrupt Enable
.equ MIE_MTIE, 0x1 << 7   #-- Machine Timer Interrupt Enable
.equ MIE_MSIE, 0x1 << 3   #-- Machine Software Interrupt Enable

#--- MIP  : Machine Interrupt Pending
.equ MIP_MEIP, 0x1 << 11  #-- Machine External Interrupt Pending
.equ MIP_MTIP, 0x1 << 7   #-- Machine Timer Interrupt Pending
.equ MIP_MSIP, 0x1 << 3   #-- Machine Software Interrupt Pending


#-----------------------------------------------
#-- Macro para Guardar el contexto actual 
#-----------------------------------------------
.macro SAVE_CONTEXT
    #--- Guardar el contexto
    #-- Todos los registros menos x2 (sp) y x0 (zero)
    addi sp, sp, -128  
    sw x0, 0(sp)    #-- Guardar x0 (No necesario). Hecho asi por simetria... 
    sw x1, 4(sp)    #-- Guardar x1
    sw x3, 12(sp)   #-- Guardar x3
    sw x4, 16(sp)   #-- Guardar x4
    sw x5, 20(sp)   #-- Guardar x5
    sw x6, 24(sp)   #-- Guardar x6
    sw x7, 28(sp)   #-- Guardar x7
    sw x8, 32(sp)   #-- Guardar x8
    sw x9, 36(sp)   #-- Guardar x9
    sw x10, 40(sp)  #-- Guardar x10
    sw x11, 44(sp)  #-- Guardar x11
    sw x12, 48(sp)  #-- Guardar x12
    sw x13, 52(sp)  #-- Guardar x13
    sw x14, 56(sp)  #-- Guardar x14
    sw x15, 60(sp)  #-- Guardar x15
    sw x16, 64(sp)  #-- Guardar x16
    sw x17, 68(sp)  #-- Guardar x17
    sw x18, 72(sp)  #-- Guardar x18
    sw x19, 76(sp)  #-- Guardar x19
    sw x20, 80(sp)  #-- Guardar x20
    sw x21, 84(sp)  #-- Guardar x21
    sw x22, 88(sp)  #-- Guardar x22
    sw x23, 92(sp)  #-- Guardar x23
    sw x24, 96(sp)  #-- Guardar x24
    sw x25, 100(sp) #-- Guardar x25
    sw x26, 104(sp) #-- Guardar x26
    sw x27, 108(sp) #-- Guardar x27
    sw x28, 112(sp) #-- Guardar x28
    sw x29, 116(sp) #-- Guardar x29
    sw x30, 120(sp) #-- Guardar x30
    sw x31, 124(sp) #-- Guardar x31
.endm

#-----------------------------------------------
#-- Macro para Restaurar el contexto actual
#-----------------------------------------------
.macro RESTORE_CONTEXT
    #-- Restaurar el contexto
    lw x1, 4(sp)    #-- Restaurar x1
    lw x3, 12(sp)   #-- Restaurar x3
    lw x4, 16(sp)   #-- Restaurar x4
    lw x5, 20(sp)   #-- Restaurar x5
    lw x6, 24(sp)   #-- Restaurar x6
    lw x7, 28(sp)   #-- Restaurar x7 
    lw x8, 32(sp)   #-- Restaurar x8
    lw x9, 36(sp)   #-- Restaurar x9
    lw x10, 40(sp)  #-- Restaurar x10
    lw x11, 44(sp)  #-- Restaurar x11
    lw x12, 48(sp)  #-- Restaurar x12
    lw x13, 52(sp)  #-- Restaurar x13
    lw x14, 56(sp)  #-- Restaurar x14
    lw x15, 60(sp)  #-- Restaurar x15
    lw x16, 64(sp)  #-- Restaurar x16
    lw x17, 68(sp)  #-- Restaurar x17
    lw x18, 72(sp)  #-- Restaurar x18
    lw x19, 76(sp)  #-- Restaurar x19
    lw x20, 80(sp)  #-- Restaurar x20
    lw x21, 84(sp)  #-- Restaurar x21
    lw x22, 88(sp)  #-- Restaurar x22
    lw x23, 92(sp)  #-- Restaurar x23
    lw x24, 96(sp)  #-- Restaurar x24
    lw x25, 100(sp) #-- Restaurar x25
    lw x26, 104(sp) #-- Restaurar x26
    lw x27, 108(sp) #-- Restaurar x27
    lw x28, 112(sp) #-- Restaurar x28
    lw x29, 116(sp) #-- Restaurar x29
    lw x30, 120(sp) #-- Restaurar x30
    lw x31, 124(sp) #-- Restaurar x31
    addi sp, sp, 128       #-- Eliminar la pila
.endm
