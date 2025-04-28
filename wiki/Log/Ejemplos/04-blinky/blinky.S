 # ----------------------------------------------
 # -- Parpadeo del LED, mediante espera activa 
 # ----------------------------------------------

# -- Se debe incluir para generar una imagen válida
.include "boot.h"

.section .text

# -- Punto de entrada
.global _start
_start:
    
    #-- Configurar el LED
    jal config_led    

loop:
    # -- Encender el LED
    jal led_on

    # -- Esperar
    jal delay

    # -- Apagar el LED
    jal led_off

    # -- Esperar
    jal delay

    # -- Repetir
    j loop
   


