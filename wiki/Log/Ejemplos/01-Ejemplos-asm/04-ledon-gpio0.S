.global main

# --------------------------------
# -- Registros de control del GPIO
# -------------------------------- 
.equ GPIO00_CTRL, 0x40028004
.equ GPIO15_CTRL, 0x4002807C

# -------------------------------
# -- Registros de los PADs
# -------------------------------
.equ GPIO00_PAD_ISO, 0x40038004
.equ GPIO15_PAD_ISO, 0x40038040

# --------------------------------------
# -- Registro de habilitacion de salida
# -- GPIOs de 0 a 31
# --------------------------------------
.equ GPIO_OE, 0xD0000030

# --------------------------------------
# -- Registro de salida
# -- GPIOs de 0 a 31
# --------------------------------------
.equ GPIO_OUT, 0xD0000010

main:   

    #-- Configuracion de GPIO0 para controlarse por software
    li t0, GPIO00_CTRL  
    li t1, 0x5          
    sw t1, 0(t0)        

    #-- Configuracion de GPIO0 como salida
    li t0, GPIO_OE      
    li t1, 1
    sw t1, 0(t0)        

    #-- Habilitar el pin GPIO0
    li t0, GPIO00_PAD_ISO  
    li t1, 0x016   #-- Apagar bit 8: ISO, dejar el resto con su estado inicial
    sw t1, 0(t0)

    # -- Encender el LED
    li t0, GPIO_OUT
    li t1, 1    #-- Activar el bit 0
    sw t1, 0(t0)  

    # -- FIN
inf:  j inf



