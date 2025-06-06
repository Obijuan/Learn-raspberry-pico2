#------------------------------
#-- FUNCIONES DE INTERFAZ
#------------------------------
.global ctx_init
.global print_context

.include "riscv.h"
.include "kernel.h"
.include "uart.h"

.section .text

#-----------------------------------------
#-- Imprimir el contexto de una tarea
#-----------------------------------------
#-- ENTRDAS:
#--   a0: Puntero al contexto
#-----------------------------------------
print_context:
    FUNC_START4
    sw s0, 8(sp)

    #-- S0: Puntero al contexto
    mv s0, a0

    PRINT "* PC: "
    lw a0, PC(s0) 
    jal print_0x_hex32
    NL

    PRINT "* SP: "
    lw a0, SP(s0)
    jal print_0x_hex32
    NL

    PRINT "* Ra: "
    lw a0, RA(s0)
    jal print_0x_hex32
    NL

    PRINT "* gp: "
    lw a0, GP(s0)
    jal print_0x_hex32
    NL

    PRINT "* tp: "
    lw a0, TP(s0)
    jal print_0x_hex32
    NL

    PRINT "* t0: "
    lw a0, T0(s0)
    jal print_0x_hex32
    NL

    PRINT "* t1: "
    lw a0, T1(s0)
    jal print_0x_hex32
    NL

    PRINT "* t2: "
    lw a0, T2(s0)
    jal print_0x_hex32
    NL

    PRINT "* s0: "
    lw a0, S0(s0)
    jal print_0x_hex32
    NL

    PRINT "* s1: "
    lw a0, S1(s0)
    jal print_0x_hex32
    NL

    PRINT "* a0: "
    lw a0, A0(s0)
    jal print_0x_hex32
    NL

    PRINT "* a1: "
    lw a0, A1(s0)
    jal print_0x_hex32
    NL

    PRINT "* a2: "
    lw a0, A2(s0)
    jal print_0x_hex32
    NL

    PRINT "* a3: "
    lw a0, A3(s0)
    jal print_0x_hex32
    NL

    PRINT "* a4: "
    lw a0, A4(s0)
    jal print_0x_hex32
    NL

    PRINT "* a5: "
    lw a0, A5(s0)
    jal print_0x_hex32
    NL

    PRINT "* a6: "
    lw a0, A6(s0)
    jal print_0x_hex32
    NL

    PRINT "* a7: "
    lw a0, A7(s0)
    jal print_0x_hex32
    NL

    PRINT "* s2: "
    lw a0, S2(s0)
    jal print_0x_hex32
    NL

    PRINT "* s3: "
    lw a0, S3(s0)
    jal print_0x_hex32
    NL

    PRINT "* s4: "
    lw a0, S4(s0)
    jal print_0x_hex32
    NL

    PRINT "* s5: "
    lw a0, S5(s0)
    jal print_0x_hex32
    NL

    PRINT "* s6: "
    lw a0, S6(s0)
    jal print_0x_hex32
    NL

    PRINT "* s7: "
    lw a0, S7(s0)
    jal print_0x_hex32
    NL

    PRINT "* s8: "
    lw a0, S8(s0)
    jal print_0x_hex32
    NL

    PRINT "* s9: "
    lw a0, S9(s0)
    jal print_0x_hex32
    NL

    PRINT "* s10: "
    lw a0, S10(s0)
    jal print_0x_hex32
    NL

    PRINT "* s11: "
    lw a0, S11(s0)
    jal print_0x_hex32
    NL

    PRINT "* t3: "
    lw a0, T3(s0)
    jal print_0x_hex32
    NL

    PRINT "* t4: "
    lw a0, T4(s0)
    jal print_0x_hex32
    NL

    PRINT "* t5: "
    lw a0, T5(s0)
    jal print_0x_hex32
    NL

    PRINT "* t6: "
    lw a0, T6(s0)
    jal print_0x_hex32
    NL

    lw s0, 8(sp)
    FUNC_END4


#----------------------------------------------
#-- Inicializar el contexto
#-- Se configuran los registros SP y PC
#-- El resto de registros se dejan a 0
#----------------------------------------------
# ENTRADAS:
#   -a0: Direccion base del contexto
#   -a1: Valor del PC
#   -a2: Direccion (variable) del sp
#-----------------------------------------------
ctx_init:

#-- t0: Apunta al primer registro
mv t0, a0

#-- Poner todos los registros a 0
li t1, 32  #-- Cantidad de registro del contexto
loop_reset:
    sw zero, 0(t0)  #-- Inicializar registro actual
    addi t1,t1,-1   #-- Un registro menos por inicializar
    beq t1, zero, end_zero  #-- Si ya no quedan mas, hemos terminado
    addi t0, t0, 4  #-- Apuntar al siguiente registro
    j loop_reset

end_zero:

    #-- Guardar el PC
    sw a1, 0(a0)

    #-- Guardar la pila
    lw t0, 0(a2)  #-- Lee el sp
    sw t0, SP(a0) #-- Guardarlo en el contexto

    ret
