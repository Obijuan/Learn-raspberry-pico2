#---------------------------
#-- Funciones de interfaz
#---------------------------
.global _start   #-- Punto de entrada

.include "riscv.h"
.include "regs.h"
.include "delay.h"
.include "uart.h"
.include "ansi.h"

.macro PRINT_MSCRATCH
    csrrs a0, mscratch, zero
    jal print_0x_hex32
    NL
.endm

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

    CLS

    #---------- Instrucciones CSR con valores inmediatos

    #-- Escribir un valor inmediato en el 
    #-- registro scratch (registro temporal)
    #-- Solo se pueden escribir valores inmediatos
    #-- de 5 bits
    csrrwi zero, mscratch, 0x1F

    #-- Leer el registro scratch y mostrarlo
    #-- Se usa READ-SET, pero como el registro fuente
    #-- es zero, no se modifica scratch
    csrrs a0, mscratch, zero
    jal print_0x_hex32
    NL

    #-- Borrar el bit 0
    csrrci zero, mscratch, 1
    PRINT_MSCRATCH

    #-- Borrar bits 1 y 2
    csrrci zero, mscratch, BIT1 | BIT2
    PRINT_MSCRATCH

    #-- Activar bits 0, 1 y 2
    csrrsi zero, mscratch, BIT0 | BIT1 | BIT2
    PRINT_MSCRATCH

    #---------- Instrucciones CSR con registro fuente

    #-- Escribir el valor 0xFFFFFFFF
    li t0, -1
    csrrw zero, mscratch, t0
    PRINT_MSCRATCH

    #-- Borrar bits
    li t0, BIT31 | BIT30 | BIT29 | BIT28 | BIT3 | BIT2 | BIT1 | BIT0
    csrrc zero, mscratch, t0
    PRINT_MSCRATCH

    #-- Activar bits
    li t0, BIT31 | BIT30
    csrrs zero, mscratch, t0
    PRINT_MSCRATCH

    #-------------- PseudoInstrucciones
    #---- WRITE IMM
    csrwi mscratch, 0x5

    #---- READ
    csrr a0, mscratch
    jal print_0x_hex32
    NL

    #--- WRITE
    li t0, 0xCAFEBACA
    csrw mscratch, t0 
    PRINT_MSCRATCH

    #-- SET IMM
    csrsi mscratch, 0x5
    PRINT_MSCRATCH

    #-- SET
    li t0, 0x30000000
    csrs mscratch, t0
    PRINT_MSCRATCH

    #-- CLEAR IMM
    csrci mscratch, 0x5
    PRINT_MSCRATCH

    #-- CLEAR
    li t0, 0x30000000
    csrc mscratch, t0
    PRINT_MSCRATCH


#-- HALT!
halt:    j .
