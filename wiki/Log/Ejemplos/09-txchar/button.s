#--------------------------------------------------
#-- Funciones de acceso al pulsador conectado
#-- al GPIO0
#--------------------------------------------------

#--- Funciones de interfaz
.global button_init0
.global button_init15
.global button_press0
.global button_press15

.include "gpio.h"

.section .text

#-------------------------------------
#-- Inicializacion del pulsador
#-- Confgirar el GPIO0 como entrada
#-- y habilitar el pull-up
#-------------------------------------
button_init0:

    #-- GPIO0: Control por software
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
    ret


button_init15:

    #-- GPIO15: Control por software
    li t0, GPIO15_CTRL  
    li t1, FUNC_SOFTWARE          
    sw t1, 0(t0)

    #-- Configuración del PAD: ENTRADA
    #--  8  |  7 |  6 |  5    |  4  |  3  |   2     |   1
    #-- ISO | OD | IE | DRIVE | PUE | PDE | SCHMITT | SLEWFAST 
    #--  0  | 1  | 1  | 00    | 1   | 0   |   1     | 1        
    li t0, PAD_GPIO15 
    li t1, 0x0CB
    sw t1, 0(t0)
    ret


#------------------------------------------------
#-- Esperar a que se apriete el pulsador
#-- La funcion retorna cuando el pulsador se ha  
#-- apretado
#------------------------------------------------
button_press0:

    # -- Cabecera funcion
    addi sp,sp, -16
    sw ra, 12(sp)   

    #-- Esperar hasta que el GPIO0 está a 1
    #-- (Boton no pulsado)
wait_1:

    li t0, GPIO_IN
    lw t1, 0(t0)   
    andi t1, t1, BIT0  #-- Leer pulsador del GPIO0

    #-- Si está pulsado, esperar a que se suelte
    beq t1,zero, wait_1

    #---- El boton NO está apretado
    #-- Espera antirrebotes
    jal delay 

    #-- Esperar hasta que el GOPIO0 esté a 0
    #-- (Boton pulsado)
wait_0:
    li t0, GPIO_IN
    lw t1, 0(t0)
    andi t1, t1, BIT0  #-- Leer pulsador del GPIO0

    #-- si no apretado, esperar
    bne t1,zero, wait_0

    #--- BOTON APRETADO
    #-- Espera antirrebotes
    jal delay

    #-- Fin de la funcion
    lw ra, 12(sp)
    addi sp,sp, 16
    ret

#------------------------------------------------
#-- Esperar a que se apriete el pulsador
#-- La funcion retorna cuando el pulsador se ha  
#-- apretado
#------------------------------------------------
button_press15:

    # -- Cabecera funcion
    addi sp,sp, -16
    sw ra, 12(sp)   

    #-- Esperar hasta que el GPIO0 está a 1
    #-- (Boton no pulsado)
btn15_wait_1:

    li t0, GPIO_IN
    lw t1, 0(t0)   
    li t2, BIT15
    and t1, t1, t2  #-- Leer pulsador del GPIO0

    #-- Si está pulsado, esperar a que se suelte
    beq t1,zero, btn15_wait_1

    #---- El boton NO está apretado
    #-- Espera antirrebotes
    jal delay 

    #-- Esperar hasta que el GOPIO0 esté a 0
    #-- (Boton pulsado)
btn15_wait_0:
    li t0, GPIO_IN
    lw t1, 0(t0)
    li t2, BIT15
    and t1, t1, t2  #-- Leer pulsador del GPIO0

    #-- si no apretado, esperar
    bne t1,zero, btn15_wait_0

    #--- BOTON APRETADO
    #-- Espera antirrebotes
    jal delay

    #-- Fin de la funcion
    lw ra, 12(sp)
    addi sp,sp, 16
    ret


# -----------------------------------------------
# -- Delay
# -- Realizar una pausa para eliminar los rebotes
# -- del pulsador
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
