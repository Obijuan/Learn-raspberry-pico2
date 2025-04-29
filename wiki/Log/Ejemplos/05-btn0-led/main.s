 
# -- Se debe incluir para generar una imagen válida
.include "boot.h"

.include "gpio.h"

.section .text


# -- Punto de entrada
.global _start
_start:

    # ----------------------------------
    # -- Configuracion del GPIO0
    # ----------------------------------
    #-- Control por software
    li t0, GPIO00_CTRL  
    li t1, FUNC_SOFTWARE          
    sw t1, 0(t0)

    #-- Configuración del PAD: ENTRADA
    #-- ISO | OD | IE | DRIVE | PUE | PDE | SCHMITT | SLEWFAST 
    #--  0  | 1  | 1  | 00    | 1   | 0   |   1     | 1        
    li t0, PAD_GPIO0 
    li t1, 0x0CB
    sw t1, 0(t0)

     #-- Configurar el LED
    jal config_led  


loop:
    #-- Direccion de los GPIOs
    li t0, GPIO_IN

    #-- Leer el GPIO0
    lw t1, 0(t0)
    li t2, BIT0  #-- Bit a leer
    and t1, t1, t2

    #-- Mostrar el valor en el LED
    #-- Según el caso
    beq t1,zero, led_off

    #-- Encender el led
    jal led_on
    j loop

    #-- Apagar el LED
led_off:
    jal led_off
    j loop
    #-- Mostrar valor en el LED


 

