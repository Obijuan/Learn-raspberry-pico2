 # ----------------------------------------------
 # -- Envío de un carácter por la UART
 # ----------------------------------------------

.include "boot.h"
.include "gpio.h"

.equ CLOCK_BASE,         0x40010000

.equ CLOCK_REF_CTRL,     0x40010030
  .equ CLK_REF_CTRL_XOR, 0x40011030
  .equ CLK_REF_CTRL_CLR, 0x40013030
.equ CLK_REF_DIV,        0x40013034 

.equ CLK_SYS_CTRL,       0x4001003C
  .equ CLK_SYS_CTRL_CLR, 0x4001303C
.equ CLK_SYS_SELECTED,   0x40010044
.equ CLK_SYS_RESUS_CTRL, 0x40010084
.equ CLK_REF_SELECTED,   0x40010038


# -----------------------------------
# -- Registro de Control del Reset 
# -----------------------------------
# https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf#tab-registerlist_resets
# 
# * Bit 26: UART0
# -----------------------------------
.equ RESET_CTRL,     0x40020000
  .equ RESET_CTRL_XOR, 0x40021000
  .equ RESET_CTRL_SET, 0x40022000
  .equ RESET_CTRL_CLR, 0x40023000

# --- Valor del registro de reset
.equ RESET_UART0,   BIT26
.equ RESET_PLL_SYS, BIT14
.equ RESET_PLL_USB, BIT15

# -----------------------------------
# -- Registro de Status del reset
# -- Pone a 1 el bit correspondiente
# -- cuando el periférico se ha reseteado 
# -----------------------------------
.equ RESET_DONE, 0x40020008

.equ SRAM_BASE,             0x20000000
.equ UART0_BASE,            0x40070000

#-- Registro de datos de la uart
.equ UART0_UARTDR,          0x40070000

#-- Registro flags de la UART
.equ UART0_UARTF,           0x40070018

  #-- Transmisor ocupado
  .equ TXFF, 0x20

.equ UART0_UARTIBRD,        0x40070024
.equ UART0_UARTFBRD,        0x40070028
.equ UART0_UARTLCR_H,       0x4007002C
  .equ UART0_UARTLCR_H_XOR, 0x4007102C
.equ UART0_UARTCR,          0x40070030 
.equ UART0_UARTDMACR,       0x40070048

.equ UART1_BASE,     0x40078000

#-- Crystal oscillator
.equ XOSC_BASE,    0x40048000
.equ XOSC_CTRL,    0x40048000
  .equ XOSC_CTRL_SET,0x4004A000

.equ XOSC_STATUS,  0x40048004
.equ XOSC_STARTUP, 0x4004800C

.equ PLL_SYS_BASE,      0x40050000 
.equ PLL_SYS_CR,        0x40050000
.equ PLL_SYS_PWR,       0x40050004
  .equ PLL_SYS_PWR_CLR, 0x40053004
.equ PLL_SYS_FBDIV_INT, 0x40050008
.equ PLL_SYS_PRIM,      0x4005000C

.equ PLL_USB_BASE,      0x40058000
.equ PLL_USB_CR,        0x40058000
.equ PLL_USB_PWR,       0x40058004
  .equ PLL_USB_PWR_CLR, 0x4005B004
.equ PLL_USB_FBDIV_INT, 0x40058008
.equ PLL_USB_PRIM,      0x4005800C



.equ USBCTRL_REGS_BASE, 0x50110000
.equ USB_SIE_CTRL,      0x5011004c
.equ USB_SIE_CTRL_SET,  0x5011204c


.section .text

# -- Punto de entrada
.global _start
_start:

    #-- Inicializar la pila
    la sp, _stack_top

    li s0,0x10001000 #-- XIP BASE + 0x1000
    jal	runtime_run_initializers

    #-- Configurar el LED
    jal led_init  

    #-- Inicializar la UART
    jal uart_init 

    #-- DEBUG
    #jal button_init15
    #jal debug_led1_lsb

main_loop:

    #-- Esperar a que el transmisor esté listo
wait_tx:
    li t0, UART0_UARTF
    lw t1, 0(t0)  
    andi t1,t1,TXFF

    #-- ¿Bit TXFF==1? (Ocupado), esperar
    bne t1, zero, wait_tx

    #-- Transmitir!
    li t0,UART0_UARTDR
    li t1,'A'
    sw t1,0(t0)

    #-- Esperar!
    jal delay
    jal led_toggle
    j main_loop

