 # ----------------------------------------------
 # -- Envío de un carácter por la UART
 # ----------------------------------------------

.include "boot.h"
.include "gpio.h"

.equ CLOCK_BASE,         0x40010000
.equ CLK_SYS_CTRL,       0x4001003C
.equ CLK_SYS_SELECTED,   0x40010044
.equ CLK_SYS_RESUS_CTRL, 0x40010084 

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
.equ RESET_UART0, BIT26

# -----------------------------------
# -- Registro de Status del reset
# -- Pone a 1 el bit correspondiente
# -- cuando el periférico se ha reseteado 
# -----------------------------------
.equ RESET_DONE, 0x40020008

.equ SRAM_BASE,  0x20000000
.equ UART0_BASE, 0x40070000
.equ UART1_BASE, 0x40078000

#-- Crystal oscillator
.equ XOSC_BASE,    0x40048000
.equ XOSC_CTRL,    0x40048000
  .equ XOSC_CTRL_SET,0x4004A000

.equ XOSC_STATUS,  0x40048004
.equ XOSC_STARTUP, 0x4004800C

.equ PLL_SYS_BASE, 0x40050000 

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

    #--------- Configurar pin TX UART0
    #-- Configurar el PAD del GPIO0
    li t0, PAD_GPIO0
    li t1, 0x56
    sw t1,0(t0)

    #-- Asignar el GPIO0 al pin tx de la UART0
    li a0,GPIO00_CTRL
    li a1, 2
    sw a1,0(a0)

    #-- DEBUG: Cuanto vale el registro PAD del GPIO0 ?
    #jal button_init15
    
    #li t0, PAD_GPIO0
    #lw a0, 0(t0)
    #jal debug_led1_lsb

main_loop:

    li	a4,UART0_BASE
next:
    lw	a5,0x18(a4)    #-- Leer Registro UARTFR (Flag-register)
    andi	a5,a5,0x20
    bnez	a5,next

    #-- Transmitir!
    li	a5,'A'
    sw	a5,0(a4)

    #-- Esperar!
    jal delay
    jal led_toggle
    j main_loop

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
    sw s2,16(sp)
    sw s3,12(sp)

    li s1,115200  #-- Baudios
    li s0,UART0_BASE

    #----------------- Configuracion de la UART0
uart_init_label6:

    #-- Activar reset de la uart0
    li a4,RESET_UART0
    li a5,RESET_CTRL_SET  
    sw a4,0(a5)

    #-- Desactivar el reset de la uart0
    li a5,RESET_CTRL_CLR
    sw a4,0(a5)

    #-- Esperar hasta que el reset termine
    li a3, RESET_DONE   #-- Registro de reset
    li a4, RESET_UART0  #-- Bit de reset de la uart0

wait_reset_done:
    lw a5,0(a3)      #-- Leer estado del reset
    and a5, a5, a4   #-- Aislar el bit de reset de la uart

    #-- Bit RESET_UART0 == 0? --> Esperar
    beq a5, zero, wait_reset_done

    #-- El bit RESET_UART0 del registro RESET_DONE está a 1
    #-- Significa que la UART0 está inicializada





    lui	a5,0xbff88
    add	a5,a5,s0
    lui	a4,0x20000
    addi	a4,a4,1348 # 20000544 <uart_char_to_line_feed>
    seqz	a5,a5
    sh1add	a5,a5,a4
    li	a0,6
    li	a4,256
    sh	a4,0(a5) # bff88000 <__StackTop+0x9ff06000>
    jal	clock_get_hz  # 10000e98 <clock_get_hz>

    slli	a5,a0,0x3
    divu	a5,a5,s1
    addi	a5,a5,1
    srli	a4,a5,0x7

    #--- Pasa por aqui

    lui	a2,0x10
    addi a2,a2,-2 # fffe <HeapSize+0xf7fe>
    lui	a3,0x10

uart_init_label2:

# 10000db2:	
    srli a5,a5,0x1
    andi a5,a5,63
    slli s3,a4,0x6
    mv a3,a4
    add	s3,s3,a5
    mv a4,a5
    j uart_init_label3 # 10000d04 <uart_init+0x74>


uart_init_label3:
# 10000d04:	
    #--- Pasa por aquí

    sw a3,36(s0)
    sw a4,40(s0)
    lw s2,48(s0)
    andi a5,s2,1
    #bnez a5,uart_init_label4 # 10000d76 <uart_init+0xe6>

    #--- Pasa por aqui

