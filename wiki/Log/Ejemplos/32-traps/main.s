#---------------------------
#-- Funciones de interfaz
#---------------------------
.global _start   #-- Punto de entrada

.include "regs.h"
.include "riscv.h"

.section .vector
.align 4
_VectorTable:
    j isr_led #AllExceptionsHandler   #-- Exceptions 
    j Isr_UndefinedHandler
    j Isr_UndefinedHandler
    j isr_led #isr_led #Isr_MachineSoftwareInterrupt   #-- MachineSoftwareInterrupt (MSI)
    j Isr_UndefinedHandler
    j Isr_UndefinedHandler
    j Isr_UndefinedHandler
    j isr_led #Isr_MachineTimerInterrupt      #-- MachineTimerInterrupt (MTI)
    j Isr_UndefinedHandler
    j Isr_UndefinedHandler
    j Isr_UndefinedHandler
    j isr_led #Isr_MachineExternalInterrupt   #-- MachineExternalInterrupt (MEI)

.section .text

# -- Punto de entrada
_start:
    /* setup the stack pointer */
    la sp, __stack_top

    /* disable all interrupts flag */
    li t0, ~0x08
    csrc mstatus, t0

    /* disable all specific interrupt sources */
    csrw mie, x0

    /* setup the stack pointer */
    la sp, __stack_top
       
    /* setup the direct interrupt handler */
    la t0, _VectorTable
    addi t0, t0, 1
    csrw mtvec, t0

    /* setup C/C++ runtime environment */
    j  Startup_Init



Startup_Init:
     FUNC_START4

    /* Initialize the CPU Core */
    jal Startup_InitCore


    /* Configure the system clock */
    jal Startup_InitSystemClock

    #-- AQUI LLEGA PUTO ESTABLE!

    /* Initialize the RAM memory */
    #jal Startup_InitRam

    /* Initialize the non-local C++ objects */
    #jal Startup_InitCtors

    /* Start the application */
    jal main
    FUNC_END4
    j .


main:
    FUNC_START4
# 10000060 <main>:
  #-- Aquí llega


    #-- PUTO-LLEGA ESTABLE!
 
    lui	a5,0xd0000
    lw	a3,64(a5) # d0000040 <__CORE1_STACK_TOP+0xaffff030>
    lui	a5,0xd0000
    lui	a4,0x2000
    or	a4,a3,a4
    sw	a4,64(a5) # d0000040 <__CORE1_STACK_TOP+0xaffff030>
    lui	a5,0xd0000
    lw	a3,32(a5) # d0000020 <__CORE1_STACK_TOP+0xaffff010>
    lui	a5,0xd0000
    lui	a4,0x2000
    or	a4,a3,a4
    sw	a4,32(a5) # d0000020 <__CORE1_STACK_TOP+0xaffff010>
    lui	a5,0x40028
    lw	a4,204(a5) # 400280cc <__CORE1_STACK_TOP+0x200270bc>
    andi	a4,a4,-32
    ori	a4,a4,5
    sw	a4,204(a5)
    lui	a5,0xd0000
    lw	a3,56(a5) # d0000038 <__CORE1_STACK_TOP+0xaffff028>
    lui	a5,0xd0000
    lui	a4,0x2000
    or	a4,a3,a4
    sw	a4,56(a5) # d0000038 <__CORE1_STACK_TOP+0xaffff028>
    lui	a5,0x40038
    lw	a4,104(a5) # 40038068 <__CORE1_STACK_TOP+0x20037058>
    andi	a4,a4,-257
    sw	a4,104(a5)

    #-- AQUI PUTO LLEGA ESTABLE!!

    li	a5,128
    csrs	mie,a5
    csrsi	mstatus,8
    lui	a5,0xd0000
    lw	a4,420(a5) # d00001a4 <__CORE1_STACK_TOP+0xaffff194>
    ori	a4,a4,2
    sw	a4,420(a5)

    #-- PUTO-LLEGA ESTABLE!

    #-- Generar excepcion!
    #li t0, 1
    #lw t1, 0(t0)

    ecall

    # lui	a5,0x20000
    # lw	a5,4(a5) # 20000004 <pMTIME>
    # lw	a4,0(a5)
    # lw	a5,4(a5)
    # lui	a3,0x20000
    # lw	a6,0(a3) # 20000000 <pMTIMECMP>
    # lui	a0,0x8f0d
    # addi	a0,a0,384 # 8f0d180 <__STACK_SIZE_CORE0+0x8f0c980>
    # li	a1,0
    # add	a2,a4,a0
    # mv	a7,a2
    # sltu	a7,a7,a4
    # add	a3,a5,a1
    # add	a5,a7,a3
    # mv	a3,a5
    # mv	a4,a2
    # mv	a5,a3
    # sw	a4,0(a6)
    # sw	a5,4(a6)

    #jal led_init
    #jal led_blinky4

    #-- Aqui llega, pero al dar al reset ya no funciona
    jal led_init
    jal led_on
    j .

    #--- DEBUG
    li t0, GPIO_OUT
    li t1, BIT25    #-- Activar el bit 25
    sw t1, 0(t0)
    j .




