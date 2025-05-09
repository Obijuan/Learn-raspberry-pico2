
# -----------------------------------------------------------------------------
# Firma especial para que la pico2 reconozca este archivo como 
# un binario RISC-V.
# Debe estar situada en la primera sección de 4kb de la memoria
# -----------------------------------------------------------------------------

.p2align 8 

image_def:
.word 0xffffded3
.word 0x11010142
.word 0x00000344
.word _start
.word _stack_top
.word 0x000004ff
.word 0x00000000
.word 0xab123579