uart_init_label5:
# 10000d12:

    #--- Pasa por aquí

    lui s1,0x1
    addi s1,s1,44 # 102c <HeapSize+0x82c>
    add	s1,s1,s0
    lw a5,44(s0)
    sw zero,0(s1)
    sw s2,48(s0)
    li	a0,6
    jal	clock_get_hz  # 10000e98 <clock_get_hz>

    lw a5,44(s0)
    slli a0,a0,0x2
    divu a0,a0,s3
    xori a5,a5,112
    andi a5,a5,126
    sw a5,0(s1)
    li a3,769
    li a4,3
    sw a3,48(s0)
    sw a4,72(s0)
    
    #-- Fin de la funcion
    lw ra,28(sp)
    lw s0,24(sp)
    lw s1,20(sp)
    lw s2,16(sp)
    lw s3,12(sp)
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

    # -- Este salto NO se hace
    bgeu a5,s1,runtime_run_initializers_end   # 10000fe4 <runtime_run_initializers+0x2a> # label_rt_1

    #-- s0 = 0x10001574
    addi s0,s0,0x574

    #-- Inicializaciones!!
    jal runtime_init_bootrom_reset
    jal runtime_init_early_resets
    jal runtime_init_usb_power_down
    jal runtime_init_clocks
    jal runtime_init_post_clock_resets

    j runtime_run_initializers_end



    #-- Se comienza analizando lo que hay en __pre_init_runtime_init_bootrom_reset
label_rt_2:

    #-- Cargar direccion guardada en s0
    lw	a5,0(s0)

    #-- Apuntar a la siguiente entrada
    addi	s0,s0,4

    #-- Ejecutar el codigo en esa direccion
    jalr	a5

    #-- Mientras que s0 < s0, se continua ejecutando ese codigo
    bltu	s0,s1,label_rt_2    # 10000fda <runtime_run_initializers+0x20> # label_rt_2

    #-- Fin de la inicializacion

runtime_run_initializers_end:
    lw ra,12(sp)
    lw s0,8(sp)
    lw s1,4(sp)
    addi sp,sp,16
    ret

#------------------------------------------------------
#-- Estas son las funciones de inicializacion que
#-- se ejecutan
#-- Algunas seran críticas para la uart, otras no...
#------------------------------------------------------
#-- Esta es la tabla de vectores de inicializacion
#-- <__pre_init_runtime_init_bootrom_reset>:
# ✅10001574:	.word runtime_init_bootrom_reset # 0x1000_104e
# 10001578 <__pre_init_runtime_init_early_resets>:
# ✅10001578:	.word runtime_init_early_resets # 0x1000_0fee
# 1000157c <__pre_init_runtime_init_usb_power_down>:
# ✅1000157c:	.word runtime_init_usb_power_down # 0x1000_1018
# 10001580 <__pre_init_runtime_init_clocks>:
# ✅10001580:	     .word runtime_init_clocks # 0x1000_107e
# 10001584 <__pre_init_runtime_init_post_clock_resets>:
# ✅10001584:	    .word runtime_init_post_clock_resets # 0x1000_1032


runtime_init_bootrom_reset:
    li  a0,0x5000
    addi sp,sp,-16
    addi  a0,a0,0x253 # 5253 <HeapSize+0x4a53>
    sw ra,12(sp)

    # -- a0 = 0x5253
    jal	rom_func_lookup # 10000f46
    lw ra,12(sp)
    mv a5,a0
    li a0,4
    addi sp,sp,16
    jr a5

rom_func_lookup:
    li a5,0x8000
    addi	a5,a5,-518 # 7dfa <HeapSize+0x75fa>

    #-- a5 = 0x7dfa
    lhu	a5,0(a5)
    li	a1,1
    jr a5

runtime_init_early_resets:
    li a5, 0xefef4000
    addi a5,a5,-1153 # efef3b7f <__StackTop+0xcfe71b7f>
    # -- a5 = 0xefef3b7f

    li a3,0x40022000   # -- RESET_CTRL + 0x2000

    #-- ESTO PARECE QUE ES ACTIVAR EL RESET
    #-- Valor inicial a5: 1110 1111 1110 1111 0011 1011 0111 1111
    #-- Valor usado     : 1110 1111 1110 1111 0011 1011 0011 FFFF
    #-- Cambia el bit del IO_BANK0
    li a5,0xEFEF3B3F  #-- Si se hace reset de IO_BANK0, peta...
    sw a5,0(a3)

    li a4,0x03f40000
    addi	a4,a4,-10 # 3f3fff6 <HeapSize+0x3f3f7f6>
    # a4 = 0x03f3fff6

    # -- ESTO PARECE QUE ES DESACTIVAR EL RESET
    # -- 0000 0011 1111 0011 1111 1111 1111 0110
    li  a5,0x40023000   #-- RESET_CTRL + 0x3000
    sw	a4,0(a5)

    li	a3,RESET_DONE

    #-- Esperar a que se reinicien todos los sistemas
label_rt_3:
    lw	a5,0(a3)
    andn	a5,a4,a5
    bnez	a5,label_rt_3 # 1000100e <runtime_init_early_resets+0x20>

    #-- Todos los bits especificados de RESET_DONE
    #-- están a 1
    ret



