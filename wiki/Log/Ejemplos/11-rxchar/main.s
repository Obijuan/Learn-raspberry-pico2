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


