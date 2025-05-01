.include "boot.h"
.include "gpio.h"

.section .text

# -- Punto de entrada
.global _start
_start:

    #-- Inicializar la pila
    la sp, _stack_top

    #-- Configurar el LED
    jal led_init  

    #-- Configurar el pulsador
    jal button_init

    #-- Mostrar un valor por los LEDs
    mv a0, sp
    jal debug_led1_lsb
    jal led_blinky

    #-- Fin
inf:
    j inf

#-------------------------------------------------
#-- DEPURACION. Mostrar un numero de 32 bits
#-- en el LED, bit a bit
#-- Se muestra el bit menos significativo primero
#-- Entradas:
#-- a0: Valor a mostrar
#-------------------------------------------------
debug_led1_lsb:

    #-- Preambulo de la funciona
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)

    #-- Guardar el valor a mostrar
    #-- en el registro s0
    mv s0, a0

    #-- Numero de bit a mostrar
    #-- Empezamos por el bit 0
    li s1,0

loop:

    #-- Mostar el bit actual en el LED
    mv a0, s0
    mv a1, s1
    jal print_led1

    #-- Esperar hasta que se apriete el pulsador
    jal button_press

    #-- Pasar al siguiente bit
    addi s1, s1, 1

    #-- Si es menor que 32, repetir
    li t0, 32
    blt s1, t0, loop

    #-- fin de la funcion
    lw s1, 4(sp)
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

#--------------------------------------------
#-- Mostrar en el LED el bit del valor dado 
#-- Entradas:
#-- a0: Valor que se quiere ver
#-- a1: Bit a mostrar
#---------------------------------------------
print_led1:

    #-- Preambulo de la funcion
    addi sp, sp, -16
    sw ra, 12(sp)

    #-- t0: máscara del bit a visualizar
    #-- (1 << a1)
    li t1, 1
    sll t0, t1, a1

    #-- t2: Valor aislado del bit
    and t2, a0, t0

    #-- t3 contiene el valor del bit
    sgtu t3, t2,zero

    #-- Mostrar t3 en el LED
    mv a0, t3
    jal led_set

    #-- Fin de la funcion
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

#------------------------------------
#-- led_blinky
#-- Parpadear el LED infinitamente
#-- ¡OJO! Esta funcion nunca acaba!
#------------------------------------
led_blinky:
    
    jal delay
    jal led_toggle
    j led_blinky



# -----------------------------------------------
# -- Delay
# -- Realizar una pausa de medio segundo aprox.
# -----------------------------------------------
delay:
    # -- Usar t0 como contador descendente
    li t0, 0xFFFF
delay_loop:
    beq t0,zero, delay_end_loop
    addi t0, t0, -1
    j delay_loop

    # -- Cuando el contador llega a cero
    # -- se termina
delay_end_loop:
    ret
