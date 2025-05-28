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
    la t0, isr_timer
    csrw mtvec, t0

main:
    #-- Configurar perifericos
    jal led_init
    LED_INIT(2)
    LED_INIT(3)
    jal uart_init

    #-- Estados iniciales de los LEDs
    jal led_off
    LED_ON(2)
    LED_OFF(3)


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

    #-- Configurar el comparador
    li t0, MTIMECMPH  #-- Direccion del comparador alto
    sw zero, 0(t0)  
    li t0, MTIMECMP  #-- Direccion del comparador bajo
    sw zero, 0(t0)  
    
    #-- Inicializar contador de tics
    li s0, 0
    
    CLS

    #-- Bucle principal
loop:
    PRINT "--> TIC "
    mv a0, s0
    jal print_unsigned_int
    NL

    LED_TOGGLE(2)
    LED_TOGGLE(3)

    DELAY_MS(500)

    #-- Incrementar el contador de tics
    addi s0, s0, 1

    #-- Repetir
    j loop


inc_timer:
FUNC_START4
    #-------------------------------------------------
    #-- Incrementar el comparador
    #-- Comparador = Timer + 0x20000000
    #-- La lectura del timer se hace como se indica  
    #-- en la sección 3.1.8 del Datasheet (Pag. 43)
    #-------------------------------------------------

_read_timer:
    #-- La lectura se hace en 4 pasos:
    #-- 1. Leer la parte alta del timer
    li t1, MTIMEH  #-- Direccion del timer alto
    lw a1, 0(t1)  #-- Leer parte alta del timer

    #-- 2. Leer la parte baja
    li t0, MTIME  #-- Direccion del timer
    lw a0, 0(t0)  #-- Leer el timer (Parte baja)

    #-- 3. Leer la parte alta de nuevo
    lw a2, 0(t1)

    #-- 4. Loop if the two upper-half reads returned different values
    bne a1, a2, _read_timer  #-- Si las dos lecturas no son iguales, repetir
    
    #-- a1, a0 contienen el valor del timer
    
    #-- Preparar el incremento a sumar
    li a3, 0x0  #-- Parte alta
    li a2, 0x01000000  #-- Parte baja
    
    #-- Incrementar el timer
    jal add64
   
    #-- Actualizar el comparador

    #-- Tenemos el valor en t1, t0
    #-- Guardarlo en el comparador
    li t0, MTIMECMPH  #-- Direccion del comparador alto
    sw a1, 0(t0)  #-- Escribir la parte alta del comparador
    li t0, MTIMECMP  #-- Direccion del comparador bajo
    sw a0, 0(t0)  #-- Escribir la parte baja del comparador

FUNC_END4


isr_timer:
    SAVE_CONTEXT    

    #-- Cambiar de estado el led
    jal led_toggle    

    #-- Actualizar el comparador del timer
    #-- Interrupcion dentro de xxx ciclos
    jal inc_timer


    #-- Terminar
    RESTORE_CONTEXT
    mret