#--------------------------------
#-- Inicializar la UART
#---------------------------------
uart_init:

    #-- Activar reset de la uart0
    li t0,RESET_CTRL_SET  
    li t1,RESET_UART0
    sw t1,0(t0)

    #-- Desactivar el reset de la uart0
    li t0,RESET_CTRL_CLR
    sw t1,0(t0)

    #-- Esperar hasta que el reset termine
    li t0, RESET_DONE   #-- Registro de reset
    li t1, RESET_UART0  #-- Bit de reset de la uart0

wait_reset_done:
    lw t2,0(t0)      #-- Leer estado del reset
    and t2, t2, t1   #-- Aislar el bit de reset de la uart

    #-- Bit RESET_UART0 == 0? --> Esperar
    beq t2, zero, wait_reset_done

    #-- El bit RESET_UART0 del registro RESET_DONE está a 1
    #-- Significa que la UART0 está inicializada

    #-- Parte entera de los baudios (Integer Baudrate)
    li t0, UART0_UARTIBRD
    li t1, 0x51
    sw t1, 0(t0)

    #-- Parte fraccional de los baudios (Fractional baudrate)
    li t0, UART0_UARTFBRD
    li t1, 0x18
    sw t1, 0(t0) 

    #-- Configurar UART
    #-- 8bits de datos. Sin paridad
    li t0, UART0_UARTLCR_H
    li t1, 0xE0
    sw t1,0(t0)

    #-- Habilitar la UART
    #-- Habilitar transmisor
    #-- Habilitar receptor
    li t0, UART0_UARTCR
    li t1,0x301
    sw t1,0(t0)

    #--------- Configurar pin TX UART0
    #-- Configurar el PAD del GPIO0
    li t0, PAD_GPIO0
    li t1, 0x56
    sw t1,0(t0)

    #-- Asignar el GPIO0 al pin tx de la UART0
    li t0,GPIO00_CTRL
    li t1, 2
    sw t1,0(t0)
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


#-----------------------------------


runtime_run_initializers:
    addi	sp,sp,-16
    sw	s0,8(sp)
    sw	s1,4(sp)
    sw	ra,12(sp)

    li s0,0x10001000
    li s1,0x10001000

    #-- a5 = 0x10001574    
    addi a5,s0,0x574 # 10001574 <__pre_init_runtime_init_bootrom_reset>

    #-- s1 = 0x100015ac
    addi s1,s1,0x5ac # 100015ac <__frame_dummy_init_array_entry>

    #-- s0 = 0x10001574
    addi s0,s0,0x574

    #-- Inicializaciones!!
    jal runtime_init_clocks
    jal runtime_init_post_clock_resets

    lw ra,12(sp)
    lw s0,8(sp)
    lw s1,4(sp)
    addi sp,sp,16
    ret


runtime_init_clocks:
    addi sp,sp,-16
    sw ra,12(sp)
    sw s0,8(sp)
    sw s1,4(sp)
    sw s2,0(sp)

    li s0, CLOCK_BASE

    #-- Inicializar RESUS
    li t0, CLK_SYS_RESUS_CTRL
    sw	zero,0(t0)

    #-- Inicializar oscilador externo
    jal	xosc_init

    #-- Seleccionar CLK-REF
    li t0, CLK_SYS_CTRL_CLR 
    li t1,1
    sw t1,0(t0)

    #-- Esperar a que se realice la selección de reloj
wait_selected:
    li t0, CLK_SYS_SELECTED
    lw	t1,0(t0)
    li t2,1
    bne	t1,t2, wait_selected

    #-- Configurara CLK_REF. Fuente: Ring-oscillator
    li t0, CLK_REF_CTRL_CLR
    li t1, 3
    sw t1, 0(t0)

    #li a4,3
    #li a5,0x40013000 #-- CLOCK_BASE + 0x3000
    #sw	a4,0x30(a5)  #-- CLK_REF_CTRL

    #-- Esperar a que se finalice la seleccion
