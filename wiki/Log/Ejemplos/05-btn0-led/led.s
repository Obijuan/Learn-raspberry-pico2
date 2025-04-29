# --- Funciones de interfaz
.global config_led
.global led_on
.global led_off

# -- Definición de constantes para acceder 
# -- a los GPIOs
.include "gpio.h"

.section .text

# ------------------------------
# -- Configurar el LED
# ------------------------------
config_led:

    #-- Configuracion de GPIO25 para controlarse por software
    li t0, GPIO25_CTRL  
    li t1, FUNC_SOFTWARE          
    sw t1, 0(t0)

    #-- Habilitar el pin GPIO25
    li t0, PAD_GPIO25  
    li t1, PAD_ENABLE_OUT
    sw t1, 0(t0)

    #-- Configuracion de GPIO25 como salida
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
