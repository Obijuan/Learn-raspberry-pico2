#---------------------------
#-- Funciones de interfaz
#---------------------------
.global _start   #-- Punto de entrada

.include "riscv.h"
.include "led.h"
.include "uart.h"
.include "ansi.h"
.include "kernel.h"

#-- Pausa en ms
.equ PAUSA, 500

# -- VARIABLES DE SOLO LECTURA
.section .rodata

#-- Tabla de punteros a los diferentes contextos
#-- de las tareas
ctx_list:
    .word ctx1
    .word ctx2
ctx_list_end:


# -- VARIABLES NO INICIALIZADAS
.section .bss

#-- Puntero al contexto actual
#-- (Apunta a un elemento en la lista de contextos)
ctx:    .word 0

    #-- Contexto de la tarea 1
    #-- Se guardan los 32 registros (en vez de x0 se guarda PC)
ctx1:   .space 32 * 4

    #-- Contexto de la tarea 2
ctx2:   .space 32 * 4

    #-- Valores iniciales de las pilas de las tareas
    #-- Se inicializan al arrancar
stack1: .word 0
stack2: .word 0

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

    #-- Guardar los valores de las pilas
    #-- Configurar la pila de la tarea 1
    li t1, 0x1000
    sub sp, sp, t1
    
    #-- Almacenar el comienzo de la pila 1
    la t0, stack1
    sw sp, 0(t0)

    #-- Configurar la pila de la tarea 2
    la t0, stack2
    sub sp, sp, t1
    sw sp, 0(t0)

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

    #-- NO ELIMINAR (de momento)
    nop

    #-- Inicializar el puntero de pila de la tarea 1
    la t0, stack1
    lw sp, 0(t0)

    PRINT "--> TAREA 1: INIT\n"

tarea1_loop:
    PRINT "--> TAREA 1\n"

    #-- Encender LED de tarea
    LED_ON(2)

    li a0, PAUSA
    jal delay_ms
    
    #-- Test: Llamar al S.O
    ecall

    PRINT "--> TAREA 1\n"
    LED_OFF(2)

    li a0, PAUSA
    jal delay_ms

    #-- Llamar al S.O
    ecall

    j tarea1_loop

    PRINT "--> TAREA 1: FIN\n"

    ecall
    HALT


#--------------------------------
#-- Tarea 2
#--------------------------------
task2:

    #--- IMPORTANTE!!!! La primera instruccion NO
    #--- se ejecuta actualmente (porque en la isr se retorna a PC+4)
    nop

    #-- Inicializar el puntero de pila de la tarea 2
    la t0, stack2
    lw sp, 0(t0)

    PRINT "--> TAREA 2: INIT\n"


tarea2_loop:

    PRINT "--> TAREA 2\n"

    #-- Encender LED de tarea
    LED_ON(3)

    li a0, PAUSA
    jal delay_ms

    #-- Llamar al Kernel
    ecall

    PRINT "--> TAREA 2\n"
    LED_OFF(3)

    li a0, PAUSA
    jal delay_ms

    ecall
    j tarea2_loop

    PRINT "--> TAREA 2: FIN\n"
    HALT


#------------------------------------------------------
#-- ctx_next: Apuntar al siguiente contexto
#--   Se actualiza ctx para apuntar al siguiente
#------------------------------------------------------
#-- ENTRADAS:
#--    Ninguna
#-- SALIDAS:
#--    Ninguna
#-------------------------------------------------------
ctx_next:
   #-- Apuntar al siguiente contexto
    la t0, ctx
    lw t0, 0(t0)   #-- Puntero al contexto actual
    addi t0,t0, 4  #-- Apuntar al siguiente contexto

    la t1, ctx_list_end
    bne t0,t1, ctx_end   #-- No hemos llegado al final de la lista, terminar

    #-- Estamos en el final: apuntar al principio
    la t0, ctx_list

ctx_end:

    #--- t0 contine el nuevo contexto
    #-- Actualizar la variable ctx
    la t1, ctx
    sw t0, 0(t1)
    ret