wait_clk_ref_selected:
    li t0, CLK_REF_SELECTED
    lw t1, 0(t0)
    li t2,1
    bne t1,t2, wait_clk_ref_selected

    jal pll_sys_init
    jal	pll_usb_init 

    li s0,1
    li a3, 0xB71B00
    li a2,0
    li a1,2
    li a0,4
    jal	clock_configure_undivided_ # 10000dc4 <clock_configure_undivided>

    lui	a3,0x8f0d
    mv	a1,s0
    addi a3,a3,384 # 8f0d180 <HeapSize+0x8f0c980>
    li a2,0
    li a0,5
    #-- Comentada... la segunda pasada peta :-(
    #jal	clock_configure_undivided # 10000dc4 <clock_configure_undivided>

    lui	a3,0x2dc7
    addi	a3,a3,-1024 # 2dc6c00 <HeapSize+0x2dc6400>
    li	a2,0
    li	a1,0
    li	a0,8
    jal	clock_configure_undivided # 10000dc4 <clock_configure_undivided>

    lui	a3,0x2dc7
    addi	a3,a3,-1024 # 2dc6c00 <HeapSize+0x2dc6400>
    li	a2,0
    li	a1,0
    li	a0,9
    jal	clock_configure_undivided # 10000dc4 <clock_configure_undivided>

    lui	a3,0x8f0d
    addi	a3,a3,384 # 8f0d180 <HeapSize+0x8f0c980>
    li	a2,0
    li	a1,0
    li	a0,6
    jal	clock_configure_undivided # 10000dc4 <clock_configure_undivided>

    lui	a3,0x8f0d
    addi a3,a3,384 # 8f0d180 <HeapSize+0x8f0c980>
    li	a2,0
    li	a1,0
    li	a0,7
    jal	clock_configure_undivided  # 10000dc4 <clock_configure_undivided>

    li	a0,4
    jal	clock_get_hz  # 10000e98 <clock_get_hz>

    lui	a5,0x431be
    addi a5,a5,-381 # 431bde83 <__StackTop+0x2313be83>
    mulhu s1,a0,a5
    li s0,0
    li s2,6
    srli s1,s1,0x12

label_rt_7:
    mv	a0,s0
    mv	a1,s1
    addi s0,s0,1
    jal	tick_start  # 10000f32 <tick_start>
    bne s0,s2,label_rt_7  # 10001152 <runtime_init_clocks+0xd4>

runtime_init_clocks_end:
    lw ra,12(sp)
    lw s0,8(sp)
    lw s1,4(sp)
    lw s2,0(sp)
    addi sp,sp,16
    ret



xosc_init:
    #-- Rango de frecuencias: 1Mhz - 15Mhz
    li a5, 0xaa0
    li a4,XOSC_CTRL
    sw a5,0(a4)

    #-- Empezar una cuenta atrás de 282 ciclos
    li a4, XOSC_STARTUP
    li a5,282 
    sw a5,0(a4)

    #-- HABILITAR el oscilador!
    li a5, XOSC_CTRL_SET
    li a3,0x00fab000
    sw a3,0(a5)

    #-- Esperar hasta que se estabilice el oscilador externo
xosc_init_loop:
    li a4, XOSC_STATUS
    lw a5,0(a4) 
    bgez a5, xosc_init_loop  # 10000fa0 <xosc_init+0x1c>

    ret


pll_sys_init:

    #--- Reset del PLL_SYS
    li t0, RESET_CTRL_SET
    li t1, RESET_PLL_SYS
    sw t1, 0(t0)

    #-- Desactivar reset PLL_SYS
    li t0, RESET_CTRL_CLR
    sw t1, 0(t0)

    #--- Esperar a que se termine el reset
    li t0, RESET_DONE
wait_pll_sys_reset_:
    lw t1, 0(t0)
    li t2, RESET_PLL_SYS
    and t1,t2,t1
    beq t1, zero, wait_pll_sys_reset_  

    li t0, PLL_SYS_CR
    li t1, 1  #-- sin division la señal de entrada
    sw t1,0(t0)

    li t0, PLL_SYS_FBDIV_INT
    li t1, 0x7D
    sw t1, 0(t0)

    li t0, PLL_SYS_PWR_CLR
    li t1, 0x21
    sw t1, 0(t0)

    #-- Esperar a que el PLL se estabilice
    li t0, PLL_SYS_CR
wait_pll_sys_lock_:
    lw t1,0(t0)
    bge t1,zero, wait_pll_sys_lock_  

    li t0, PLL_SYS_PRIM
    #-- PostDiv1: 5
    #-- PostDiv2: 4
    li t1, 0x52000
    sw t1, 0(t0)

    li t0, PLL_SYS_PWR_CLR
    li t1, 0x8
    sw t1, 0(t0)
    ret


