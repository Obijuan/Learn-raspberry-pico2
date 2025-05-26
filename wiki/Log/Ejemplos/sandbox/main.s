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
    jal uart_init

    #-- Encender LED
    jal led_on

    CLS

    #--- Activar el temporizador del RISCV
    #--- Que se actualice en cada ciclo
    li t0, MTIME_CTRL
    li t1, 0x3
    sw t1, 0(t0)

loop:

    #-- Leer temporizador del RISCV
    PRINT "Timer L: "
    li t0, MTIME
    lw a0, 0(t0)
    jal print_hex32
    NL

    #-- Esperar (espera activa)
    jal delay

    #-- Repetir 
    j loop



