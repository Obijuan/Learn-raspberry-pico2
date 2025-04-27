.global main

# ----------------------------------------------
# -- Registro de control del GPIO15
.equ GPIO15_CTRL, 0x4002807C

# -- Habilitación del pin GPIO15
.equ GPIO15_PAD_ISO, 0x40038040

# -- Registro de configuración de la direcion (salida/entrada)
.equ GPIO_OE, 0xD0000030

# -- Registro de salida del GPIO
.equ GPIO_OUT, 0xD0000010

main:   

    #-- Configuracion de GPIO15 para controlarse por software
    li t0, GPIO15_CTRL  #-- Direccion
    li t1, 0x5          #-- Funcion: SIO. Control por software
    sw t1, 0(t0)        #-- Escribir en el registro de control

    #-- Configuracion de GPIO15 como salida
    li t0, GPIO_OE      #-- Direccion
    li t1, 0x00008000   #-- Poner bit 15 a 1: Salida. Esto a 0: entradas
    sw t1, 0(t0)        #-- Configurar el pin como salida

    #-- Habilitar el pin GPIO15
    li t0, GPIO15_PAD_ISO  #-- Direccion
    li t1, 0x016   #-- Apagar bit 8: ISO, dejar el resto con su estado inicial
    sw t1, 0(t0)        #-- Habilitar el pin GPIO15

loop:

    # -- Encender el LED
    li t0, GPIO_OUT
    li t1, 0x00008000  #-- Activar el bit 15
    sw t1, 0(t0)       #-- Escribir!

    j loop