pll_usb_init:

    #--- Reset del PLL
    li t0, RESET_CTRL_SET
    li t1, RESET_PLL_USB
    sw t1, 0(t0)

    #-- Desactivar reset PLL
    li t0, RESET_CTRL_CLR
    sw t1, 0(t0)

   #--- Esperar a que se termine el reset
    li t0, RESET_DONE
wait_pll_usb_reset:
    lw t1, 0(t0)
    li t2, RESET_PLL_USB
    and t1,t2,t1
    beq t1, zero, wait_pll_usb_reset  

    li t0, PLL_USB_CR
    li t1, 1  #-- sin division la señal de entrada
    sw t1,0(t0)

    li t0, PLL_USB_FBDIV_INT
    li t1, 0x7D
    sw t1, 0(t0)

    li t0, PLL_USB_PWR_CLR
    li t1, 0x21
    sw t1, 0(t0)

    #-- Esperar a que el PLL se estabilice
    li t0, PLL_USB_CR
wait_pll_usb_lock:
    lw t1,0(t0)
    bge t1, zero, wait_pll_usb_lock  

    li t0, PLL_USB_PRIM
    #-- PostDiv1: 5
    #-- PostDiv2: 4
    li t1, 0x52000
    sw t1, 0(t0)

    li t0, PLL_USB_PWR_CLR
    li t1, 0x8
    sw t1, 0(t0)
    ret



clock_configure_undivided_:

    addi sp,sp,-16
    sw ra, 12(sp)

    li s0,1
    li a3, 0xB71B00
    li a2,0
    li a1,2
    li a0,4

    li t0, CLK_REF_DIV
    lw a6, 0(t0)

    #-- Divisor: 1
    li a5,0x10000
    sw a5, 0(t0)

    li a5, CLK_REF_CTRL_CLR
    li t3, 0x0B
    sw t3, 0(a5)

    #slli a0,a0,0x2
    li a0, 16
    li a4, CLOCK_REF_CTRL

    lw a7,0(a4)

    li a5, CLK_REF_CTRL_XOR
    sw a2, 0(a5)

    j clock_configure_undivided_label5_

    #-- POR AQUI NO PASA

clock_configure_undivided_label9_:
# 10000e22:	
    lui a5,0x2
    add	a5,a5,a4
    bseti a2,zero,0xb
    sw	a2,0(a5)
    add	a0,a0,t1
    lui	a5,0x10
    sw	a3,0(a0)
    sw	a5,4(a4)

    lw ra, 12(sp)
    addi sp,sp,16
    ret

clock_configure_undivided_label5_:

    #-- POR AQUI PASA

# 10000e80:	
    lw a6,0(a4)          #-- Leer registro CLK_SYS_CTRL
    bset	a2,zero,a1   #-- Segunda llamada: a1 = 1, a2 = 1
    xor	a1,a1,a6         #-- Segunda llamada: a1 = 1 xor x6 = 01 xor 11 = 10
    andi	a1,a1,3      #-- Segunda llamada: a1 = 1 and 11 = 1

    #-- AQUI PETA!!!!!!
    sw	a1,0(a5)  #Comentada para que no pete... (¿?)

clock_configure_undivided_label8_:
#-- SE QUEDA EN BUCLE INFINITO!!!
# 10000e90:	
    lw a5,8(a4)   #-- CLK_SYS_SELECTED
    and	a5,a5,a2
    beqz	a5,clock_configure_undivided_label8  # 10000e90 <clock_configure_undivided+0xcc>

    j	clock_configure_undivided_label9  #  10000e22 <clock_configure_undivided+0x5e>











#--- Primera llamada: a0 = 4, a1 = 2, a2=0
#--- Segunda llamada: a0 = 5, a1 = 1, a2=0
clock_configure_undivided:
    li a5,CLOCK_BASE
    sh1add	a4,a0,a0  #-- sh1add rd, rs1, rs2
                      #-- X(rd) = X(rs2) + (X(rs1) << 1);
                      #-- a4 = a0 + a0<<1

    #-- Primera llamada: a4 = 4 + 4<<1 = 12
    #-- Segunda llamda: a4 = 15
    sh2add	a4,a4,a5  #-- a4 = a5 + a4<<2  (X(rd) = X(rs2) + (X(rs1) << 2))
                      #-- Primera llamada: a4 = 0x40010030 (CLK_REF_CTRL)
                      #-- Segunda llamada: a4 = 0x4001003c (CLK_SYS_CTRL)
    lw a6,4(a4) # Se lee registro (CLK_REF_DIV (1ª), CLK_SYS_DIV (2º)
    li a5,0x10000

    bgeu a6,a5,clock_configure_undivided_label1  # 10000ddc <clock_configure_undivided+0x18>
    sw	a5,4(a4)