Startup_InitCore:
    lui a5,0x40018
    lw a3,4(a5) # 40018004 <__CORE1_STACK_TOP+0x20016ff4>
    lui a4,0x1000
    or a4,a3,a4
    sw a4,4(a5)
    nop

L10000508:
    lui a5,0x40018
    lw a5,12(a5) # 4001800c <__CORE1_STACK_TOP+0x20016ffc>
    srli a5,a5,0x18
    andi a5,a5,1
    zext.b a4,a5
    li a5,1
    beq a4,a5,L10000508 # <RP2350_InitCore+0x18>

    lui a5,0x40018
    lw a3,4(a5) # 40018004 <__CORE1_STACK_TOP+0x20016ff4>
    lui a4,0xff000
    addi a4,a4,-1 # feffffff <__CORE1_STACK_TOP+0xdeffefef>
    and a4,a3,a4
    sw a4,4(a5)
    nop

L10000540:
    lui a5,0x40018
    lw a5,12(a5) # 4001800c <__CORE1_STACK_TOP+0x20016ffc>
    srli a5,a5,0x18
    andi a5,a5,1
    zext.b a4,a5
    li a5,1
    bne a4,a5,L10000540 # <RP2350_InitCore+0x50>

    lui a5,0x40020
    lw a4,0(a5) # 40020000 <__CORE1_STACK_TOP+0x2001eff0>
    ori a4,a4,64
    sw a4,0(a5)
    lui a5,0x40020
    lw a4,0(a5) # 40020000 <__CORE1_STACK_TOP+0x2001eff0>
    ori a4,a4,512
    sw a4,0(a5)
    nop

L10000580:
    lui a5,0x40020
    lw a5,8(a5) # 40020008 <__CORE1_STACK_TOP+0x2001eff8>
    srli a5,a5,0x6
    andi a5,a5,1
    zext.b a4,a5
    li a5,1
    beq a4,a5,L10000580  # <RP2350_InitCore+0x90>
    lui a5,0x40020
    lw a5,8(a5) # 40020008 <__CORE1_STACK_TOP+0x2001eff8>
    srli a5,a5,0x9
    andi a5,a5,1
    zext.b a4,a5
    li a5,1
    beq a4,a5,L10000580 #  <RP2350_InitCore+0x90>

    lui a5,0x40020
    lw a4,0(a5) # 40020000 <__CORE1_STACK_TOP+0x2001eff0>
    andi a4,a4,-65
    sw a4,0(a5)
    lui a5,0x40020
    lw a4,0(a5) # 40020000 <__CORE1_STACK_TOP+0x2001eff0>
    andi a4,a4,-513
    sw a4,0(a5)
    nop

