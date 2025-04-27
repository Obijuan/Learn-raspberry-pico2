.section .text
.global _start

.include "gpio.h"

_start:
    la sp, _stack_top   # Load stack pointer
    call main           # Call main
    wfi                 # Wait for interrupt (to save power)
    j _start            # Loop forever (should never reach here)

# -----------------------------------------------------------------------------
.p2align 8 # This special signature must appear within the first 4 kb of
image_def: # the memory image to be recognised as a valid RISC-V binary.
# -----------------------------------------------------------------------------

.word 0xffffded3
.word 0x11010142
.word 0x00000344
.word _start
.word _stack_top
.word 0x000004ff
.word 0x00000000
.word 0xab123579

main:   

    #-- Configuracion de GPIO0 para controlarse por software
    li t0, GPIO25_CTRL  
    li t1, FUNC_SOFTWARE          
    sw t1, 0(t0)        

    #-- Configuracion de GPIO0 como salida
    li t0, GPIO_OE      
    li t1, BIT25
    sw t1, 0(t0)

    #-- Habilitar el pin GPIO0
    li t0, GPIO25_PAD_ISO  
    li t1, PAD_ENABLE
    sw t1, 0(t0)

    # -- Encender el LED
    li t0, GPIO_OUT
    li t1, BIT25    #-- Activar el bit 25
    sw t1, 0(t0)  

    # -- FIN
inf:  j inf
      nop

