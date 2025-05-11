.macro CLS
    jal ansi_cls
.endm

.macro CPRINT color, cadena
    la a0, \color
    jal print
    la a0, \cadena
    jal print
.endm

.macro CPRINT0x color, cadena
    la a0, \color
    jal print
    la a0, \cadena
    jal print_0x_hex32
.endm
