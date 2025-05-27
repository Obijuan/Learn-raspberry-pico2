#---------------
#-- MACROS
#---------------

.macro DELAY_MS ms
    li a0, \ms
    jal delay_ms
.endm

