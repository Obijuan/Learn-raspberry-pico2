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

    

    #-- Guardar los valores de las pilas
    #-- Configurar la pila de la tarea 1
    la t0, __stack_top
    li t1, 0x1000
    sub t0, t0, t1
    
    #-- Almacenar el comienzo de la pila 1
    la a0, stack1
    sw t0, 0(a0)

    #-- Configurar la pila de la tarea 2
    la a0, stack2
    sub t0, t0, t1
    sw t0, 0(a0)

    #-- Inicializar la memoria del contexto 1
    la a0, ctx1
    la a1, task1
    la a2, stack1
    jal ctx_init

    #-- Inicializar la memoria del contexto 2
    la a0, ctx2
    la a1, task2
    la a2, stack2
    jal ctx_init

    #-- Inicializar puntero al contexto actual
    la t0, ctx_list
    la t1, ctx
    sw t0, 0(t1)  #-- ctx --> ctx_list[0]

    #-- Configurar el comparador
    li t0, MTIMECMPH  #-- Direccion del comparador alto
    sw zero, 0(t0)  
    li t0, MTIMECMP  #-- Direccion del comparador bajo
    sw zero, 0(t0) 

    #-- Actualizar el comparador del timer
    #-- Interrupcion dentro de a0 ciclos
    li a0, TIMEOUT
    jal mtime_set_compare

    #-- Activar las interrupciones del temporizador
    li t0, MIE_MTIE
    csrs mie, t0

    #-- Activar las interrupciones globales
    li t0, MSTATUS_MIE
    csrs mstatus, t0

    #--- Activar el temporizador del RISCV
    #--- Que se actualice en cada ciclo
    li t0, MTIME_CTRL
    li t1, 0x3
    sw t1, 0(t0)


    #--- Obtener el puntero al contexto actual
    #--- s0: Puntero al contexto actual
    la t0, ctx
    lw t0, 0(t0)
    lw s0, 0(t0)

    #-- Saltar a ejecutar la tarea actual
    lw t0, PC(s0)
    jalr t0


# -----------------------
# -- Tarea 1
# -----------------------
task1:
    #-- Inicializar el puntero de pila de la tarea 1
    la t0, stack1
    lw sp, 0(t0)

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

