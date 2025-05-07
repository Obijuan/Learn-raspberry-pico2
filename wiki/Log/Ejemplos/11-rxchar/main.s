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

wait_rx:
    li t0, UART0_UARTF
    lw t1, 0(t0)  
    andi t1,t1,RXFF

    #-- ¿Bit RXFF==1? (sin caracter), esperar
    bne t1, zero, wait_rx

    #-- Leer dato recibido
    li t0,UART0_UARTDR
    lw a0, 0(t0)

    #-- Eco del caracter recibido
    jal putchar

    #-- Cambiar de estado el led
    jal led_toggle
    j main_loop 


gpio_set_function:
    li a1,2
    li a0,1

    
    li a5, PAD_GPIO1
    lw a4, 0(a5)

    
    xori a4,a4, 0x40
    andi a4,a4, 0xC0

    li a3, PAD_GPIO1_XOR
    sw a4, 0(a3)


    #-- sh3add rd, rs1, rs2
    #-- X(rd) = X(rs2) + (X(rs1) << 3);
    #--  a0   =  a2  +  (a0 << 3)

    li a2, 0x40028000
    sh3add	a0,a0,a2
    #li a0, PAD_GPIO1



    lui	a4,0x3
    add	a5,a5,a4
    sw a1,4(a0)
    li a4,256
    sw a4,0(a5)
    ret



    #-- Esperar a que el receptor tenga datos
wait_rx2:
    li t0, UART0_UARTF
    lw t1, 0(t0)  
    andi t1,t1,RXFF

    #-- ¿Bit RXFF==1? (sin caracter), esperar
    bne t1, zero, wait_rx2

    #-- Leer dato
    li t0,UART0_UARTDR
    lw t1, 0(t0)

    #-- Cambiar de estado el LED
    jal led_toggle

    #-- Repetir
    j main_loop


