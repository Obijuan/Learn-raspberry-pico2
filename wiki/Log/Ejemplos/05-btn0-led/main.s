.include "boot.h"
.include "gpio.h"

.section .text

# -- Punto de entrada
.global _start
_start:

    
    li a0,25
    jal gpio_init    # --  gpio_init(25)

    lui s0,0xd0000   #-- s0 = 0xD0000000
    lui s1,0x2000    #-- s1 = 0x02000000
    sw	s1,56(s0)    #-- Mem[D000_0038]=0x02000000 

    li a0,0
    jal	gpio_init  # -- gpio_init(0)

    li  a1,1
    sw  a1,64(s0)  # -- Mem[D000_0040]=1

    li  a0,0
    li  a2,0
    jal gpio_set_pulls  # -- gpio_set_pulls(0)

label:  
    lw a5, 4(s0)       # -- a5 = Mem[D000_0004]
    andi a5,a5,1
    beqz a5,next
loop:   
    sw s1,24(s0)       # -- Mem[D000_0018]=0x02000000
    lw	a5,4(s0)       # -- a5 = Mem[D000_0004]
    andi	a5,a5,1
    bnez	a5,loop
next:   
    sw s1,32(s0)       # -- Mem[D000_0020]=0x02000000
    j label


gpio_init:
    bset a3,zero,a0      #-- a3 = 1 << a0
    lui	a4,0xd0000       #-- a4 = 0xD0000000
    lui	a5,0x40038       #-- a5 = 0x40038000
    sw a3,64(a4)         #-- Mem[D000_0040]=a3
    addi a5,a5,4         #-- a5 = 0x40038004
    sw	a3,32(a4)
    sh2add	a5,a0,a5
    lw	a4,0(a5)
    lui	a3,0x1
    add	a3,a3,a5
    xori	a4,a4,64
    andi	a4,a4,192
    lui	a2,0x40028
    sw	a4,0(a3)
    sh3add	a0,a0,a2
    li	a4,5
    lui	a3,0x3
    sw	a4,4(a0)
    add	a5,a5,a3
    li	a4,256
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