L100005DC:
    lui a5,0x40020
    lw a5,8(a5) # 40020008 <__CORE1_STACK_TOP+0x2001eff8>
    srli a5,a5,0x6
    andi a5,a5,1
    zext.b a5,a5
    beqz a5, L100005DC # <RP2350_InitCore+0xec>
    lui a5,0x40020
    lw a5,8(a5) # 40020008 <__CORE1_STACK_TOP+0x2001eff8>
    srli a5,a5,0x9
    andi a5,a5,1
    zext.b a5,a5
    beqz a5, L100005DC # <RP2350_InitCore+0xec>
    nop
    nop
    ret


Startup_InitSystemClock:
FUNC_START4
# 100001f0 <RP2350_ClockInit>:

   



    lui	a5,0x40048
    lw	a3,12(a5) # 4004800c <__CORE1_STACK_TOP+0x20046ffc>
    lui	a4,0xfff00
    addi	a4,a4,-1 # ffefffff <__CORE1_STACK_TOP+0xdfefefef>
    and	a4,a3,a4
    sw	a4,12(a5)

    #-- PUTO ESTABLE

    lui	a5,0x40048
    lw	a3,12(a5) # 4004800c <__CORE1_STACK_TOP+0x20046ffc>
    lui	a4,0xffffc
    and	a4,a3,a4
    ori	a4,a4,47
    sw	a4,12(a5)

    #-- PUTO ESTABLE

    lui	a5,0x40048
    lw	a5,4(a5) # 40048004 <__CORE1_STACK_TOP+0x20046ff4>
    andi	a5,a5,3
    zext.b	a4,a5
    lui	a5,0x40048
    mv	a3,a4
    lui	a4,0x1
    addi	a4,a4,-1 # fff <__STACK_SIZE_CORE0+0x7ff>
    and	a4,a3,a4
    slli	a3,a4,0x10
    srli	a3,a3,0x10
    lui	a4,0x1
    addi	a4,a4,-1 # fff <__STACK_SIZE_CORE0+0x7ff>
    and	a4,a3,a4
    lw	a2,0(a5) # 40048000 <__CORE1_STACK_TOP+0x20046ff0>
    lui	a3,0xfffff
    and	a3,a2,a3
    or	a4,a3,a4
    sw	a4,0(a5)

    #-- PUTO ESTABLE

    lui	a5,0x40048
    lw	a3,0(a5) # 40048000 <__CORE1_STACK_TOP+0x20046ff0>
    lui	a4,0xff001
    addi	a4,a4,-1 # ff000fff <__CORE1_STACK_TOP+0xdeffffef>
    and	a3,a3,a4
    lui	a4,0xfab
    or	a4,a3,a4
    sw	a4,0(a5)
    nop

    #-- PUTO ESTABLE
L10000290:
    lui	a5,0x40048
    lw	a5,4(a5) # 40048004 <__CORE1_STACK_TOP+0x20046ff4>
    srli	a5,a5,0x1f
    zext.b	a4,a5
    li	a5,1
    bne	a4,a5,L10000290 #  <RP2350_ClockInit+0xa0>

   

    #--- PUTO ESTABLE

    #li a5,0x40010000
    li t0, CLK_REF_CTRL
    #lw	a4,0x30(a5) # 40010030 <__CORE1_STACK_TOP+0x2000f020>
    lw  a4,0(t0)
    andi	a4,a4,-4 #-- FFFF_FFFC  Poner SRC a 00: ROSC_CLKSRC_PH
    ori	a4,a4,2 #-- 02 -> clk_REF_CTRL.SRC = 02 (XOSC_CLKSRC)
    #sw	a4,0x30(a5)
    li a4, 2
    #-- Condicion 1
    #sw a4, 0(t0)  #-- NO CONFIGURAMOS ESTO de momento...
    nop

    #--- Aquí ya NO ES PUTO ESTABLE. A veces va y otra no....

# L100002c0:
#     lui	a5,0x40010
#     lw	a4,56(a5) # 40010038 <__CORE1_STACK_TOP+0x2000f028>
#     li	a5,4
#     bne	a4,a5,L100002c0 # <RP2350_ClockInit+0xd0>
#     nop


