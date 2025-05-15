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

main:
    #-- Configurar perifericos
    jal led_init
    jal uart_init

    CLS

    #--------- ESTABLECER VECTOR DE INTERRUPCION
    #------- MTVEC
    #-- Antes
    jal print_mtvec

    la t0, trap_handle
    csrrw zero, mtvec, t0

    #-- Despues
    jal print_mtvec

    #--------- ACTIVAR LAS INTERRUPCIONES
    #------- MIE.SIE=1
    #-- Antes
    jal print_mie

    #-- mie.msie = 1
    li t0, BIT3  #-- 0x08
    csrrw zero, mie, t0

    #-- Despues
    jal print_mie
    NL

    #------- MSTATUS.MIE=1
    #-- Antes
    jal print_mstatus

    li t0, 0x1808
    csrrw zero, mstatus, t0

    #-- Despues
    jal print_mstatus

    #-------- MIP.MSIP=1
    #-- Antes
    jal print_mip

    li t0, BIT3
    csrrw zero, mip, t0

    jal print_mip

    #--- GENERAR INTERRUPCION!!
    li t0, 1
    lw t1, 0(t0)  #-- TRAP! Lectura de una direccion NO alineada
    ecall

loop: 

    #-- Esperar
    DELAY_MS 200

    #-- Cambiar de estado el LED
    jal led_toggle

    j loop
    
trap_handle:
    #-- Encender el LED
    li t0, GPIO_OUT_SET
    li t1, BIT25    #-- Activar el bit 25
    sw t1, 0(t0)
    j .
