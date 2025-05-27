#-----------------------------
#-- Funciones de interfaz  
#-----------------------------
.global uart_init
.global putchar
.global getchar
.global print_raw8
.global print_raw16
.global print_raw32
.global print_hex4
.global print_hex8
.global print_hex16
.global print_hex32
.global print_hex64
.global print_nl
.global print
.global print_0x_hex32
.global print_bin1
.global print_bin2


.include "riscv.h"
.include "regs.h"

.section .rodata
hex_prefix:  .string "0x"

.section .text

#--------------------------------
#-- Inicializar la UART
#---------------------------------
uart_init:

    #-- Activar reset de la uart0
    li t0,RESET_CTRL_SET  
    li t1,RESET_UART0
    sw t1,0(t0)

    #-- Desactivar el reset de la uart0
    li t0,RESET_CTRL_CLR
    sw t1,0(t0)

    #-- Esperar hasta que el reset termine
    li t0, RESET_DONE   #-- Registro de reset
    li t1, RESET_UART0  #-- Bit de reset de la uart0

wait_reset_done:
    lw t2,0(t0)      #-- Leer estado del reset
    and t2, t2, t1   #-- Aislar el bit de reset de la uart

    #-- Bit RESET_UART0 == 0? --> Esperar
    beq t2, zero, wait_reset_done

    #-- El bit RESET_UART0 del registro RESET_DONE está a 1
    #-- Significa que la UART0 está inicializada

    #-- Parte entera de los baudios (Integer Baudrate)
    li t0, UART0_UARTIBRD
    li t1, 0x51
    sw t1, 0(t0)

    #-- Parte fraccional de los baudios (Fractional baudrate)
    li t0, UART0_UARTFBRD
    li t1, 0x18
    sw t1, 0(t0) 

    #-- Configurar UART
    #-- 8bits de datos. Sin paridad
    li t0, UART0_UARTLCR_H
    li t1, 0xE0
    sw t1,0(t0)

    #-- Habilitar la UART
    #-- Habilitar transmisor
    #-- Habilitar receptor
    li t0, UART0_UARTCR
    li t1,0x301
    sw t1,0(t0)

    #--------- Configurar pin TX UART0
    #-- Configurar el PAD del GPIO0
    li t0, PAD_GPIO0
    li t1, 0x56
    sw t1,0(t0)

    #-- Asignar el GPIO0 al pin tx de la UART0
    li t0,GPIO0_CTRL
    li t1, 2
    sw t1,0(t0)

    #--------- Configurar pin RX UART0
    #-- Configurar el PAD del GPIO1
    li t0, PAD_GPIO1
    li t1, 0x0CB
    sw t1,0(t0)

    #-- Asignar el GPIO0 al pin tx de la UART0
    li t0,GPIO1_CTRL
    li t1, 2
    sw t1,0(t0)
    ret

# --------------------------------------------
# -- Putchar(c)
# --------------------------------------------
# -- Enviar un caracter por el puerto serie
# -- ENTRADAS:
# --   -a0: Caracter a enviar
# --------------------------------------------
print_raw8:
putchar:

   #-- Esperar a que el transmisor esté listo
wait_tx:
    li t0, UART0_UARTF
    lw t1, 0(t0)  
    andi t1,t1,TXFF

    #-- ¿Bit TXFF==1? (Ocupado), esperar
    bne t1, zero, wait_tx

    #-- Transmitir!
    li t0,UART0_UARTDR
    sw a0,0(t0)

    ret
    

# --------------------------------------
# -- Getchar(c)
# --------------------------------------
# -- Leer un carácter del puerto serie
# -- Es bloqueante (se queda esperando  
# -- a que llegue un carácter)
# -------------------------------------- 
getchar:

    #-- Esperar a que llegue un carácter
wait_rx:
    li t0, UART0_UARTF
    lw t1, 0(t0)  
    andi t1,t1,RXFF

    #-- ¿Bit RXFF==1? (sin caracter), esperar
    bne t1, zero, wait_rx

    #-- Leer dato recibido
    li t0,UART0_UARTDR
    lw a0, 0(t0)

    #-- Retornar
    ret

    
