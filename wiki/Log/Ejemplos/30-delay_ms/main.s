#---------------------------
#-- Funciones de interfaz
#---------------------------
.global _start   #-- Punto de entrada

.include "riscv.h"
.include "regs.h"
.include "uart.h"
.include "ansi.h"

.section .text

# -- Punto de entrada
_start:

    #-- Acciones de arranque
    la sp, __stack_top
    jal	runtime_init

    #-- Configurar perifericos
    jal led_init
    jal uart_init

    #-- Encender el LED
    jal led_on

main: 

    #-- Encender el AON-Timer
    li t0, POWMAN_TIMER
    li t1, 0x5afe0000 + RUN
    sw t1, 0(t0)

    #-- Esperar hasta que transcurra el tiempo
    #-- establecido

timer_wait:
    #jal delay
    li t0, READ_TIME_LOWER
    lw t1, 0(t0)  #-- Leer temporizador
    #jal print_hex32
    #NL


    li t2, 100
    bltu t1, t2, timer_wait

    jal led_toggle

    #-- Apagar temporizador
    li t0, POWMAN_TIMER
    li t1, 0x5afe0000
    sw t1, 0(t0)

    j main
    
    
