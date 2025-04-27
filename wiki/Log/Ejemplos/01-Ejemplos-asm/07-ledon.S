.global main

.include "gpio.h"

main:   

    #-- Configuracion de GPIO0 para controlarse por software
    li t0, GPIO25_CTRL  
    li t1, FUNC_SOFTWARE          
    sw t1, 0(t0)        

    #-- Configuracion de GPIO0 como salida
    li t0, GPIO_OE      
    li t1, BIT25
    sw t1, 0(t0)

    #-- Habilitar el pin GPIO0
    li t0, GPIO25_PAD_ISO  
    li t1, PAD_ENABLE
    sw t1, 0(t0)

    # -- Encender el LED
    li t0, GPIO_OUT
    li t1, BIT25    #-- Activar el bit 25
    sw t1, 0(t0)  

    # -- FIN
inf:  j inf
      nop

