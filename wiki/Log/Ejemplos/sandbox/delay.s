#-----------------------------------
#-- FUNCIONES DE INTERFAZ
#-----------------------------------
.global delay
.global delay_ms

.include "regs.h"

.section .text

#---------------------------------------
#-- delay_ms: Funcion de retardo, en ms
#---------------------------------------
#-- ENTRADAS:
#--  a0: ms a esperar (>=1)
#---------------------------------------
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
    

# -----------------------------------------------
# -- Delay
# -- Realizar una pausa de medio segundo aprox.
# -----------------------------------------------
delay:
    # -- Usar t0 como contador descendente
    li t0, 0xFFFFFF
delay_loop:
    beq t0,zero, delay_end_loop
    addi t0, t0, -1
    j delay_loop

    # -- Cuando el contador llega a cero
    # -- se termina
delay_end_loop:
    ret