clock_configure_undivided_label1:
# 10000ddc:	
    addi a6,a0,-4
    li a5,1
    bgeu a5,a6, clock_configure_undivided_label2 # 10000e4e

clock_configure_undivided_label3:
# 10000de6:	

    lui t1,0x20000
    addi t1,t1,1268 # 200004f4 <configured_freq>
    sh2add a5,a0,t1
    lw a7,0(a5) # 10000 <HeapSize+0xf800>
    lui	a5,0x3
    add	a5,a5,a4
    bseti t3,zero,0xb
    sw t3,0(a5) # 3000 <HeapSize+0x2800>
    slli a0,a0,0x2
    bnez a7,clock_configure_undivided_label4 # 10000e36 <clock_configure_undivided+0x72>

clock_configure_undivided_label10:
# 10000e08
    lw a7,0(a4)
    slli a2,a2,0x5
    lui a5,0x1
    xor a2,a2,a7
    andi a2,a2,224
    add a5,a5,a4
    sw a2,0(a5)
    li a2,1
    bgeu a2,a6,clock_configure_undivided_label5  #  10000e80 <clock_configure_undivided+0xbc>

clock_configure_undivided_label9:
# 10000e22:	
    lui a5,0x2
    add	a5,a5,a4
    bseti a2,zero,0xb
    sw	a2,0(a5)
    add	a0,a0,t1
    lui	a5,0x10
    sw	a3,0(a0)
    sw	a5,4(a4)
    ret
clock_configure_undivided_label4:
# 10000e36:	 
    lw a5,20(t1)
    divu a5,a5,a7
    addi a5,a5,1 # 10001 <HeapSize+0xf801>
    sh1add a5,a5,a5

clock_configure_undivided_label6:
# 10000e44:	
    addi a5,a5,-2
    bgez	a5,clock_configure_undivided_label6 # 10000e44 <clock_configure_undivided+0x80>
    j	clock_configure_undivided_label10 # 10000e08 <clock_configure_undivided+0x44>

clock_configure_undivided_label2:
# 10000e4e:
# Segunda llamada: a1 = 1, a5=1, a4 = 0x4001003c (CLK_SYS_CTRL)
    bne	a1,a5,clock_configure_undivided_label3  # 10000de6 <clock_configure_undivided+0x22>

    li  a5,0x3000
    add	a5,a5,a4
    #-- Segunda llamada: a5 = 0x4001003c + 0x3000 = 0x4001303c (CLK_SYS_CTRL_XOR?)

    li	a6,3
    sw	a6,0(a5) # 3000 <HeapSize+0x2800>

clock_configure_undivided_label7:
# 10000e5c:	
    lw a5,8(a4)    #-- Segunda llamada: a4 = 0x4001003c (CLK_SYS_CTRL) Se lee: CLK_SYS_SELECTED
    andi a5,a5,1
    beqz a5,clock_configure_undivided_label7 # 10000e5c <clock_configure_undivided+0x98>

    lw	a6,0(a4)    #-- Segunda llamada: Lectura de (CLK_SYS_CTRL) (DEBUG) --> Seguir por aqui
    slli a2,a2,0x5  #-- Segunda llamada: a2 = 0 + 5 = 5
    li a5,0x1000
    xor	a2,a2,a6    #-- Segunda llamada: a2 = a2 xor a6 = 3
    andi a2,a2,0xe0  #-- Segunda llamada: a2 = 0 
    add	a5,a5,a4     #-- Segunda llamada: CLK_SYS_CTRL + 0x1000
    lui	t1,0x20000
    slli a0,a0,0x2   #-- Segunda llamada: a0 = 5, a0 = 5 << 2 = 20
    sw	a2,0(a5)     #-- Segunda llamada: Escritura en CLK_SYS_CTRL + 0x1000
    addi	t1,t1,1268 # 200004f4 <configured_freq>