L100002d4:
    lui	a5,0x40010
    lbu	a5,54(a5) # 40010036 <__CORE1_STACK_TOP+0x2000f026>
    zext.b	a4,a5
    li	a5,1
    bne	a4,a5,L100002d4 # <RP2350_ClockInit+0xe4>

    lui	a5,0x40020
    lw	a3,0(a5) # 40020000 <__CORE1_STACK_TOP+0x2001eff0>
    lui	a4,0xffffc
    addi	a4,a4,-1 # ffffbfff <__CORE1_STACK_TOP+0xdfffafef>
    and	a4,a3,a4
    sw	a4,0(a5)
    nop

    #-- PUTO LLEGA ESTABLE (condicion 1)

L10000304:
    lui	a5,0x40020
    lw	a5,8(a5) # 40020008 <__CORE1_STACK_TOP+0x2001eff8>
    srli	a5,a5,0xe
    andi	a5,a5,1
    zext.b	a4,a5
    li	a5,1
    bne	a4,a5,L10000304 # <RP2350_ClockInit+0x114>


    #-- PUTO LLEGA ESTABLE (Condicion 1)

    #-- Aquí llega...

    lui	a5,0x40050
    lw	a4,0(a5) # 40050000 <__CORE1_STACK_TOP+0x2004eff0>
    andi	a4,a4,-64
    ori	a4,a4,1
    sw	a4,0(a5)

    #-- PUTO LLEGA ESTABLE (Condicion 1)

    #-- Aqui llega

    lui	a5,0x40050
    lw	a3,8(a5) # 40050008 <__CORE1_STACK_TOP+0x2004eff8>
    lui	a4,0xfffff
    and	a4,a3,a4
    ori	a4,a4,125
    sw	a4,8(a5)

     #-- Aqui llega

    #-- PUTO LLEGA ESTABLE (Condicion 1)

    #-- PLL_SYS_PRIM
    li a5, PLL_SYS_PRIM
    lw a3, 0(a5)
    lui	a4,0xfff90
    addi	a4,a4,-1 # fff8ffff <__CORE1_STACK_TOP+0xdff8efef>
    and	a3,a3,a4
    lui	a4,0x50
    or	a4,a3,a4
    sw	a4,0(a5)

    #-- PUTO LLEGA ESTABLE!

    lui	a5,0x40050
    lw	a3,12(a5) # 4005000c <__CORE1_STACK_TOP+0x2004effc>
    lui	a4,0xffff9
    addi	a4,a4,-1 # ffff8fff <__CORE1_STACK_TOP+0xdfff7fef>
    and	a3,a3,a4
    lui	a4,0x2
    or	a4,a3,a4
    sw	a4,12(a5)
    lui	a5,0x40050
    lw	a4,4(a5) # 40050004 <__CORE1_STACK_TOP+0x2004eff4>
    andi	a4,a4,-2
    sw	a4,4(a5)
    lui	a5,0x40050
    lw	a4,4(a5) # 40050004 <__CORE1_STACK_TOP+0x2004eff4>
    andi	a4,a4,-33
    sw	a4,4(a5)
    lui	a5,0x40050
    lw	a4,4(a5) # 40050004 <__CORE1_STACK_TOP+0x2004eff4>
    andi	a4,a4,-9
    sw	a4,4(a5)
    nop

    #-- PUTO LLEGA ESTABLE (Condicion 1)


L100003c0:
    lui	a5,0x40050
    lw	a5,0(a5) # 40050000 <__CORE1_STACK_TOP+0x2004eff0>
    srli	a5,a5,0x1f
    zext.b	a4,a5
    li	a5,1
    bne	a4,a5,L100003c0 # <RP2350_ClockInit+0x1d0>

     #-- PUTO LLEGA ESTABLE (Condicion 1)

 
    lui	a5,0x40010
    lw	a4,64(a5) # 40010040 <__CORE1_STACK_TOP+0x2000f030>
    lui	a5,0x10

