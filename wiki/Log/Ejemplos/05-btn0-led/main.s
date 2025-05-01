.include "boot.h"
.include "gpio.h"

.section .text

# -- Punto de entrada
.global _start
_start:

   

    li s1, BIT25

    li a0,0
    jal	gpio_init  # -- gpio_init(0)

    li s0, GPIO_OE_CLR
    li  a1,1
    sw  a1,0(s0)  

    li  a0,0
    li  a2,0
    jal gpio_set_pulls  

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


gpio_init:
    
    li a3, 1
    li a4, GPIO_OE_CLR
    sw a3,0(a4) 

    li a4, GPIO_OUT_CLR
    sw	a3,0(a4)

    li a5, PAD_GPIO0
    lw a4,0(a5)

    xori a4,a4,0x40
    andi a4,a4,0xc0
    li a3, 0x40039004
    sw a4,0(a3)

    li a0,GPIO00_CTRL
    li	a4,5
    sw	a4,0(a0)

    li  a5, 0x4003b004
    li	a4,0x100
    sw	a4,0(a5)
    ret


gpio_set_pulls:
    li	a0,0x40038004
    lw	a5,0(a0)

    li a2, 8
    xor	a2,a2,a5
    andi	a2,a2,0x0C 
    li a0, 0x40039004
    sw	a2,0(a0)
    ret
