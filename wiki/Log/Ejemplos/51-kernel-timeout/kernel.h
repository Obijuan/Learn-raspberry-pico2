#-- Offsets para acceder al contexto de las tareas
.equ PC, 0x0
.equ RA, 0x4
.equ SP, 0x8
.equ GP, 0xc
.equ TP, 0x10
.equ T0, 0x14
.equ T1, 0x18
.equ T2, 0x1c
.equ S0, 0x20
.equ S1, 0x24
.equ A0, 0x28
.equ A1, 0x2c
.equ A2, 0x30
.equ A3, 0x34
.equ A4, 0x38
.equ A5, 0x3c
.equ A6, 0x40
.equ A7, 0x44
.equ S2, 0x48
.equ S3, 0x4c
.equ S4, 0x50
.equ S5, 0x54
.equ S6, 0x58
.equ S7, 0x5c
.equ S8, 0x60
.equ S9, 0x64
.equ S10,0x68
.equ S11,0x6c
.equ T3, 0x70
.equ T4, 0x74
.equ T5, 0x78
.equ T6, 0x7c


#--- Tiempo (en ciclos) para realizar el cambio de tareas
.equ TIMEOUT, 0x00400000

#---------------------------------------------
#-- Macro de prueba: 
#-- Asignar un valor a TODOS los registros
#---------------------------------------------
.macro SET_REGISTERS
    li ra, 1
    li gp, 3
    li tp, 4
    li t0, 5
    li t1, 6
    li t2, 7
    li s0, 8
    li s1, 9
    li a0, 10
    li a1, 11
    li a2, 12
    li a3, 13
    li a4, 14
    li a5, 15
    li a6, 16
    li a7, 17
    li s2, 18
    li s3, 19
    li s4, 20
    li s5, 21
    li s6, 22
    li s7, 23
    li s8, 24
    li s9, 25
    li s10, 26
    li s11, 27
    li t3, 28
    li t4, 29
    li t5, 30
    li t6, 31
.endm
