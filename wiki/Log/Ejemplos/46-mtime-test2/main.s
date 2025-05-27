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

    #-- Apagar LED
    jal led_off

    CLS

    #--- Activar el temporizador del RISCV
    #--- Que se actualice en cada ciclo
    li t0, MTIME_CTRL
    li t1, 0x3
    sw t1, 0(t0)

    #-- Configurar el comparador
    jal inc_timer 

    COLOR WHITE
    PRINT "Temporizador lanzado!\n\n"

    #-- Activar las interrupciones del temporizador
    li t0, MIE_MTIE
    csrs mie, t0

    #-- Activar las interrupciones globales
    li t0, MSTATUS_MIE
    csrs mstatus, t0

loop:

    jal print_mtimer
    NL

    #-- Esperar (espera activa)
    jal delay
    jal delay

    #-- Repetir 
    j loop


#-------------------------------------------------
#-- Sumar dos numeros de 64 bits
#-------------------------------------------------
#-- ENTRADAS:
#--  -Primer numero:
#--     a1: Parte alta
#--     a0: Parte baja
#--  -Segundo numero:
#--     a3: Parte alta
#--     a2: Parte baja
#-- SALIDA:
#--  - a1: Parte alta
#--  - a0: Parte baja
#--------------------------------------------------
add64:
    #-- Sumar bytes de menor peso (a0 + a2)
    add t0, a0, a2

    #-- Calcular el acarreo
    sltu t2, t0, a0  #-- Si t0 < a0, hay acarreo

    #-- Sumar la parte alta
    add t1, a1, a3

    #-- Sumar el acarreo
    add t1, t1, t2

    #-- Devolver resultado
    mv a1, t1
    mv a0, t0

    #-- Terminar
    ret

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
    li a2, 0x20000000  #-- Parte baja
    
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


print_mtimer:
FUNC_START4
    #-- Leer temporizador del RISCV
    PRINT "Timer: "
    li t0, MTIMEH
    lw a0, 0(t0)
    jal print_hex32
    PRINT "-"
    li t0, MTIME
    lw a0, 0(t0)
    jal print_hex32
    NL

    #-- Imprimir el comparador
    PRINT "CMP:   "
    li t0, MTIMECMPH
    lw a0, 0(t0)
    jal print_hex32
    PRINT "-"
    li t0, MTIMECMP
    lw a0, 0(t0)
    jal print_hex32
    NL
FUNC_END4


#--------------------------------------------------------------
#-- Rutina de servicio de interrupcion
#--------------------------------------------------------------
#-- Se supone que solo llega la interrupción del temporizador
#--------------------------------------------------------------
isr:
    SAVE_CONTEXT

    jal led_toggle
    CPRINT RED, "ISR: Temporizador!\n"
    COLOR WHITE

    jal inc_timer

    RESTORE_CONTEXT
    mret    

