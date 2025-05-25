.global _start   #-- Punto de entrada

.section .text

# -- Punto de entrada
_start:

    #-- Inicializar contador
    li t0, 0

loop:
    #-- Incrementar contador
    addi t0, t0, 1

    j loop 
