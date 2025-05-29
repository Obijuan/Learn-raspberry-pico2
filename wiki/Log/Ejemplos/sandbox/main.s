#---------------------------
#-- Funciones de interfaz
#---------------------------
.global _start   #-- Punto de entrada

.include "riscv.h"
.include "led.h"
.include "uart.h"
.include "ansi.h"

.section .text

# -- Punto de entrada
_start:

    #-- Acciones de arranque
    la sp, __stack_top
    jal runtime_init

    #-- Cambiar el vector de interrupción
    la t0, isr_kernel
    csrw mtvec, t0

main:
    #-- Configurar perifericos
    jal led_init
    LED_INIT(2)
    LED_INIT(3)
    jal uart_init

    #-- Estados iniciales de los LEDs
    jal led_off
    LED_OFF(2)
    LED_OFF(3)

    CLS

    #-- Configurar la pila de la tarea 1
    li t0, 0x1000
    sub sp, sp, t0
    mv a0, sp

    #-- Saltar a ejecutar la tarea 1
    j task1


# -----------------------
# -- Tarea 1
# -----------------------
task1:

    #-- Obtener la pila del sistema
    la sp, __stack_top

    #-- Encender LED de tarea
    LED_ON(2)

    #-- Dar valores a los registros
    li ra, 1
    

    #-- Test: Llamar al S.O
valor_pc:
    ecall

    LED_ON(3)

    HALT

# ----------------------------------
# -- Kernel de multiplexion
# ----------------------------------
isr_kernel:
    jal led_on

    #-- Incrementar mepc en 4 para apuntar a la siguiente instrucción
    #-- (porque esto es un ecall)
    csrr t0, mepc
    addi t0, t0, 4
    csrw mepc, t0

    mret
