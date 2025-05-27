#---------------------------
#-- Funciones de interfaz
#---------------------------
.global _start   #-- Punto de entrada

.include "riscv.h"
.include "regs.h"
.include "delay.h"
.include "uart.h"
.include "ansi.h"

.section .text

# -- Punto de entrada
_start:

    #-- Acciones de arranque
    la sp, __stack_top
    jal runtime_init

    #-- Establecer el vector de interrupcion
    la t0, isr_monitor
    csrw mtvec, t0

main:
    #-- Configurar perifericos
    jal led_init
    jal uart_init

    #-- Apagar LED
    jal led_off

    #-- Arrancar temporizador
    li t0, MTIME_CTRL
    li t1, 0x3
    sw t1, 0(t0)

    CLS

loop:

    #-- Comenzar medición
    li t0, MTIME
    lw t1, 0(t0)

    #--- Instrucciones a medir
    nop

    #-- Terminar la medición
    lw t2, 0(t0)

    #-- Calcular el número de ciclos
    sub s0, t2, t1
    PRINT "Ciclos: "
    mv a0, s0
    jal print_unsigned_int
    NL

    jal getchar

    j loop 

