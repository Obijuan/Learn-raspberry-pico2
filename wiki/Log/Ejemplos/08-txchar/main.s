 # ----------------------------------------------
 # -- Envío de un carácter por la UART
 # ----------------------------------------------

.include "boot.h"
.include "gpio.h"

# -----------------------------------
# -- Registro de Control del Reset 
# -----------------------------------
# https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf#tab-registerlist_resets
# 
# * Bit 26: UART0
# -----------------------------------
.equ RESET_CTRL,     0x40020000
.equ RESET_CTRL_CLR, 0x40023000

# -----------------------------------
# -- Registro de Status del reset
# -- Pone a 1 el bit correspondiente
# -- cuando el periférico se ha reseteado 
# -----------------------------------
.equ RESET_DONE, 0x40020008

.equ SRAM_BASE,  0x20000000
.equ UART0_BASE, 0x40070000


.section .text

# -- Punto de entrada
.global _start
_start:

    #-- Inicializar la pila
    la sp, _stack_top

    #-- Configurar el LED
    jal led_init  

     #-- Configurar el pulsador
    #jal button_init

    #-- main
    li a1,115200      #-- Baudios
    li a0,UART0_BASE
    jal uart_init 

    #-- La primera vez que se llama simplemente retorna sin configurar nada...
    #-- Pero al hacer un reset con el pulsador (pin run a GND) entonces si
    #-- que configura cosas...

    li a1,2
    li a0,0
    jal gpio_set_function

    li	a1,2
    li	a0,1
    jal	gpio_set_function

    #-- TODO: Analizar este codigo

    lui	a4,0x40070
next:
    lw	a5,24(a4)
    andi	a5,a5,32
    bnez	a5,next
    li	a5,65
    sw	a5,0(a4)
    li	a0,0

    jal led_on

inf3: j inf3

#--------------------------------
#-- Inicializar la UART
#-- a0: Direccion base usart0
#-- a1: Baudios
#---------------------------------
uart_init:
    
    #-- Preambulo de la funcion
    addi sp,sp,-32
    sw ra,28(sp)
    sw s0,24(sp)
    sw s1,20(sp)

    #-- s0: Puntero a la uart0
    mv s0,a0

    #-- s1: Baudios
    mv s1,a1

    #-- Llamar a clock_get_hz(6)
    #-- Devuelve el contenido de la posicion de memoria 0x2000050c
    #-- En principio eso es SRAM... no registros especificos
    #-- Es una variable, que inicialmente vale 0
    li a0,6
    jal clock_get_hz

    #-- a0 vale 0 (la primera vez)
    beqz  a0,uart_init_end

    #-- Esto no se ejecuta la primera vez
    #-- 
    #-- TODO
    jal led_blinky

    #-- DEBUG!!
    jal debug_led1_MSB
    jal led_blinky


uart_init_end:
    #-- Fin de la funcion
    lw ra,28(sp)
    lw s0,24(sp)
    lw s1,20(sp)
    addi sp,sp,32
    ret


#-------------------------------
#-- Lectura de una variable
#-------------------------------
clock_get_hz:
    li a5, 0x200004f4  #-- RAM-BASE + 0x4f4

    #-- Calcular: a0 = a5 + a0<<2
    sll a0, a0, 2  #-- a0<<2
    add a0, a5, a0 
    
    lw a0,0(a0)  #-- Mem[0x2000050c]
    ret


gpio_set_function:
    lui	a5,0x40038
    addi	a5,a5,4 # 40038004 <__StackTop+0x1ffb6004>
    sh2add	a5,a0,a5
    lw	a4,0(a5)
    lui	a3,0x1
    add	a3,a3,a5
    xori	a4,a4,64
    andi	a4,a4,192
    lui	a2,0x40028
    sw	a4,0(a3)
    sh3add	a0,a0,a2
    lui	a4,0x3
    add	a5,a5,a4
    sw	a1,4(a0)
    li	a4,256
    sw	a4,0(a5)
    ret



#-----------------------------------



    # --------- Configurar la UART0

    #-- Configurar pin GPIO0 como UART0-TX
    li t0, GPIO00_CTRL
    li t1, FUNC_UART0_TX
    sw t1, 0(t0)


    #-- DEBUG: Observar el valor del registro
    li t0, RESET_CTRL
    lw a0, 0(t0)
    li a1, BIT26
    jal print_led1

    #-- Poner el bit 26 a 0
    not a1,a1
    and a0, a0,a1
    sw a0, 0(t0)

    #-- Esperar a que se pulse el boton
    jal button_press

    #-- Observar el bit 26 otra vez
    li t0, RESET_DONE
    lw a0, 0(t0)
    li a1, BIT26
    jal print_led1


inf2:
    j inf2

    #jal debug_led1_MSB

    #-- Al terminar hacer parpadear el LED rápidamente
    #jal led_blinky









    #-- Activar el reset de la UART0
    li t0, RESET_CTRL
    li t1, BIT26  #-- UART0
    sw t1, 0(t0)

    #-- Desactivar el reset
    li t0, RESET_CTRL_CLR
    li t1, BIT26  #-- UART0
    sw t1, 0(t0)

    #---------- Esperar a que el reset se complete
    li t0, RESET_DONE

wait_reset:
    lw t1, 0(t0)  #-- Leer estado del reset
    li t2, BIT26  #-- Mascara para lectura del reset
    and t1, t1, t2 #-- Comprobar si el reset se ha completado
    beq t1,zero, wait_reset

    # -- Encender el LED
    jal led_on


    #-- ddd

        #-- Fin
inf:    j inf
   
halt:
    j halt

