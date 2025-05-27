#---------------------------
#-- Funciones de interfaz
#---------------------------
.global _start   #-- Punto de entrada

.include "riscv.h"
.include "regs.h"
.include "delay.h"
.include "uart.h"
.include "ansi.h"

.section .text

# -- Punto de entrada
_start:

    #-- Acciones de arranque
    la sp, __stack_top
    jal runtime_init

    #-- Establecer el vector de interrupcion
    la t0, isr
    csrw mtvec, t0

main:
    #-- Configurar perifericos
    jal led_init
    jal uart_init

    #-- Apagar LED
    jal led_off

    CLS

    #--- Activar el temporizador del RISCV
    #--- Que se actualice en cada ciclo
    li t0, MTIME_CTRL
    li t1, 0x3
    sw t1, 0(t0)

    #-- Configurar el comparador
    li t0, MTIMECMPH
    sw zero, 0(t0)
    li t0, MTIMECMP
    li t1, 0x20000000
    sw t1, 0(t0)


    #-- Activar las interrupciones del temporizador
    li t0, MIE_MTIE
    csrs mie, t0

    COLOR WHITE
    PRINT "Temporizador lanzado!\n\n"

    #-- Activar las interrupciones globales
    li t0, MSTATUS_MIE
    csrs mstatus, t0

loop:

    #-- Imprimir el temporizador
    jal print_mtimer
    NL

    #-- Esperar (espera activa)
    jal delay
    jal delay

    #-- Repetir 
    j loop


print_mtimer:
FUNC_START4
    #-- Leer temporizador del RISCV
    PRINT "Timer: "
    li t0, MTIMEH
    lw a0, 0(t0)
    jal print_hex32
    PRINT "-"
    li t0, MTIME
    lw a0, 0(t0)
    jal print_hex32
    NL

    #-- Imprimir el comparador
    PRINT "CMP:   "
    li t0, MTIMECMPH
    lw a0, 0(t0)
    jal print_hex32
    PRINT "-"
    li t0, MTIMECMP
    lw a0, 0(t0)
    jal print_hex32
    NL
FUNC_END4


isr:
    SAVE_CONTEXT

    jal led_on
    CPRINT RED, "ISR: Temporizador!\n"
    COLOR WHITE

    j .

    RESTORE_CONTEXT
    mret    