L100003e4:
    #beq a4,a5,L100003e4 ## 100003e4:	/-- 00f70863
    lui a5,0x40010      ## 100003e8:	|   400107b7
    lui a4,0x10         ## 100003ec:	|   00010737
    sw a4,64(a5)        ## 100003f0:	|   04e7a023

    #-- AQUI LLEGA PUTO-ESTABLE CONDICION 1

    lui a5,0x40010      ## 100003f4:	\-> 400107b7
    lw	a4,60(a5) # 4001003c <__CORE1_STACK_TOP+0x2000f02c>
    andi	a4,a4,-225
    sw	a4,60(a5)

    #-- AQUI LLEGA PUTO-ESTABLE (Condicion 1)
    #-- PUNTO CRITICO 2

    #-- CLK_SYS_CTRL
    li a5,0x40010000
    lw	a4,0x3c(a5) # 4001003c <__CORE1_STACK_TOP+0x2000f02c>
    ori	a4,a4,1   #-- Se selecciona CLK_SYS_AUX como auxiliar

    #li a4, 1
    sw	a4,0x3C(a5)
    nop

    #--- LA VELOCIDAD AUMENTA MUCHO!!!!
    #-- AQUI LLEGA PUTO-ESTABLE (Con CONDICION 1)

    #-- Aquí llega..

L10000418:
    lui	a5,0x40010
    lw	a5,68(a5) # 40010044 <__CORE1_STACK_TOP+0x2000f034>
    andi	a5,a5,3
    zext.b	a4,a5
    li	a5,2
    bne	a4,a5,L10000418 # <RP2350_ClockInit+0x228>

    #-- Aqui llega PUTO-ESTABLE

    lui	a5,0x40010
    lw	a3,72(a5) # 40010048 <__CORE1_STACK_TOP+0x2000f038>
    lui	a4,0x1
    addi	a4,a4,-2048 # 800 <__STACK_SIZE_CORE0>
    or	a4,a3,a4
    sw	a4,72(a5)
    lui	a5,0x40020
    lw	a4,0(a5) # 40020000 <__CORE1_STACK_TOP+0x2001eff0>
    andi	a4,a4,-65
    sw	a4,0(a5)
    nop

L1000045c:
    lui	a5,0x40020
    lw	a5,8(a5) # 40020008 <__CORE1_STACK_TOP+0x2001eff8>
    srli	a5,a5,0x6
    andi	a5,a5,1
    zext.b	a4,a5
    li	a5,1
    bne	a4,a5,L1000045c # <RP2350_ClockInit+0x26c>

    #-- Aqui llega PUTO-ESTABLE!

    nop
    nop
    FUNC_END4
    ret

# -----------------------------------------------
# -- Delay
# -- Realizar una pausa de medio segundo aprox.
# -----------------------------------------------
delay:
    # -- Usar t0 como contador descendente
    li t0, 0xFFFFF
delay_loop:
    beq t0,zero, delay_end_loop
    addi t0, t0, -1
    j delay_loop

    # -- Cuando el contador llega a cero
    # -- se termina
delay_end_loop:
    ret



Startup_InitRam:
# 100008b4 <Startup_InitRam>:
    addi sp,sp,-16
    sw zero,12(sp)
    sw zero,8(sp)

L100008c0:
    j	L10000928 # <Startup_InitRam+0x74>
L100008c4:
    sw	zero,4(sp)
    j	L100008fc # <Startup_InitRam+0x48>
L100008cc:
    lw	a5,12(sp)
    slli	a4,a5,0x3
    lui	a5,0x10001
    addi	a5,a5,-512 # 10000e00 <__RUNTIME_CLEAR_TABLE>
    add	a5,a4,a5
    lw	a4,0(a5)
    lw	a5,4(sp)
    add	a5,a4,a5
    sb	zero,0(a5)
    lw	a5,4(sp)
    addi	a5,a5,1
    sw	a5,4(sp)

