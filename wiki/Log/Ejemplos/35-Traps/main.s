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
    la t0, isr
    csrw mtvec, t0

main:
    #-- Configurar perifericos
    jal led_init
    jal uart_init

menu:
    CLS
    PRINT "Test de interrupciones\n"
    PRINT "1.- Ecall\n"
    PRINT "2.- Instruccion ilegal\n"
    PRINT "3.- BREAKPOINT\n"

prompt:
    PRINT "> "
    jal getchar

    #-- Salvar la tecla
    mv s0, a0

    #-- Eco de al tecla
    jal putchar
    PUTCHAR '\n'

    #-- Recuperar tecla
    mv a0, s0

    li t0, ' ' 
    beq a0, t0, menu

    li t0, '1'
    beq a0, t0, opcion1

    li t0, '2'
    beq a0, t0, opcion2

    li t0, '3'
    beq a0, t0, opcion3

    j prompt

opcion1:
    ecall
    j prompt

opcion2:
    .word 0  #-- Instruccion ilegal
    j prompt

opcion3:
    ebreak
    j prompt

#-- HALT!
halt:    j .

#------------------------------------------
#-- Rutina de atencion a la interrupcion 
#------------------------------------------
isr:
    PRINT "----> Interrupción!\n"
    #--- Lo primero que hacemos es averiguar la causa de la 
    #--- interrupción
    #--- eso se encuentra en el registro mcause
    jal print_mcause

    #-- Leer causa
    csrr a0, mcause

    #-- Comprobar si la causa es por una excepcion
    #-- o por una interrupcion
    #-- Esto se hace comprobando el bit INT (el de mayor peso)
    bge a0, zero, es_excepcion

    #-- Es una interrupcion
    PRINT "TIPO: Interrupcion\n"
    PRINT "Desconocida...\n"
    jal led_blinky3

es_excepcion:
    PRINT "TIPO: Excepcion\n"

    #-- Comprobar qué tipo de excepcion es
    csrr t0, mcause

    #-- Aislar la causa
    andi t0, t0, 0xF
    
    li t1, ECALL
    beq t0, t1, es_ecall

    li t1, ILEGAL_INST
    beq t0, t1, excep_ilegal_inst

    li t1, BREAKPOINT
    beq t0, t1, es_ebreak

    #-- Causa desconocida
    PRINT "Desconocida\n"
    jal led_blinky3

#---- La excepcion es debida a ecall
es_ecall:

    PRINT "ECALL\n\n"
    j isr_end

es_ebreak:
    PRINT "EBREAK\n\n"
    j isr_end

#--- La excepcion es por instruccion ilegal
excep_ilegal_inst:
    PRINT "INSTRUCCION ILEGAL\n\n"
    j isr_end


isr_end:
    #-- TERMINAR---------------------------
    #--- Leer la direccion de retorno
    csrr t0, mepc

    #-- Incrementar la direccion en 4 para retornar a la
    #-- siguiente instruccion a ecall
    addi t0, t0, 4
    csrw mepc, t0

    #-- Retornar
    mret
