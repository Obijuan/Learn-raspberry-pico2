.include "boot.h"
.include "gpio.h"

.section .text

# -- Punto de entrada
.global _start
_start:

    jal config_led

    li s0, 0xd0000038
    li s1, 0x02000000
    sw	s1,0(s0)  

    li a0,0
    jal	gpio_init  # -- gpio_init(0)

    li s0, 0xd0000040
    li  a1,1
    sw  a1,0(s0)  

    li  a0,0
    li  a2,0
    jal gpio_set_pulls  

label:
    li s0, 0xd0000004  
    lw a5, 0(s0)       
    andi a5,a5,1
    beqz a5,next
loop:
    li s0, 0xd0000018
    sw s1,0(s0)       

    li s0, 0xd0000004
    lw	a5,0(s0)       
    andi	a5,a5,1
    bnez	a5,loop
next:   
    li s0, 0xd0000020
    sw s1,0(s0)       
    j label


gpio_init:
    
    li a3, 1
    li a4, 0xd0000040
    sw a3,0(a4) 

    li a4, 0xd0000020
    sw	a3,0(a4)

    li a5, 0x40038004
    lw a4,0(a5)

    xori a4,a4,0x40
    andi a4,a4,0xc0
    li a3, 0x40039004
    sw a4,0(a3)

    li a0,0x40028004
    li	a4,5
    sw	a4,0(a0)

    li  a5, 0x4003b004
    li	a4,0x100
    sw	a4,0(a5)
    ret


gpio_set_pulls:
    lui	a5,0x40038
    addi	a5,a5,4 # 40038004 <__StackTop+0x1ffb6004>
    sh2add	a0,a0,a5
    lw	a5,0(a0)
    slli	a1,a1,0x3
    slli	a2,a2,0x2
    or	a2,a2,a1
    xor	a2,a2,a5
    lui	a5,0x1
    andi	a2,a2,12
    add	a0,a0,a5
    sw	a2,0(a0)
    ret
