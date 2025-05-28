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
    la t0, isr_panic
    csrw mtvec, t0

main:
    #-- Configurar perifericos
    jal led_init
    jal uart_init

    #-- Apagar LED
    jal led_off

    CLS

    #-- Configurar LEDs
    li a0, 2
    jal ledn_init

    li a0, 3
    jal ledn_init

    #-- Estados iniciales de los LEDs
    li a0, 2
    jal ledn_on

    li a0, 3
    jal ledn_off

loop:
    li a0, 2
    jal ledn_toggle

    li a0, 3
    jal ledn_toggle

    DELAY_MS(500)

    j loop

    ecall
    HALT

 


isr_panic:
    jal led_blinky3
