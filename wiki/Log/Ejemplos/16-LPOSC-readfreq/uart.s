#-----------------------------
#-- Funciones de interfaz  
#-----------------------------
.global uart_init
.global putchar
.global getchar
.global print_raw8
.global print_raw16
.global print_raw32

.include "regs.h"

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
