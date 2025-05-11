
# -----------------------------------------------------------------------------
# Firma especial para que la pico2 reconozca este archivo como 
# un binario RISC-V.
# Debe estar situada en la primera sección de 4kb de la memoria
# -----------------------------------------------------------------------------

.section .boot

#-- Preambulo
.word 0xffffded3
.word 0x11010142
.word 0x00000344

.word _start        #-- Punto de entrada
.word __stack_top   #-- Cima de la pila

#-- Palabras de cierre
.word 0x000004ff
.word 0x00000000
.word 0xab123579
