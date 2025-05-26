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
    jal led_off
    jal uart_init

    #-------- Configurar los permisos para el modo usuario -----------
    #-- ACCESO A LA MEMORIA FLASH desde modo usuario
    li t0, 0x5FFFFFFF
    csrw pmpaddr0, t0

    li t1, 0x1F
    csrw pmpcfg0, t1

    #--- ACCESO A LOS GPIOS desde modo usuario
    li t0, ACCESSCTRL_GPIO_NSMASK0
    li t1, BIT25
    sw t1, 0(t0) 

    #--- ACCESO A LA UART desde modo usuario
    li t0, ACCESSCTRL_UART0
    li t1, 0xacce00ff
    sw t1, 0(t0)

    j monitorv_trap

