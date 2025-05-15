# --- Funciones de interfaz
.global led_init
.global led_on
.global led_off
.global led_toggle
.global led_set
.global led_blinky
.global led_blinky2
.global led_blinky3
.global led_blinky4

# -- Definición de constantes para acceder 
# -- a los GPIOs
.include "regs.h"

.section .text

# ------------------------------
# -- Configurar el LED
# ------------------------------
led_init:

    #-- Configuracion de GPIO25 para controlarse por software
    li t0, GPIO25_CTRL  
    li t1, FUNC_SOFTWARE          
    sw t1, 0(t0)

    #-- Habilitar el pin GPIO25
    li t0, PAD_GPIO25  
    li t1, PAD_ENABLE_OUT
    sw t1, 0(t0)

    #-- Configuracion de GPIO25 como salida
    li t0, GPIO_OE_SET      
    li t1, BIT25
    sw t1, 0(t0)
    ret

#-------------------------------
#-- Establecer el estado del LED
#-- Entrada: a0: 1=encender, 0=apagar
#---------------------------------
led_set:

    #-- Es 0 --> apagar el LED
    beq a0, zero, led_off

    #-- Es s1 --> encender el LED
    j led_on

# ---------------------
# -- Encender el LED
# ---------------------
led_on:
    li t0, GPIO_OUT_SET
    li t1, BIT25    #-- Activar el bit 25
    sw t1, 0(t0)
    ret  

# ---------------------
# -- Apagar el LED
# ---------------------
led_off:
    li t0, GPIO_OUT_CLR
    li t1, BIT25    #-- Desactivar el bit 25
    sw t1, 0(t0)
    ret

# -----------------------------
# -- Cambiar el estado del LED
# -----------------------------
led_toggle:
    li t0, GPIO_OUT_XOR
    li t1, BIT25    #-- Cambiar el estado del bit 25
    sw t1, 0(t0) 
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

led_blinky2:
    jal delay2
    jal led_toggle
    j led_blinky2

led_blinky3:
    jal delay3
    jal led_toggle
    j led_blinky3

led_blinky4:
    jal delay4
    jal led_toggle
    j led_blinky4

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

# -----------------------------------------------
# -- Delay
# -- Realizar una pausa de medio segundo aprox.
# -----------------------------------------------
delay2:
    # -- Usar t0 como contador descendente
    li t0, 0x2FFFF
delay2_loop:
    beq t0,zero, delay2_end_loop
    addi t0, t0, -1
    j delay2_loop

    # -- Cuando el contador llega a cero
    # -- se termina
delay2_end_loop:
    ret

# -----------------------------------------------
# -- Delay
# -- Realizar una pausa de medio segundo aprox.
# -----------------------------------------------
delay3:
    # -- Usar t0 como contador descendente
    li t0, 0xFFFFF
delay3_loop:
    beq t0,zero, delay3_end_loop
    addi t0, t0, -1
    j delay3_loop

    # -- Cuando el contador llega a cero
    # -- se termina
delay3_end_loop:
    ret

# -----------------------------------------------
# -- Delay
# -- Realizar una pausa de medio segundo aprox.
# -----------------------------------------------
delay4:
    # -- Usar t0 como contador descendente
    li t0, 0x2FFFFF
delay4_loop:
    beq t0,zero, delay4_end_loop
    addi t0, t0, -1
    j delay4_loop

    # -- Cuando el contador llega a cero
    # -- se termina
delay4_end_loop:
    ret
