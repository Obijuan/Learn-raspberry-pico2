#---------------------------
#-- Funciones de interfaz 
#---------------------------
.global ansi_cls


#------------------------------
#-- Variables de solo lectura 
#------------------------------
.section .rodata

#------ Secuencias de escape ANSI

#-- Borrar pantalla: ESC[H  ESC[2J
ESC_cls: .string "\x1b[H\x1b[2J"


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
