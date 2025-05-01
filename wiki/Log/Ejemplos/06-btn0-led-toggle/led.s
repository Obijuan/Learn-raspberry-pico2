# --- Funciones de interfaz
.global led_init
.global led_on
.global led_off
.global led_toggle

# -- Definición de constantes para acceder 
# -- a los GPIOs
.include "gpio.h"

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