# ---------------------------------------------------------
# -- print_raw16:
# --   Imprmir una media palabra (16-bits) en la consola
# --  Se envia en BIG ENDIAN
# ---------------------------------------------------------
print_raw16:
    addi sp,sp,-16
    sw ra, 12(sp)
    sw s0, 8(sp)

    mv s0, a0

    #-- La media palabra está computa de 2 bytes: byte1 byte0
    #-- El byte1 es el de mayor peso

    #----- Print byte1:
    #-- Desplazar valor 8 bits a la derecha
    #-- para obtener byte1
    srli a0, s0, 8
    jal print_raw8

    #-- Print byte0
    mv a0, s0
    jal print_raw8

    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp,sp,16
    ret


# ---------------------------------------------------------
# -- print_raw32:
# --   Imprmir una palabra (32-bits) en la consola
# --  Se envia en BIG ENDIAN
# ---------------------------------------------------------
print_raw32:
    addi sp,sp,-16
    sw ra, 12(sp)
    sw s0, 8(sp)

    mv s0, a0

    #-- Las palabras están compuestas por 2 medias palabras
    #-- half1 half0

    #-- Imprimir half1
    mv a0, s0
    srl a0, s0, 16
    jal print_raw16

    #-- Imprimir half0
    mv a0, s0
    jal print_raw16

    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp,sp,16
    ret

# ------------------------------------------------
# -- Print_hex4
# -- Imprimir un numero de 4 bits en hexadecimal  
# ------------------------------------------------
# -- ENTRADAS:
# -- a0: Numero a imprimir (nibble)
# ------------------------------------------------
print_hex4:
    addi sp, sp, -16
    sw ra, 12(sp)

    #-- Eliminamos todos los bits de mayor peso,
    #-- para aislar el nibble
    andi a0, a0, 0xF

    #-- Comprobar si el numero está entre 0 - 9
    li t0, 9
    bgt a0, t0, _range_a_f

    #-- El numero está en el rango [0,9]
    #-- Para imprimirlo hay que sumar '0'
    addi a0, a0, '0'

    #-- Imprimr el digito!
    j _print

_range_a_f:
    #-- El caracter esta en el rango a - f
    #-- Hay que sumarle 'A'
    addi a0, a0, ('A'-10)

_print:
    #-- Imprimir el digito
    jal putchar

    lw ra, 12(sp)
    addi sp, sp, 16
    ret


# ------------------------------------------------
# -- Print_hex8
# -- Imprimir un numero de 8 bits en hexadecimal  
# ------------------------------------------------
# -- ENTRADAS:
# -- a0: Numero a imprimir (byte)
# ------------------------------------------------
print_hex8:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)

    #-- Guardar el numero original
    mv s0, a0

    #------ Imprimir el nibble1
    # -- Imprimir a0 >> 4
    srli a0,a0,4
    jal print_hex4
    
    #-- Imprimir el nibble0
    mv a0, s0
    jal print_hex4

    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    ret


# ------------------------------------------------
# -- Print_hex16
# -- Imprimir un numero de 16 bits en hexadecimal  
# ------------------------------------------------
# -- ENTRADAS:
# -- a0: Numero a imprimir (media palabra)
# ------------------------------------------------
print_hex16:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)

    #-- Guardar el numero original
    mv s0, a0

    #---- Una palabra está formada por dos bytes: byte 1 | byte 0
    #------ Imprimir el byte1
    # -- Imprimir a0 >> 8
    srli a0,a0,8
    jal print_hex8
    
    #-- Imprimir el byte1
    mv a0, s0
    jal print_hex8

    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    ret


