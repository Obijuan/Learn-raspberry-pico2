 # ----------------------------------------------
 # -- Envío de un carácter por la UART
 # -- Con cada pulsación del pulsador GPIO15
 # ----------------------------------------------
.include "boot.h"
.include "regs.h"

.section .text

# -- Punto de entrada
.global _start
_start:

    #-- Inicializar la pila
    la sp, _stack_top

    #-- Inicializar el sistema
    jal	runtime_init

    #-- Configurar el LED
    jal led_init

    #-- Configurar el pulsador
    jal button_init15

   

    li a1,2
    li a0,1
    jal gpio_set_function

     #-- Inicializar la UART
    #-- Velocidad: 115200 (con runtime actual)
    jal uart_init 



    #-- Encender el LED
    jal led_on




main_loop:

    #-- Transmitir un asterisco inicial
    li a0, '*'
    #jal putchar

  

    lui	a4,0x40070

label1_:

    lw a5,24(a4)
    andi a5,a5,16
    bnez a5, label1_
    lw a3,0(a4)

label2_:
    lw a5,24(a4)
    andi a5,a5,32
    bnez a5, label2_ 
    zext.b a5,a3
    sw a5,0(a4)

    jal led_toggle

    j main_loop  #label1_


gpio_set_function:
    lui	a5,0x40038
    addi a5,a5,4 
    sh2add a5,a0,a5
    lw a4,0(a5)
    lui	a3,0x1
    add	a3,a3,a5
    xori a4,a4,64
    andi a4,a4,192
    lui	a2,0x40028
    sw a4,0(a3)
    sh3add	a0,a0,a2
    lui	a4,0x3
    add	a5,a5,a4
    sw a1,4(a0)
    li a4,256
    sw a4,0(a5)
    ret



    #-- Esperar a que el receptor tenga datos
wait_rx:
    li t0, UART0_UARTF
    lw t1, 0(t0)  
    andi t1,t1,RXFF

    #-- ¿Bit RXFF==1? (sin caracter), esperar
    bne t1, zero, wait_rx

    #-- Leer dato
    li t0,UART0_UARTDR
    lw t1, 0(t0)

    #-- Cambiar de estado el LED
    jal led_toggle

    #-- Repetir
    j main_loop


