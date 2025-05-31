#--------------------------
#-- FUNCIONES DE INTERFAZ
#--------------------------
.global add64

#-------------------------------------------------
#-- Sumar dos numeros de 64 bits
#-------------------------------------------------
#-- ENTRADAS:
#--  -Primer numero:
#--     a1: Parte alta
#--     a0: Parte baja
#--  -Segundo numero:
#--     a3: Parte alta
#--     a2: Parte baja
#-- SALIDA:
#--  - a1: Parte alta
#--  - a0: Parte baja
#--------------------------------------------------
add64:
    #-- Sumar bytes de menor peso (a0 + a2)
    add t0, a0, a2

    #-- Calcular el acarreo
    sltu t2, t0, a0  #-- Si t0 < a0, hay acarreo

    #-- Sumar la parte alta
    add t1, a1, a3

    #-- Sumar el acarreo
    add t1, t1, t2

    #-- Devolver resultado
    mv a1, t1
    mv a0, t0

    #-- Terminar
    ret
