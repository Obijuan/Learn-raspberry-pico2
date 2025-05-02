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
.equ UART1_BASE, 0x40078000


.section .text

# -- Punto de entrada
.global _start
_start:

    #-- Inicializar la pila
    la sp, _stack_top

    #-- Configurar el LED
    jal led_init  

#-------------------------------

runtime_init:
    li s0,0x10001000 #-- XIP BASE + 0x1000
    jal	runtime_run_initializers
    #jal led_on
    #j halt

    #-- TODO





#-------------------------
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
    sw s2,16(sp)
    sw s3,12(sp)

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

    #-- Aquí comienza la inicializacion de la uart
    li a5,UART1_BASE
    li a4,0x04000000
    #beq s0,a5,label1   # 10000dac

    #----------------- Configuracion de la UART0
    li a4,BIT26
    lui a5,0x40022  #-- RESET_CTRL + 0x2000  (¿set?)
    sw a4,0(a5)

    
    li a3,RESET_CTRL
    lui a5,0x40023  #-- RESET_CTRL + 0x3000 (¿clear?)
    sw a4,0(a5)

    jal led_on

    li a3, RESET_DONE 
loop1:
    lw a5,0(a3)     # a5 = Registro Reset_done
    li a4, BIT26
    andn a5,a4,a5   # a5 = a4 and ~a5
    bnez a5,loop1   # 10000cc4

    #-- Llega aquí si el bit26 del registro reset_done está a 1
    #-- Es decir, llega aquí cuando se ha reseteado la uart0

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
    lw s2,16(sp)
    lw s3,12(sp)
    addi sp,sp,32
    ret

#-- Configuracion de la UART1
label1:
    jal halt


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


    jal runtime_init_bootrom_reset
    jal runtime_init_early_resets

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
# 10001578:	.word runtime_init_early_resets # 0x1000_0fee                                   ....
# 
# 1000157c <__pre_init_runtime_init_usb_power_down>:
# 1000157c:	1018 1000                                   ....
# 
# 10001580 <__pre_init_runtime_init_clocks>:
# 10001580:	107e 1000                                   ~...
# 
# 10001584 <__pre_init_runtime_init_post_clock_resets>:
# 10001584:	1032 1000                                   2...
# 
# 10001588 <__pre_init_runtime_init_boot_locks_reset>:
# 10001588:	0f66 1000                                   f...
# 
# 1000158c <__pre_init_runtime_init_spin_locks_reset>:
# 1000158c:	107a 1000                                   z...
# 
# 10001590 <__pre_init_runtime_init_bootrom_locking_enable>:
# 10001590:	0f54 1000                                   T...
# 
# 10001594 <__pre_init_runtime_init_mutex>:
# 10001594:	03d2 1000                                   ....
# 
# 10001598 <__pre_init_runtime_init_default_alarm_pool>:
# 10001598:	0824 1000                                   $...
# 
# 1000159c <__pre_init_first_per_core_initializer>:
# 1000159c:	0fa8 1000                                   ....
# 
# 100015a0 <__pre_init_runtime_init_per_core_bootrom_reset>:
# 100015a0:	1064 1000                                   d...
# 
# 100015a4 <__pre_init_runtime_init_per_core_h3_irq_registers>:
# 100015a4:	119e 1000                                   ....
# 
# 100015a8 <__pre_init_runtime_init_per_core_irq_priorities>:
# 100015a8:	02d2 1000                                   ....
# 
# 100015ac <__frame_dummy_init_array_entry>:
# 100015ac:	015a 1000 14dc 1000                         Z.......

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
    li a4,0x03f40000

    #-- Valor inicial a5: 1110 1111 1110 1111 0011 1011 0111 1111
    #-- Valor usado     : 1110 1111 1110 1111 0011 1011 0011 FFFF
    #-- Cambia el bit del IO_BANK0
    li a5,0xEFEF3B3F  #-- Si se hace reset de IO_BANK0, peta...
    sw a5,0(a3)

    #----- WARNING! Al hacer este store se va todo al carajo...
    #--- deja de ejecutar instrucciones!!!!

    jal delay
    jal led_blinky

    ret

    addi	a4,a4,-10 # 3f3fff6 <HeapSize+0x3f3f7f6>
    lui	a5,0x40023
    lui	a3,0x40020
    sw	a4,0(a5)
    addi	a3,a3,8 # 40020008 <__StackTop+0x1ff9e008>

label_rt_3:
    lw	a5,0(a3)
    andn	a5,a4,a5
    bnez	a5,label_rt_3 # 1000100e <runtime_init_early_resets+0x20>
    ret
