#---------------------------
#-- Funciones de interfaz
#---------------------------
.global _start   #-- Punto de entrada

.section .text

# -- Punto de entrada
_start:

    #-- Configurar la pila
    la sp, __stack_top
       
    #-- Configurar el vector de interrupcion
    #-- (Trap vector). Modo directo
    la t0, isr
    csrw mtvec, t0

    #-- Inicializar LED
    jal led_init

    #-- Generar una llamada al sistema
    ecall

    #-- Encender el LED
    #-- Aquí no llega, porque se ha saltado a la 
    #-- Rutina de interrupcion (que nunca retorna)
    jal led_on
    j .


#----------------------------------
#-- Atención a las Interrupciones
#----------------------------------
isr:
    #-- Hacer parpadear el LED
    #-- No se retorna nunca
    jal led_blinky2

