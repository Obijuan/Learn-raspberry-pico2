# --- Funciones de interfaz
.global led_init
.global led2_init
.global ledn_init
.global led_on
.global led2_on
.global ledn_on
.global led_off
.global ledn_off
.global led_toggle
.global ledn_toggle
.global led_set
.global led_blinky
.global led_blinky2
.global led_blinky3
.global led_blinky4
.global sim_led_on
.global sim_led_off
.global sim_led_init

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


#---------------------------------
#--- Funciones para simulacion 
#---------------------------------

.equ SIM_LED, 0x2aaac000  #-- Direccion del LED en simulacion

# ---------------------
# -- Encender el LED
# ---------------------
sim_led_on:
    li t0, SIM_LED
    li t1, BIT25    #-- Activar el bit 25
    sw t1, 0(t0)
    ret 

# ---------------------
# -- Apagar el LED
# ---------------------
sim_led_off:
    li t0, SIM_LED
    li t1, BIT25    #-- Desactivar el bit 25
    sw t1, 0(t0)
    ret

sim_led_init:
    ret


#-----------------------------------------------------------------
#-- Control de un LED conectado al GPIO2 
#-----------------------------------------------------------------
#-- Funciones cableadas que afectan directamente al GPIO2
#-- Se definen para mostrar la simplicidad
#-- Es más fácil entender el funcionamiento con ejemplos concretos
#-- en vez de hacerlo con leds genéricos
#-----------------------------------------------------------------


# ------------------------------
# -- Configurar el LED2
# -- Solo hay que escribir en 3 registros para configurar el LED
#-----------------------------------------------------------------

led2_init:

    #-- Configuracion de GPIO25 para controlarse por software
    li t0, GPIO2_CTRL  
    li t1, FUNC_SOFTWARE          
    sw t1, 0(t0)

    #-- Habilitar el pin GPIO25
    li t0, PAD_GPIO2  
    li t1, PAD_ENABLE_OUT
    sw t1, 0(t0)

    #-- Configuracion de GPIO25 como salida
    li t0, GPIO_OE_SET      
    li t1, BIT2
    sw t1, 0(t0)
    ret

# ---------------------
# -- Encender el LED2
# ---------------------
led2_on:
    li t0, GPIO_OUT_SET
    li t1, BIT2
    sw t1, 0(t0)
    ret  


#---------------------------------------------------------------
#-- CONTROL GENERICO DE LEDS
#---------------------------------------------------------------

#----------------------------------
#-- Iniciar un LED
#-- ENTRADAS:
#--   a0: Numero del GPIO (0-31)
#----------------------------------
ledn_init:

    #-- Calcular la direccion del GPIOx
    #-- Direccion base
    li t0, GPIO_BASE

    #-- Dir. Base GPIOn
    #-- BASE_GPIOx = GPIO_BASE + n*8 =
    #-- = GPIO_BASE + n*(2**3 = GPIO_BASE + n << 3
    slli t1, a0, 3  #-- t1 = a0 * 8
    add t0, t0, t1  #-- t0 = GPIO_BASE + n*8

    #-- Establecer funcion: Control por software  
    li t1, FUNC_SOFTWARE          
    sw t1, 4(t0)  #-- Reg. de control del GPIOn

    #--------- Paso 2: Habilitar el pin
    #-- Hay que escribir un valor en el registro PAD_GPIOn 

    #-- Calcular direccion base:
    #-- Direccion base: 
    #-- PAD_GPIOn = PADS_BANK0_BASE + (n * 4) + 0x04
    li t0, PADS_BANK0_BASE

    slli t1, a0, 2  #-- t1 = n * 4
    add t0, t0, t1  #-- t0 = PADS_BANK0_BASE + n*4

    #-- Habilitar el pin GPIOn
    li t1, PAD_ENABLE_OUT
    sw t1, 4(t0)

    #--------- Pase 3: Configurar GPIOn como salida
    li t0, GPIO_OE_SET      

    #-- Calcular la mascara del bit
    #-- Mascara del bit: 1 << n
    li t1, 1
    sll t2, t1, a0  #-- t2 = 1 << n

    #-- Escribir la mascara en el registro
    sw t2, 0(t0)

    ret

#------------------------------
#-- Encender el LED n
#-- ENTRADAS:
#--   a0: Numero del GPIO (0-31)
#------------------------------
ledn_on:
    #------------ ENCENDER LED
    #-- Poner GPIOn a 1
    li t0, GPIO_OUT_SET

    #-- Calcular la mascara del bit
    #-- Mascara del bit: 1 << n
    li t1, 1
    sll t2, t1, a0  #-- t2 = 1 << n

    #-- Escribir la mascara en el registro
    sw t2, 0(t0)

    ret

#------------------------------
#-- Apagar el LED n
#-- ENTRADAS:
#--   a0: Numero del GPIO (0-31)
#------------------------------
ledn_off:

    #-- Poner GPIOn a 0
    li t0, GPIO_OUT_CLR

    #-- Calcular la mascara del bit
    #-- Mascara del bit: 1 << n
    li t1, 1
    sll t2, t1, a0  #-- t2 = 1 << n

    #-- Escribir la mascara en el registro
    sw t2, 0(t0)

    ret

#------------------------------
#-- Cambiar de estado el LED n
#-- ENTRADAS:
#--   a0: Numero del GPIO (0-31)
#------------------------------
ledn_toggle:

    #-- Cambiar de estado el GPIOn
    li t0, GPIO_OUT_XOR

    #-- Calcular la mascara del bit
    #-- Mascara del bit: 1 << n
    li t1, 1
    sll t2, t1, a0  #-- t2 = 1 << n

    #-- Escribir la mascara en el registro
    sw t2, 0(t0)

    ret
