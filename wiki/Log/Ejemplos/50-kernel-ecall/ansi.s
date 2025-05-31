#---------------------------
#-- Funciones de interfaz 
#---------------------------
.global ansi_cls
.global ansi_color


#-----------------------------
#-- Cadenas de colores ansi 
#-----------------------------
.global RED, LRED
.global GREEN
.global YELLOW, LYELLOW
.global BLUE, LBLUE
.global MAGENTA
.global CYAN
.global WHITE

#--------------------
#-- Colores ANSI
#--------------------
.section .rodata

RED:     .string "\x1b[0;31m"
LRED:     .string "\x1b[1;31m"
GREEN:   .string "\x1b[0;32m"
YELLOW:  .string "\x1b[0;33m"
LYELLOW: .string "\x1b[1;33m"
BLUE:    .string "\x1b[0;34m"
LBLUE:   .string "\x1b[1;34m"
MAGENTA: .string "\x1b[0;35m"
CYAN:    .string "\x1b[0;36m"
WHITE:   .string "\x1b[0;37m"


#------ Secuencias de escape ANSI

#-- Borrar pantalla: ESC[H  ESC[2J
ESC_cls: .string "\x1b[H\x1b[2J"

#-- Establecer color: ESC[3 + color + m
ESC_color_prefix: .string "\x1b[3"


.section .text

#------------------------
#-- Borrar la pantalla 
#------------------------
ansi_cls:
    addi sp, sp, -16
    sw ra, 12(sp)

    la a0, ESC_cls
    jal print

    lw ra, 12(sp)
    addi sp, sp, 16
    ret

ansi_color:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)


    #-- Salvar el color
    mv s0, a0

    la a0, ESC_color_prefix
    jal print

    mv a0, s0
    jal print_hex4

    li a0, 'm'
    jal putchar

    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    ret
