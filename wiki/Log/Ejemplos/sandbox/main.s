#---------------------------
#-- Funciones de interfaz
#---------------------------
.global _start   #-- Punto de entrada

.include "riscv.h"
.include "led.h"
.include "uart.h"
.include "ansi.h"
.include "kernel.h"


# -- VARIABLES NO INICIALIZADAS
.section .bss

ctx1:   #-- Contexto de la tarea 1
        .word 0   #-- PC (offset 0)
        .word 0   #-- ra (offset 4)
        .word 0   #-- sp (offset 8)
        .word 0   #-- gp (offset 0xC)
        .word 0   #-- tp
        .word 0   #-- t0
        .word 0   #-- t1
        .word 0   #-- t2
        .word 0   #-- s0
        .word 0   #-- s1
        .word 0   #-- a0
        .word 0   #-- a1
        .word 0   #-- a2
        .word 0   #-- a3
        .word 0   #-- a4
        .word 0   #-- a5
        .word 0   #-- a6
        .word 0   #-- a7
        .word 0   #-- s2
        .word 0   #-- s3
        .word 0   #-- s4
        .word 0   #-- s5
        .word 0   #-- s6
        .word 0   #-- s7
        .word 0   #-- s8
        .word 0   #-- s9
        .word 0   #-- s10
        .word 0   #-- s11
        .word 0   #-- t3
        .word 0   #-- t4
        .word 0   #-- t5
        .word 0   #-- t6


.section .text

# -- Punto de entrada
_start:

    #-- Acciones de arranque
    la sp, __stack_top
    jal runtime_init

    #-- Cambiar el vector de interrupción
    la t0, isr_kernel
    csrw mtvec, t0

main:
    #-- Configurar perifericos
    jal led_init
    LED_INIT(2)
    LED_INIT(3)
    jal uart_init

    #-- Estados iniciales de los LEDs
    jal led_off
    LED_OFF(2)
    LED_OFF(3)

    CLS

    #-- Configurar la pila de la tarea 1
    li t0, 0x1000
    sub sp, sp, t0
    mv a0, sp

    #-- Saltar a ejecutar la tarea 1
    j task1


# -----------------------
# -- Tarea 1
# -----------------------
task1:

    #-- Encender LED de tarea
    LED_ON(2)

    #-- Dar valores a los registros
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
    
    #-- Test: Llamar al S.O
valor_pc:
    ecall

    nop

    LED_ON(3)
    PRINT "--> CONTEXTO TAREA 1\n"

    #-- Imprimir contexto de la tarea 1
    la a0, ctx1
    jal print_context

    HALT



# ----------------------------------
# -- Kernel de multiplexion
# ----------------------------------
isr_kernel:

    #-- Guardar la pila de la tarea actual
    csrw mscratch, sp

    #-- Obtener la pila del sistema
    la sp, __stack_top

    #-- Guardar registros usados en la pila del SO
    addi sp, sp, -16
    sw t0, 8(sp)
    sw t1, 4(sp)

    #---------- Guardar el contexto de la tarea actual
    #-- Puntero al contexto 1
    la t0, ctx1

    #-- Guardar el PC
    csrr t1, mepc
    sw t1, PC(t0)

    #-- Guardar la pila
    csrr t1, mscratch
    sw t1, SP(t0)

    #-- Guardar resto de registros
    sw ra, RA(t0)
    sw gp, GP(t0)
    sw tp, TP(t0)

    #-- Ahora que gp está guardado, lo usamos
    #-- como puntero de contexto en vez t0
    mv gp, t0

    #-- Guardar t0 y t1. Recuperar su valor inicial
    #-- y guardarlo en el contexto
    lw t0, 8(sp)
    lw t1, 4(sp)

    #-- Guardar t0 y t1
    sw t0, T0(gp)
    sw t1, T1(gp)

    #-- Guardar resto de registros
    sw t2, T2(gp)
    sw s0, S0(gp)
    sw s1, S1(gp)
    sw a0, A0(gp)
    sw a1, A1(gp)
    sw a2, A2(gp)
    sw a3, A3(gp)
    sw a4, A4(gp)
    sw a5, A5(gp)
    sw a6, A6(gp)
    sw a7, A7(gp)
    sw s2, S2(gp)
    sw s3, S3(gp)
    sw s4, S4(gp)
    sw s5, S5(gp)
    sw s6, S6(gp)
    sw s7, S7(gp)
    sw s8, S8(gp)
    sw s9, S9(gp)
    sw s10, S10(gp)
    sw s11, S11(gp)
    sw t3, T3(gp)
    sw t4, T4(gp)
    sw t5, T5(gp)
    sw t6, T6(gp)

    jal led_on

    #----------- Terminar
    #-- Incrementar mepc en 4 para apuntar a la siguiente instrucción
    #-- (porque esto es un ecall)
    csrr t0, mepc
    addi t0, t0, 4
    csrw mepc, t0

    #------------ Reponer el contexto de la tarea
    la t0, ctx1

    #-- Reponer la pila
    lw sp, SP(t0)

    mret
