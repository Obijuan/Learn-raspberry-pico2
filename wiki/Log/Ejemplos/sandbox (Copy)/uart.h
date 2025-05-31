#-----------------------
#-- Macros
#-----------------------

#-- Imprimir un salto de linea
.macro NL
    li a0, '\n'
    jal putchar
.endm

#-- Imprimir un caracter
.macro PUTCHAR car
    li a0, \car
    jal putchar
.endm

#-------------------------
#-- Imprimir una cadena 
#-------------------------
#-- Ejemplo: PRINT "Hola"
#-------------------------
.macro PRINT str
    .section .rodata
1: .string "\str"

    .section .text
    la a0, 1b
    jal print
.endm

