 # ----------------------------------------------
 # -- Parpadeo del LED, mediante espera activa 
 # ----------------------------------------------

# -- Se debe incluir para generar una imagen válida
.include "boot.h"

# -- Definición de constantes para acceder 
# -- a los GPIOs
.include "gpio.h"

.section .text

# ------------------------------
# -- Configurar el LED
# ------------------------------
config_led:

    #-- Configuracion de GPIO0 para controlarse por software
    li t0, GPIO25_CTRL  
    li t1, FUNC_SOFTWARE          
    sw t1, 0(t0)

    #-- Habilitar el pin GPIO0
    li t0, GPIO25_PAD_ISO  
    li t1, PAD_ENABLE
    sw t1, 0(t0)

    #-- Configuracion de GPIO0 como salida
    li t0, GPIO_OE      
    li t1, BIT25
    sw t1, 0(t0)
    ret

# ---------------------
# -- Encender el LED
# ---------------------
led_on:
    li t0, GPIO_OUT
    li t1, BIT25    #-- Activar el bit 25
    sw t1, 0(t0)
    ret  

# ---------------------
# -- Apagar el LED
# ---------------------
led_off:
    li t0, GPIO_OUT
    sw zero, 0(t0)
    ret

# -----------------------------------------------
# -- Delay
# -- Realizar una pausa de medio segundo aprox.
# -----------------------------------------------
delay:
    # -- Usar t0 como contador descendente
    li t0, 0xFFFFF
delay_loop:
    beq t0,zero, delay_end_loop
    addi t0, t0, -1
    j delay_loop

    # -- Cuando el contador llega a cero
    # -- se termina
delay_end_loop:
    ret


# -- Punto de entrada
.global _start
_start:
    
    #-- Configurar el LED
    jal config_led    

loop:
    # -- Encender el LED
    jal led_on

    # -- Esperar
    jal delay

    # -- Apagar el LED
    jal led_off

    # -- Esperar
    jal delay

    # -- Repetir
    j loop
   


