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

    #-- Encender el led
    jal led_on

    CLS

loop:
    CPRINT RED, "HOLA!\n"
    jal getchar
    j loop

#------------------------------------------
#-- Rutina de atencion a la interrupcion 
#------------------------------------------
isr:
    jal led_blinky3
    