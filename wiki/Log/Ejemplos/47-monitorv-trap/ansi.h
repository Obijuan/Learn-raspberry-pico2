#----------------------------------------------------
#- MACROS
#----------------------------------------------------

#-----------------------
#-- Borrar la pantalla 
#-----------------------
.macro CLS
    jal ansi_cls
.endm


#------------------------------------------
#-- Imprimir un numero hexadecimal con 
#-- el prefijo '0x', en color
#-- Se pasa como argumentos las etiquetas
#-- del color y el numero a imprimir
#------------------------------------------
#-- Ejemplo:  CPRINT0x YELLOW, __flash_ini
#------------------------------------------
.macro CPRINT0x color, etiq_num
    la a0, \color
    jal print
    la a0, \etiq_num
    jal print_0x_hex32
.endm

#-----------------------------------
#-- Imprimir una cadena en color
#-----------------------------------
#-- Ejemplo:  CPRINT YELLOW, "Hola"
#-----------------------------------
.macro CPRINT color, str
    .section .rodata
1:  .string "\str"

    .section .text
    la a0, \color
    jal print
    la a0, 1b
    jal print
.endm

#-----------------------------------
#-- Establecer el color actual
#-----------------------------------
#-- Ejemplo: COLOR YELLOW
#-----------------------------------
.macro COLOR color
  la a0, \color
  jal print
.endm
