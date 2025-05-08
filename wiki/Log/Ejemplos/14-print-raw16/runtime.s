.global runtime_init


.include "regs.h"

.section .text
#----------------------------------------
#-- Inicializacion del sistema
#----------------------------------------
runtime_init:
    addi sp,sp,-16
    sw ra,12(sp)

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

    #-- Esperar a que se finalice la seleccion
wait_clk_ref_selected:
    li t0, CLK_REF_SELECTED
    lw t1, 0(t0)
    li t2,1
    bne t1,t2, wait_clk_ref_selected

    #-- Inicializar plls
    jal pll_sys_init
    jal	pll_usb_init 

    #-- Configurar CLK_REF
    jal	configure_clk_ref

    #-- Configurar CLK_SYS
    jal	configure_clk_sys

    #-- Configurar CLK_USB
    jal	configure_clk_usb

    #-- Configurar CLK_ADC
    jal	configure_clk_adc 

    #-- Configurar CLK_PERI
    jal	configure_clk_peri

    #-- Configurar CLK_HSTX
    jal	configure_clk_hstx

    lw ra,12(sp)
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

configure_clk_ref:
    #-- Divisor: 1
    li t0, CLK_REF_DIV
    li t1, BIT16  # 0x10000
    sw t1, 0(t0)

    #-- Seleccionar la fuente para CLK_REF
    #-- Oscilador interno
    li t0, CLOCK_REF_CTRL
    li t1, 2
    sw t1, 0(t0) 

    #-- Esperar a que se seleccione la fuente
    li t0, CLK_REF_SELECTED
wait_clk_ref_selected2:
    lw t1, 0(t0)
    andi t1,t1, 0xF
    beq t1, zero, wait_clk_ref_selected2 

    #-- ¿Se puede eliminar?
    li t0, CLK_REF_CTRL_SET
    sw zero, 0(t0)

    #-- Divisor a 1
    li t0, CLK_REF_DIV
    li t1, BIT16 
    sw t1, 0(t0)
    ret


configure_clk_sys:
    #-- Seleccionar la fuente: CLK_REF
    li t0, CLK_SYS_CTRL_CLR
    li t1, 3
    sw t1, 0(t0)

    #-- Esperar a que se seleccione la fuente
    li t0, CLK_SYS_SELECTED
wait_clk_sys_selected:
    lw t1, 0(t0)
    andi t1,t1,1
    beq t1, zero, wait_clk_sys_selected

    #-- Fuente auxiliar de reloj: PLL_SYS
    li t0, CLK_SYS_CTRL
    sw zero, 0(t0)
   
    li t0, CLK_SYS_CTRL_XOR
    li a1, 1
    sw a1, 0(t0) 

    li t0, CLK_SYS_SELECTED
wait_clk_sys_selected2:
    lw t1, 0(t0)
    andi t1,t1, 0x2
    beq t1, zero, wait_clk_ref_selected2

    #-- Establecer el divisor a 1
    li t0, CLK_SYS_DIV
    li t1,0x10000   
    sw t1,0(t0)
    ret


configure_clk_usb:
    li t0, CLK_USB_CTRL_CLR
    li t1, BIT11
    sw t1, 0(t0) 

    li t0, CLK_USB_CTRL
    lw t2, 0(t0)

    #-- Establecer la fuente de reloj auxiliar
    li t0, CLK_USB_CTRL_XOR
    andi t1, t2, 0xe0
    sw t1, 0(t0)

    li t0, CLK_USB_CTRL_SET
    li t1, BIT11
    sw t1, 0(t0)

    #-- Divisor a 1
    li t0, CLK_USB_DIV
    li t1, BIT16
    sw t1, 0(t0)
    ret

configure_clk_adc:
    li t0, CLK_ADC_CTRL_SET
    li t1, BIT11
    sw t1, 0(t0)

    li t0, CLK_ADC_DIV
    li t1,0x10000
    sw t1, 0(t0)
    ret


configure_clk_peri:
    li t0, CLK_PERI_CTRL
    lw t2, 0(t0)

    li t0, CLK_PERI_CTRL_XOR
    andi t1,t2,0xE0
    sw t1, 0(t0)

    li t0, CLK_PERI_CTRL_SET
    li t1, BIT11
    sw t1, 0(t0)

    li t0, CLK_PERI_DIV
    li t1, BIT16
    sw t1, 4(t0)
    ret

configure_clk_hstx:
    li t0, CLK_HSTX_CTRL_SET
    li t1, BIT11
    sw t1, 0(t0)

    li t0, CLK_HSTX_DIV
    li t1, BIT16
    sw t1, 0(t0)
    ret

