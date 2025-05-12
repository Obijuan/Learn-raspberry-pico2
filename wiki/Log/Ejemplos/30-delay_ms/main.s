#---------------------------
#-- Funciones de interfaz
#---------------------------
.global _start   #-- Punto de entrada

.include "riscv.h"
.include "regs.h"
.include "uart.h"
.include "ansi.h"

.section .text

# -- Punto de entrada
_start:

    #-- Acciones de arranque
    la sp, __stack_top
    jal	runtime_init

    #-- Configurar perifericos
    jal led_init
    jal uart_init

    #-- Encender el LED
    jal led_on

main: 

    li a0, 100
    jal delay_ms

    jal led_toggle

    j main
    
#----------------------------------
#-- Funcion de retardo, en ms
#----------------------------------
#-- ENTRADAS:
#--  a0: ms a esperar (>=1)
#----------------------------------
delay_ms:

    #-- Encender el AON-Timer
    li t0, POWMAN_TIMER_SET
    li t1, RUN
    sw t1, 0(t0)

    #-- Esperar hasta que transcurra el tiempo
    #-- establecido

_timer_wait:
    
    #-- Leer temporizador (en ms)
    li t0, READ_TIME_LOWER
    lw t1, 0(t0) 

    #-- Ha transcurrido el tiempo?
    bltu t1, a0, _timer_wait

    #-- Ha pasado el tiempo indicado

    #-- Apagar temporizador
    li t0, POWMAN_TIMER_CLR
    li t1, RUN
    sw t1, 0(t0)

    ret
    