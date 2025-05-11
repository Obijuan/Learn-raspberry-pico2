#----------------------------------------------------
#- MACROS
#----------------------------------------------------


#-----------------------
#-- Borrar la pantalla 
#-----------------------
.macro CLS
    jal ansi_cls
.endm

#---------------------------------
#- Imprimir una cadena en color 
#---------------------------------
.macro CPRINT color, cadena
    la a0, \color
    jal print
    la a0, \cadena
    jal print
.endm

#---------------------------------------
#-- Imprimir un numero hexadecimal con 
#-- el prefijo '0x', en color
#---------------------------------------
.macro CPRINT0x color, cadena
    la a0, \color
    jal print
    la a0, \cadena
    jal print_0x_hex32
.endm
