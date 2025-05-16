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

    #-- Establecer permisos para el GPIO25
    li t0, ACCESSCTRL_GPIO_NSMASK0
    li t1, BIT25
    sw t1, 0(t0) 

    #-- Permisos para UART0
    li t0, ACCESSCTRL_UART0
    li t1, 0x3
    #sw t1, 0(t0)


    #-- Configurar los permisos de acceso a la flash
    li t0, 0x5FFFFFFF
    csrw pmpaddr0, t0

    li t1, 0x1F
    csrw pmpcfg0, t1

    #------- PASAR A MODO USUARIO

    #-- Poner a 0 bits del campo MPP
    #-- Para que el modo de privilegio sea de usuario
    csrw mstatus, zero

    #-- Meter en mepc la direccion de retorno
    la t0, user_mode_entry
    csrw mepc, t0

    #-- Saltar a modo usuario
    mret 


# Código en modo usuario
user_mode_entry:

    jal led_on

    #PUTCHAR 'A'
    #csrw mtvec, zero
    j .

#------------------------------------------
#-- Rutina de atencion a la interrupcion 
#------------------------------------------
isr:
    jal print_mstatus
    jal print_mcause

    jal led_blinky3
    