#---------------------------
#-- Funciones de interfaz
#---------------------------
.global _start   #-- Punto de entrada

.include "regs.h"
.include "riscv.h"

.section .vector

_VectorTable:

    #-- Offset 0: Excepciones
    j isr_exceptions
    .word 0
    .word 0

    #-- Offset: 0xC: Interrupciones software (MSI)
    j halt
    .word 0
    .word 0
    .word 0

    #-- Offset 0x1C: Interrupciones del temporizador (MTI)
    j halt
    .word 0
    .word 0
    .word 0

    #-- Offset 0x2C: Interrupción externa (MEI)
    j halt

halt:
    j .

.section .text

# -- Punto de entrada
_start:

    #-- Configurar la pila
    la sp, __stack_top
       
    #-- Configurar la tabla de vectores
    #-- de interrupcion
    #-- El +1 significa modo Tabla
    la t0, _VectorTable + 1
    #csrw mtvec, t0

    la t0, isr_exceptions
    csrw mtvec, t0

    #-- Inicializar LED
    jal led_init

    #-- Generar una llamada al sistema
    ecall

    #-- Encender el LED
    jal led_on
    j .

#--------------------------------------------
#-- Rutinas de interrupcion
#--------------------------------------------

#-------------------------------
#-- Atención a las excepciones
#-------------------------------
.align 4
isr_exceptions:
    jal led_blinky2

