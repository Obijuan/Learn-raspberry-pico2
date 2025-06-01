#---------------------------
#-- Funciones de interfaz
#---------------------------
.global _start   #-- Punto de entrada
.global task1
.global task2

.include "regs.h"
.include "riscv.h"
.include "led.h"
.include "uart.h"
.include "ansi.h"
.include "kernel.h"

#-- Pausa en ms
.equ PAUSA, 500


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

    jal kernel_init

    #--- Obtener el puntero al contexto actual
    #--- s0: Puntero al contexto actual
    la t0, ctx
    lw t0, 0(t0)
    lw s0, 0(t0)

    #-- Saltar a ejecutar la tarea actual
    lw sp, SP(s0)
    lw t0, PC(s0)
    jalr t0


# -----------------------
# -- Tarea 1
# -----------------------
task1:
    #-- Inicializar el puntero de pila de la tarea 1
    #la t0, stack1
    #lw sp, 0(t0)

    PRINT "--> TAREA 1: INIT\n"

tarea1_loop:

    #-- Encender LED de tarea
    LED_TOGGLE(2)

    li a0, PAUSA
    jal delay_ms

    j tarea1_loop


#--------------------------------
#-- Tarea 2
#--------------------------------
task2:
    #-- Inicializar el puntero de pila de la tarea 2
    la t0, stack2
    lw sp, 0(t0)

    PRINT "--> TAREA 2: INIT\n"


tarea2_loop:
    PRINT "--> TAREA 2\n"

    #-- Cambiar de estado el LED
    LED_TOGGLE(3)

    #-- Esperar a que se apriete una tecla
    jal getchar

    #-- Repetir
    j tarea2_loop

