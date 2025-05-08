.global dump16

.section .text

# ---------------------------------------------------------------------------
# dump16: Volcado de memoria en bloques de 16 bytes (4 palabras)
# ---------------------------------------------------------------------------
# ENTRADAS:
#  -a0: Direccion donde empezar a volcar (digito de menor peso debe ser 0)
#  -a1: Numero de bloques de 16 bytes a volcar (a1 >= 1)  
#
# DEVUELVE:
#  -a0: La direccion siguiente al ultimo bloque mostrado
#    (esto permite encadenar llamadas a dump16)
# ---------------------------------------------------------------------------
dump16:
    addi sp,sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)

    #-- Meter en s0 la direccion inicial
    mv s0, a0

    #-- Meter en s1 el numero de bloques a volcar
    mv s1, a1

_dump16_loop:
    #-- Imprimir el byte de la direccion actual
    lb a0, 0(s0)
    jal print_hex8

    li a0, ' '
    jal putchar

    #-- Incrementar direccion
    addi s0, s0, 1

    #-- Comprobar si se han impreso 16 bytes
    #-- correspondientes a una línea
    #-- Ailar los 4 bits de menor peso
    andi t1, s0, 0xF

    #-- Cuando sean cero, hemos terminado la linea
    #-- De lo contrario seguimos imprimiendo bytes
    bne t1, zero, _dump16_loop

    #-- Hemos llegado a 16 bytes (linea completa)
    #-- Imprimir un salto de linea
    li a0, '\n'
    jal putchar 

    li a0, '\r'
    jal putchar

    #-- Se ha completado un bloque. Queda uno menos
    addi s1, s1, -1

    #-- Si quedan todavia bloques por volcar, repetir
    bne s1, zero, _dump16_loop

    #-- No quedan bloques... hemos terminado
    #-- Devolver la siguiente direccion
    mv a0, s0

    lw s1, 4(sp)
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp,sp, 16
    ret