L100008fc:
    lw	a5,12(sp)
    slli	a4,a5,0x3
    lui	a5,0x10001
    addi	a5,a5,-512 # 10000e00 <__RUNTIME_CLEAR_TABLE>
    add	a5,a4,a5
    lw	a5,4(a5)
    lw	a4,4(sp)
    bltu	a4,a5, L100008cc #<Startup_InitRam+0x18>


    lw	a5,12(sp)
    addi	a5,a5,1
    sw	a5,12(sp)

L10000928:
    lw	a5,12(sp)

    slli	a4,a5,0x3
    lui	a5,0x10001
    addi	a5,a5,-512 # 10000e00 <__RUNTIME_CLEAR_TABLE>
    add	a5,a4,a5
    lw	a4,0(a5)
    li	a5,-1

    beq	a4,a5,L10000a30 # <Startup_InitRam+0x17c>
    lw	a5,12(sp)
    slli	a4,a5,0x3
    lui	a5,0x10001
    addi	a5,a5,-512 # 10000e00 <__RUNTIME_CLEAR_TABLE>
    add	a5,a4,a5
    lw	a4,4(a5)
    li	a5,-1

    bne	a4,a5,L100008c4 
    j	L10000a30 # <Startup_InitRam+0x17c>

L1000096c:
    sw	zero,0(sp)
    j	L100009f4 # <Startup_InitRam+0x140>

L10000974:
    lw	a4,8(sp)
    mv	a5,a4
    slli	a5,a5,0x1
    add	a5,a5,a4
    slli	a5,a5,0x2
    mv	a4,a5
    lui	a5,0x10001
    addi	a5,a5,-496 # 10000e10 <__RUNTIME_COPY_TABLE>
    add	a5,a4,a5
    lw	a4,0(a5)
    lw	a5,0(sp)
    add	a5,a4,a5
    mv	a3,a5
    lw	a4,8(sp)
    mv	a5,a4
    slli	a5,a5,0x1
    add	a5,a5,a4
    slli	a5,a5,0x2
    mv	a4,a5
    lui	a5,0x10001
    addi	a5,a5,-496 # 10000e10 <__RUNTIME_COPY_TABLE>
    add	a5,a4,a5
    lw	a4,4(a5)
    lw	a5,0(sp)
    add	a5,a4,a5
    mv	a4,a5
    lbu	a5,0(a3)
    zext.b	a5,a5
    sb	a5,0(a4)
    lw	a5,0(sp)
    addi	a5,a5,1
    sw	a5,0(sp)

L100009f4:
    lw	a4,8(sp)
    mv	a5,a4
    slli	a5,a5,0x1
    add	a5,a5,a4
    slli	a5,a5,0x2
    mv	a4,a5
    lui	a5,0x10001
    addi	a5,a5,-496 # 10000e10 <__RUNTIME_COPY_TABLE>
    add	a5,a4,a5
    lw	a5,8(a5)
    lw	a4,0(sp)
    bltu a4,a5, L10000974 # <Startup_InitRam+0xc0>
    lw	a5,8(sp)
    addi	a5,a5,1
    sw	a5,8(sp)

L10000a30:
    lw	a4,8(sp)
    mv	a5,a4
    slli	a5,a5,0x1
    add	a5,a5,a4
    slli	a5,a5,0x2
    mv	a4,a5
    lui	a5,0x10001
    addi	a5,a5,-496 # 10000e10 <__RUNTIME_COPY_TABLE>
    add	a5,a4,a5
    lw	a4,0(a5)
    li	a5,-1

    beq	a4,a5,L10000ac0 #<Startup_InitRam+0x20c>
    lw	a4,8(sp)
    mv	a5,a4
    slli	a5,a5,0x1
    add	a5,a5,a4
    slli	a5,a5,0x2
    mv	a4,a5
    lui	a5,0x10001
    addi	a5,a5,-496 # 10000e10 <__RUNTIME_COPY_TABLE>
    add	a5,a4,a5
    lw	a4,4(a5)
    li	a5,-1
    beq	a4,a5,L10000ac0 # <Startup_InitRam+0x20c>
    lw	a4,8(sp)
    mv	a5,a4
    slli	a5,a5,0x1
    add	a5,a5,a4
    slli	a5,a5,0x2
    mv	a4,a5
    lui	a5,0x10001
    addi	a5,a5,-496 # 10000e10 <__RUNTIME_COPY_TABLE>
    add	a5,a4,a5
    lw	a4,8(a5)
    li	a5,-1
    bne	a4,a5, L1000096c # <Startup_InitRam+0xb8>

