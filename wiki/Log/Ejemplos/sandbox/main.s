#---------------------------
#-- Funciones de interfaz
#---------------------------
.global _start   #-- Punto de entrada

.include "riscv.h"
.include "regs.h"
.include "delay.h"
.include "led.h"
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
    LED_INIT(2)
    LED_INIT(3)
    jal uart_init


    nop
    nop
    CLS

    #-- Estados iniciales de los LEDs
    LED_ON(2)
    LED_OFF(3)


loop:
    LED_TOGGLE(2)
    LED_TOGGLE(3)

    DELAY_MS(500)

    j loop

    ecall
    HALT

isr_panic:
    jal led_blinky3