# ------------------------------------------------
# -- Print_hex32
# -- Imprimir un numero de 32 bits en hexadecimal  
# ------------------------------------------------
# -- ENTRADAS:
# -- a0: Numero a imprimir (palabra)
# ------------------------------------------------
print_hex32:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)

    #-- Guardar el numero original
    mv s0, a0

    #---- Una palabra está formada por dos medias palabras: half1 | half0
    #------ Imprimir half1
    # -- Imprimir a0 >> 16
    srli a0,a0,16
    jal print_hex16
    
    #-- Imprimir half0
    mv a0, s0
    jal print_hex16

    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

# ------------------------------------------------
# -- Print_hex64
# -- Imprimir un numero de 64 bits en hexadecimal  
# ------------------------------------------------
# -- ENTRADAS:
# -- a0: Numero a imprimir (Parte baja)
# -- a1: Numero a imprimir (Parte alta)
# ------------------------------------------------
print_hex64:
FUNC_START4

    #-- Guardar registro s0
    sw s0, 8(sp)

    #-- Guardar la parte baja
    mv s0, a0

    #-- Imprimir la parte alta
    mv a0, a1
    jal print_hex32

    #-- Imprimir un guion
    li a0, '-'
    jal putchar

    #-- Imprimir la parte baja
    mv a0, s0
    jal print_hex32

    lw s0, 8(sp)
FUNC_END4


# -------------------------------------------------------
# -- Print_0x_hex32
# -- Imprimir un numero hexadecimal con el prefijo '0x'
# -------------------------------------------------------
# ENTRADAS:
#  - a0:  Palabra a imprimir en hexa
# -------------------------------------------------------
print_0x_hex32:
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)

    #-- Salvar el numero
    mv s0, a0

    #-- Imprimir el prefijo
    la a0, hex_prefix
    jal print

    #-- Imprimir el numero
    mv a0, s0
    jal print_hex32

    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    ret


#----------------------------
#-- Imprimir Salto de linea 
#----------------------------
print_nl:
    addi sp, sp, -16
    sw ra, 12(sp)

    li a0, '\n'
    jal putchar

    li a0, '\r'
    jal putchar

    lw ra, 12(sp)
    addi sp, sp, 16
    ret
    
# ---------------------------------------------
# -- Print: Imprimir una cadena en la consola 
# ---------------------------------------------
# -- ENTRADAS:
# --   a0: Direccion de la cadena a imprimir
# ---------------------------------------------
print:
    addi sp,sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)

    #-- PUntero a la cadena
    mv s0, a0

_print_loop:
    #-- Leer caracter actual
    lb a0, 0(s0)

    #-- Si es 0, hemos terminado
    beq a0, zero, _print_end

    #-- Imprimir el caracter
    jal putchar

    #-- Apuntar al siguiente byte
    addi s0, s0, 1

    #-- Repetir
    j _print_loop


_print_end:
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp,sp, 16
    ret

#--------------------------------------------------------------
#-- print_bin1. Imprimir un numero binario de 1 bit
#--------------------------------------------------------------
#-- ENTRADAS:
#-- a0: Numero a imprimir. Solo se toma el bit de menor peso 
#--------------------------------------------------------------
print_bin1:
FUNC_START4

    #--- Solo se tiene en cuenta el bit de menor peso
    #--- Poner a cero el resto
    andi a0, a0, 0x1

    #-- Convertir el numero a digito (0 ó 1)
    addi a0, a0, '0'

    #-- Imprimir el digito
    jal putchar

FUNC_END4

#------------------------------------------------------------------
#-- print_bin2. Imprimir un numero binario de 2 bits
#------------------------------------------------------------------
#-- ENTRADAS:
#-- a0: Numero a imprimir. Solo se toman los 2 bits de menor peso 
#------------------------------------------------------------------
print_bin2:
FUNC_START4
    sw s0, 8(sp)

    #-- Imprimir bit de mayor peso
    mv s0, a0
    srl a0, a0, 1
    jal print_bin1

    #-- Imprimir bit de menor peso
    mv a0, s0
    jal print_bin1

    lw s0, 8(sp)
FUNC_END4