clock_configure_undivided_label5:
# 10000e80:	
    lw a6,0(a4)          #-- Leer registro CLK_SYS_CTRL
    bset	a2,zero,a1   #-- Segunda llamada: a1 = 1, a2 = 1
    xor	a1,a1,a6         #-- Segunda llamada: a1 = 1 xor x6 = 01 xor 11 = 10
    andi	a1,a1,3      #-- Segunda llamada: a1 = 1 and 11 = 1

    #-- AQUI PETA!!!!!!
    sw	a1,0(a5)  #Comentada para que no pete... (¿?)

clock_configure_undivided_label8:
#-- SE QUEDA EN BUCLE INFINITO!!!
# 10000e90:	
    lw a5,8(a4)   #-- CLK_SYS_SELECTED
    and	a5,a5,a2
    beqz	a5,clock_configure_undivided_label8  # 10000e90 <clock_configure_undivided+0xcc>
    j	clock_configure_undivided_label9  #  10000e22 <clock_configure_undivided+0x5e>





tick_start:
    lui	a5,0x40108
    sh1add	a0,a0,a0
    sh2add	a0,a0,a5
    sw	a1,4(a0)
    li	a5,1
    sw	a5,0(a0)
    ret


runtime_init_post_clock_resets:
# 10001032:	
    lui	a4,0x20000
    addi	a4,a4,-1 # 1fffffff <__flash_binary_end+0xfffe60b>
    lui	a5,0x40023
    lui	a3,0x40020
    sw	a4,0(a5)
    addi	a3,a3,8 # 40020008 <__StackTop+0x1ff9e008>
runtime_init_post_clock_resets_label1:    
# 10001044
    lw	a5,0(a3)
    andn	a5,a4,a5
    bnez	a5,runtime_init_post_clock_resets_label1 # 10001044 <runtime_init_post_clock_resets+0x12>
    ret



busy_wait_us:

    lui	a4,0x400b0
    lw a5,36(a4)

busy_wait_us_label1:
# 10000c2e:	
    lw a6,40(a4) # 400b0028 <__StackTop+0x2002e028>
    mv	a3,a5
    lw	a5,36(a4)
    bne	a5,a3,busy_wait_us_label1 # 10000c2e <busy_wait_us+0x6>

    add	a2,a0,a6
    add	a1,a1,a5
    sltu a4,a2,a0
    add	a4,a4,a1
    bltu a4,a5,busy_wait_us_label2  # 10000c7e <busy_wait_us+0x56>

busy_wait_us_label11:
# 10000c4e
    beq	a5,a4,busy_wait_us_label3  # 10000c7a <busy_wait_us+0x52>
    lui	a5,0x400b0
    lw	a5,36(a5)
    bgeu a5,a4,busy_wait_us_label4 # 10000c62 <busy_wait_us+0x3a>

busy_wait_us_label8:
# 10000c58
    lui	a3,0x400b0

busy_wait_us_label5:
# 10000c5c:	
    lw a5,36(a3)
    bltu a5,a4,busy_wait_us_label5   # 10000c5c <busy_wait_us+0x34>

busy_wait_us_label4:
# 10000c62:	
    bne a5,a4,busy_wait_us_label4 # 10000c78 <busy_wait_us+0x50>

busy_wait_us_label9:
# 10000c66
    lui	a4,0x400b0
    j	busy_wait_us_label6   # 10000c72 <busy_wait_us+0x4a>

busy_wait_us_label7:
# 10000c6c:
    lw	a3,36(a4)
    bne	a3,a5,busy_wait_us_label10  # <busy_wait_us+0x50>

busy_wait_us_label6:
# 10000c72:	
    lw a3,40(a4)
    bltu a3,a2,busy_wait_us_label7   # 10000c6c <busy_wait_us+0x44>

busy_wait_us_label10:
# 10000c78:	
ret

busy_wait_us_label3:
# 10000c7a:	
    bgeu a2,a6, busy_wait_us_label11  # 10000c4e <busy_wait_us+0x26>

busy_wait_us_label2:
# 10000c7e:	
    lui	a5,0x400b0
    lw	a5,36(a5)
    li	a4,-1
    mv	a2,a4
    bne	a5,a4,busy_wait_us_label8    # 10000c58 <busy_wait_us+0x30>
    mv a2,a5
    j busy_wait_us_label9  # 10000c66 <busy_wait_us+0x3e>

