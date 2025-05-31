#---------------------
#-- MACROS
#---------------------

#--- Configurar un LED
.macro LED_INIT led
    li a0, \led
    jal ledn_init
.endm

#--- Encender un led
.macro LED_ON led
    li a0, \led
    jal ledn_on
.endm

#-- Apagar un led
.macro LED_OFF led
    li a0, \led
    jal ledn_off
.endm

#-- Cambiar de estado un led
.macro LED_TOGGLE led
    li a0, \led
    jal ledn_toggle
.endm   