L10000ac0:
    nop
    addi	sp,sp,16
    ret


Startup_InitCtors:
# 10000acc <Startup_InitCtors>:
    addi	sp,sp,-32
    sw	ra,28(sp)
    sw	zero,12(sp)
    j	L10000b00 # <Startup_InitCtors+0x34>

L10000adc:
    lw	a5,12(sp)
    addi	a4,a5,1
    sw	a4,12(sp)
    slli	a4,a5,0x2
    lui	a5,0x10001
    addi	a5,a5,-520 # 10000df8 <__CPPCTOR_LIST__>
    add	a5,a4,a5
    lw	a5,0(a5)
    jalr	a5

L10000b00:
    lw	a5,12(sp)
    slli	a4,a5,0x2
    lui	a5,0x10001
    addi	a5,a5,-520 # 10000df8 <__CPPCTOR_LIST__>
    add	a5,a4,a5
    lw	a4,0(a5)
    li	a5,-1
    bne	a4,a5, L10000adc # <Startup_InitCtors+0x10>

    nop
    nop
    lw	ra,28(sp)
    addi	sp,sp,32
    ret


Isr_MachineTimerInterrupt:
# 1000013c <Isr_MachineTimerInterrupt>:

    addi	sp,sp,-32
    sw	a0,28(sp)
    sw	a1,24(sp)
    sw	a2,20(sp)
    sw	a3,16(sp)
    sw	a4,12(sp)
    sw	a5,8(sp)
    sw	a6,4(sp)
    sw	a7,0(sp)
    lui	a5,0x20000
    lw	a5,4(a5) # 20000004 <pMTIME>
    lw	a4,0(a5)
    lw	a5,4(a5)
    lui	a3,0x20000
    lw	a6,0(a3) # 20000000 <pMTIMECMP>
    lui	a0,0x8f0d
    addi	a0,a0,384 # 8f0d180 <__STACK_SIZE_CORE0+0x8f0c980>
    li	a1,0
    add	a2,a4,a0
    mv	a7,a2
    sltu	a7,a7,a4
    add	a3,a5,a1
    add	a5,a7,a3
    mv	a3,a5
    mv	a4,a2
    mv	a5,a3
    sw	a4,0(a6)
    sw	a5,4(a6)
    lui	a5,0xd0000
    lw	a3,40(a5) # d0000028 <__CORE1_STACK_TOP+0xaffff018>
    lui	a5,0xd0000
    lui	a4,0x2000
    or	a4,a3,a4
    sw	a4,40(a5) # d0000028 <__CORE1_STACK_TOP+0xaffff018>
    nop
    lw	a0,28(sp)
    lw	a1,24(sp)
    lw	a2,20(sp)
    lw	a3,16(sp)
    lw	a4,12(sp)
    lw	a5,8(sp)
    lw	a6,4(sp)
    lw	a7,0(sp)
    addi	sp,sp,32
    mret

#------------------------------
#-- Rutinas de interrupcion
#------------------------------
Isr_UndefinedHandler: 
    j Isr_UndefinedHandler

AllExceptionsHandler: 
    j AllExceptionsHandler

Isr_MachineSoftwareInterrupt:
    j .

Isr_MachineExternalInterrupt:
    j .


isr_led:
    jal led_init
    jal led_blinky3

isr_led2:
    jal led_init
    jal led_blinky4

