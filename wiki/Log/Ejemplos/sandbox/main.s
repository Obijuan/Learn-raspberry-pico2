#---------------------------
#-- Funciones de interfaz
#---------------------------
.global _start   #-- Punto de entrada

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

    #-- Inicializar el kernel 
    #-- Establecer las tareas 
    #-- y saltar a ejecutar la primera tarea
    la a0, task1
    la a1, task2
    jal kernel_init


# -----------------------
# -- Tarea 1
# -----------------------
task1:
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
    PRINT "--> TAREA 2: INIT\n"

tarea2_loop:
    PRINT "--> TAREA 2\n"

    #-- Cambiar de estado el LED
    LED_TOGGLE(3)

    #-- Esperar a que se apriete una tecla
    jal getchar

    #-- Repetir
    j tarea2_loop

