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

    CLS

    #-- Configurar los permisos
    li t0, 0x5FFFFFFF
    csrw pmpaddr0, t0

    li t1, 0x1F
    csrw pmpcfg0, t1

    #---- Mostrar registro PMPCFG0
    PRINT "PMPCFG0:   "
    csrr a0, pmpcfg0
    jal print_0x_hex32
    NL

    #---- Mostrar registro PMPADDR8
    PRINT "PMPADDR0:  "
    csrr a0, pmpaddr0
    jal print_0x_hex32
    NL

    #-- Poner a 0 memoria por si acaso
    li t0, 0x20000000
    sw zero, 0(t0)
    sw zero, 4(t0)

    #-- Volcado de memoria de la direccion 0x2000_0000
    li a0, 0x20000000
    li a1, 1
    jal dump16

    #-- Poner a 0 bits del campo MPP
    #-- Para que el modo de privilegio sea de usuario
    #li t0, MPRV
    csrw mstatus, zero

    #-- Meter en mepc la direccion de retorno
    la t0, user_mode_entry
    csrw mepc, t0

    #-- Saltar a modo usuario
    mret 


# Código en modo usuario
user_mode_entry:

    #-- Escribir valores en la RAM
    li t0, 0x20000000
    li t1, 0xCAFEBACA
    li t2, 0xABCDEF01
    sw t1, 0(t0)
    sw t2, 4(t0)

    csrw mtvec, zero
    j .

#------------------------------------------
#-- Rutina de atencion a la interrupcion 
#------------------------------------------
isr:
    jal print_mstatus
    jal print_mcause

     #-- Volcado de memoria
    li a0, 0x20000000
    li a1, 1
    jal dump16

    jal led_blinky3
    