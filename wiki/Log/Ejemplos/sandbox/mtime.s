#------------------------------
#-- FUNCIONES DE INTERFAZ
#------------------------------
.global mtime_set_compare
.global mtime_main_test
.global isr_timer_test


.include "regs.h"
.include "riscv.h"
.include "led.h"
.include "uart.h"
.include "ansi.h"
.include "delay.h"


#------------------------------------
#-- Programa de prueba
#-- Configurar el temporizador y 
#-- hacer parpadear el LED
#------------------------------------
mtime_main_test:

    #-- Establecer el vector de interrupcion
    la t0, isr_timer_test
    csrw mtvec, t0

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

#-------------------------------------------------
#-- Configurar el comparador del mtimer
#-- TIMER_CMP = MTIME + a0
#-- -----------------------------------------------
#-- ENTRADAS:
#--   a0: Valor a incrementar (solo 32-bits)
#--------------------------------------------------
mtime_set_compare:
    FUNC_START4
    sw s0, 8(sp)

    #-- Guardar incremento
    mv s0, a0

    #------------------------------------------------
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
    mv a2, s0   #-- Parte baja
    
    #-- Incrementar el timer
    jal add64
   
    #-- Actualizar el comparador

    #-- Tenemos el valor en t1, t0
    #-- Guardarlo en el comparador
    li t0, MTIMECMPH  #-- Direccion del comparador alto
    sw a1, 0(t0)  #-- Escribir la parte alta del comparador
    li t0, MTIMECMP  #-- Direccion del comparador bajo
    sw a0, 0(t0)  #-- Escribir la parte baja del comparador

    lw s0, 8(sp) 
FUNC_END4

# ------------------------------------------------
# -- Rutina de atención a la interrupción 
# -- del temporizador: PRUEBA
# -- Se cambia el estado del LED periodicamente
# ------------------------------------------------
isr_timer_test:
    SAVE_CONTEXT    

    #-- Cambiar de estado el led
    jal led_toggle    

    #-- Actualizar el comparador del timer
    #-- Interrupcion dentro de a0 ciclos
    li a0, 0x01000000
    jal mtime_set_compare


    #-- Terminar
    RESTORE_CONTEXT
    mret

