.global _start   #-- Punto de entrada

.section .text

# -- Punto de entrada
_start:

    #-- Acciones de arranque
    la sp, __stack_top

main:

    #-- Configurar perifericos
    jal led_init

loop:
    jal led_on
    jal led_off
    j loop

