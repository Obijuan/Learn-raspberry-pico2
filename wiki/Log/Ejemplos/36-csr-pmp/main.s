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

    #---- Mostrar registro PMPCFG0
    PRINT "PMPCFG0:  "
    csrr a0, pmpcfg0
    jal print_0x_hex32
    NL

    #---- Mostrar registro PMPCFG1
    PRINT "PMPCFG1:  "
    csrr a0, pmpcfg1
    jal print_0x_hex32
    NL

    #---- Mostrar registro PMPCFG2
    PRINT "PMPCFG2:  "
    csrr a0, pmpcfg2
    jal print_0x_hex32
    NL

    #---- Mostrar registro PMPCFG3
    PRINT "PMPCFG3:  "
    csrr a0, pmpcfg3
    jal print_0x_hex32
    NL

    #---- Mostrar registro PMPADDR8
    PRINT "PMPADDR8:  "
    csrr a0, pmpaddr8
    jal print_0x_hex32
    NL

    #---- Mostrar registro PMPADDR9
    PRINT "PMPADDR9:  "
    csrr a0, pmpaddr9
    jal print_0x_hex32
    NL

    #---- Mostrar registro PMPADDR10
    PRINT "PMPADDR10: "
    csrr a0, pmpaddr10
    jal print_0x_hex32
    NL

    #---- Mostrar registro PMPADDR11
    PRINT "PMPADDR11: "
    csrr a0, pmpaddr11
    jal print_0x_hex32
    NL

    #-- Fin
    j .


#------------------------------------------
#-- Rutina de atencion a la interrupcion 
#------------------------------------------
#-- En caso de excepcion el LED parpadea rapidamente
isr:
    jal led_blinky3
    