#---------------------------
#-- Funciones de interfaz
#---------------------------
.global _start   #-- Punto de entrada

.include "riscv.h"
.include "delay.h"
.include "uart.h"
.include "ansi.h"

.section .text

# -- Punto de entrada
_start:

    #-- Acciones de arranque
    la sp, __stack_top
    jal runtime_init

main:
    #-- Configurar perifericos
    jal led_init
    jal uart_init

    #-- Encender el LED
    jal led_on

    #-- Imprimir los registros privilegiados
    CLS
    jal print_mstatus
    NL
    jal print_misa
    NL
    jal print_mie
    NL
    jal print_mtvec
    NL


    #-- MCOUNTINHIBIT 
    #-- MEPC (Machine exception program counter.)
    #-- MCAUSE Register
    #-- MIP (Machine interrupt pending)
    #-- MCYCLE 
    #-- MCYCLEH Register
    #-- MVENDORID (no me deja leerlo...)
    #-- MARCHID (Architecture ID)  
    #-- MIMPID (Implementation ID. On RP2350 this reads as 0x86fc4e3f,
      #-- which is release v1.0-rc1 of Hazard3.
    #-- MHARTID 
    

loop: 

    #-- Esperar
    DELAY_MS 200

    #-- Cambiar de estado el LED
    jal led_toggle

    j loop
    