runtime_init_usb_power_down:
    li a5,USB_SIE_CTRL
    lw a4,0(a5)
    li a5,0x00008000  #-- PULLDOWN_EN
    beq	a4,a5,label_rt_4  # 10001026 <runtime_init_usb_power_down+0xe>
    ret

    #-- Esto se ejecuta si está habilitado el pull-down
label_rt_4:
    li	a5,USB_SIE_CTRL_SET
    li	a4,0x40000  #-- TRANSCEIVER_PD: Apagar el transceptor del bus
    sw	a4,0(a5)
    ret



runtime_init_clocks:
    addi sp,sp,-16
    sw ra,12(sp)
    sw s0,8(sp)
    sw s1,4(sp)
    sw s2,0(sp)

    li s0, CLOCK_BASE
    sw	zero,0x84(s0)  # 40010084 (CLK_SYS_RESUS_CTRL)

    #-- Inicializar oscilador externo
    jal	xosc_init  # 10000f84 

    #-- Seleccionar CLK-REF (?)
    li a5,0x40013000  #-- CLOCK_BASE + 0x3000    
    li a4,1
    sw a4,0x3C(a5) #-- (CLOCK_CTRL_XOR)

    #-- Esperar a que se realice la selección de reloj
label_rt_5:
    lw	a5,0x44(s0) # (CLK_SYS_SELECTED)
    bne	a5,a4,label_rt_5  # 1000109a <runtime_init_clocks+0x1c>

    li a4,3
    li a5,0x40013000 #-- CLOCK_BASE + 0x3000
    sw	a4,0x30(a5)  #-- CLK_REF_CTRL

    li	s0,1
    li	a4,CLOCK_BASE
label_rt_6:
    lw	a5,0x38(a4)  #-- CLK_REF_SELECTED 
    bne	a5,s0,label_rt_6  # 100010ae <runtime_init_clocks+0x30>

    li a2,0x59683000
    mv a1,s0
    addi a2,a2,-256 # 59682f00 <__StackTop+0x39600f00>
    #-- a2 = 0x59682f00

    li a4,2
    li a3,5
    li a0,PLL_SYS_BASE
    jal pll_init # 10000ea8

    li	a4,5
    lui	a2,0x47869
    mv	a3,a4
    mv	a1,s0
    addi a2,a2,-1024 # 47868c00 <__StackTop+0x277e6c00>
    lui	a0,0x40058
    jal	pll_init # 10000ea8 <pll_init>

    lui	a3,0xb72
    addi a3,a3,-1280 # b71b00 <HeapSize+0xb71300>
    li	a2,0
    li	a1,2
    li	a0,4
    jal	clock_configure_undivided # 10000dc4 <clock_configure_undivided>

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


pll_init:
    li a5,0x00b72000
    addi a5,a5,-1280 # b71b00 <HeapSize+0xb71300>
    divu a5,a5,a1
    lw a7,0(a0)

    slli a3,a3,0x10
    slli a4,a4,0xc
    or a6,a3,a4
    divu a2,a2,a5
    bltz a7,pll_init_label1  # 10000f0c <pll_init+0x64>

pll_init_label4:
    li a5,0x40058000
    li a4,0x4000
    beq	a0,a5,pll_init_label2  # 10000f2e <pll_init+0x86>

pll_init_label3:
    lui	a5,0x40022
    sw	a4,0(a5)
    lui	a3,0x40020
    lui	a5,0x40023
    sw	a4,0(a5)
    addi a3,a3,8 # 40020008 <__StackTop+0x1ff9e008>

pll_init_label5:
    lw	a5,0(a3)
    andn	a5,a4,a5
    bnez	a5,pll_init_label5  # 10000ee4 <pll_init+0x3c>

    lui	a4,0x3
    sw	a1,0(a0)
    addi a4,a4,4 # 3004 <HeapSize+0x2804>
    sw	a2,8(a0)
    add	a4,a4,a0
    li	a5,33
    sw	a5,0(a4)

pll_init_label6:
    lw a5,0(a0)
    bgez a5,pll_init_label6  # 10000efc <pll_init+0x54>
    sw	a6,12(a0)
    li	a5,8
    sw	a5,0(a4)
    ret

pll_init_label1:
    lw a5,0(a0)
    andi a5,a5,63
    bne	a5,a1,pll_init_label4 # 10000ec8 <pll_init+0x20>

    lw a5,8(a0)
    slli a5,a5,0x14
    srli a5,a5,0x14
    bne a5,a2,pll_init_label4 # 10000ec8 <pll_init+0x20>

    lw	a5,12(a0)
    lui	a4,0x77
    and	a5,a5,a4
    bne	a5,a6,pll_init_label4 # 10000ec8 <pll_init+0x20>
    ret

pll_init_label2:
    li a4,0x8000
    j	pll_init_label3 # 10000ed2 <pll_init+0x2a>


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