# ----------------------------------
# -- Kernel de multiplexación
# ----------------------------------
isr_kernel:

    #-- Guardar la pila de la tarea actual
    csrw mscratch, sp

    #-- Obtener la pila del sistema
    la sp, __stack_top

    #-- Guardar registros usados en la pila del SO
    addi sp, sp, -16
    sw t0, 8(sp)
    sw t1, 4(sp)

    #--- Obtener el puntero al contexto actual
    #--- t0: Puntero al contexto actual
    la t0, ctx
    lw t0, 0(t0)  #-- Entrada de la tabla
    lw t0, 0(t0)  #-- Puntero al contexto

    #-- Guardar el PC
    csrr t1, mepc
    sw t1, PC(t0)

    #-- Guardar la pila
    csrr t1, mscratch
    sw t1, SP(t0)

    #-- Guardar resto de registros
    sw ra, RA(t0)
    sw gp, GP(t0)
    sw tp, TP(t0)

    #-- Ahora que gp está guardado, lo usamos
    #-- como puntero de contexto en vez t0
    mv gp, t0

    #-- Guardar t0 y t1. Recuperar su valor inicial
    #-- y guardarlo en el contexto
    lw t0, 8(sp)
    lw t1, 4(sp)

    #-- Guardar t0 y t1
    sw t0, T0(gp)
    sw t1, T1(gp)

    #-- Guardar resto de registros
    sw t2, T2(gp)
    sw s0, S0(gp)
    sw s1, S1(gp)
    sw a0, A0(gp)
    sw a1, A1(gp)
    sw a2, A2(gp)
    sw a3, A3(gp)
    sw a4, A4(gp)
    sw a5, A5(gp)
    sw a6, A6(gp)
    sw a7, A7(gp)
    sw s2, S2(gp)
    sw s3, S3(gp)
    sw s4, S4(gp)
    sw s5, S5(gp)
    sw s6, S6(gp)
    sw s7, S7(gp)
    sw s8, S8(gp)
    sw s9, S9(gp)
    sw s10, S10(gp)
    sw s11, S11(gp)
    sw t3, T3(gp)
    sw t4, T4(gp)
    sw t5, T5(gp)
    sw t6, T6(gp)

    jal led_on

    PRINT "******* KERNEL ********\n\n"
    #-- TEST: Imprimir contexto actual
    #------------------- Reponer el contexto de la tarea
    #--- Obtener el puntero al contexto actual
    #--- t0: Puntero al contexto actual
    la t0, ctx
    lw t0, 0(t0)  #-- Entrada de la tabla
    lw a0, 0(t0)  #-- Puntero al contexto
    #jal print_context

    #-- Cambiar al siguiente contexto
    jal ctx_next

    #------------------- Reponer el contexto de la tarea
    #--- Obtener el puntero al contexto actual
    #--- t0: Puntero al contexto actual
    la t0, ctx
    lw t0, 0(t0)  #-- Entrada de la tabla
    lw t0, 0(t0)  #-- Puntero al contexto

    #-- REPONER EL PC
    #-- Esto lo hace la instruccion mret a partir de la informacion
    #-- almacenada en mepc

    #-- NOTA: El pc se incrementa en 4 para apuntar a la siguiente instrucción
    #-- tras el ecal. No tengo claro si con interrupciones del timer hay que
    #-- hacer lo mismo
    lw t1, PC(t0)   #-- Recuperar pc
    addi t1, t1, 4  #-- Incrementar en 4 bytes
    csrw mepc, t1

    #-- El valor antiguo de t0 se guarda en scratch
    #-- (Lo teniamos guardado en la pila del SO)
    lw t1, T0(t0)
    csrw mscratch, t1

    #-- Reponer registros
    lw sp, SP(t0)
    lw ra, RA(t0)
    lw gp, GP(t0)
    lw tp, TP(t0)
    lw t1, T1(t0)
    lw t2, T2(t0)
    lw s0, S0(t0)
    lw s1, S1(t0)
    lw a0, A0(t0)
    lw a1, A1(t0)
    lw a2, A2(t0)
    lw a3, A3(t0)
    lw a4, A4(t0)
    lw a5, A5(t0)
    lw a6, A6(t0)
    lw a7, A7(t0)
    lw s2, S2(t0)
    lw s3, S3(t0)
    lw s4, S4(t0)
    lw s5, S5(t0)
    lw s6, S6(t0)
    lw s7, S7(t0)
    lw s8, S8(t0)
    lw s9, S9(t0)
    lw s10, S10(t0)
    lw s11, S11(t0)
    
    #-- Reponer el registro t0
    csrr t0, mscratch

    mret
