#---------------------------
#-- Funciones de interfaz
#---------------------------
.global _start   #-- Punto de entrada

.include "riscv.h"
.include "led.h"

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

    #-- Saltar a ejecutar la tarea 1
    j task1

    HALT

# -----------------------
# -- Tarea 1
# -----------------------
task1:

    #-- Encender LED de tarea
    LED_ON(2)

    #-- Test: Llamar al S.O
    ecall

    HALT

# ----------------------------------
# -- Kernel de multiplexion
# ----------------------------------
isr_kernel:
    jal led_on
    mret
