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
    #--  8  |  7 |  6 |  5    |  4  |  3  |   2     |   1
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
    andi t1, t1, BIT0

    #-- Mostrar el valor en el LED
    #-- Según el caso
    beq t1,zero, apagar_led

    #-- Encender el led
    jal led_on
    j loop

    #-- Apagar el led
apagar_led:
    jal led_off
    j loop

