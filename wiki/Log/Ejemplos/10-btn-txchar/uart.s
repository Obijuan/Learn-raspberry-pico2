#-----------------------------
#-- Funciones de interfaz  
#-----------------------------
.global uart_init
.global putchar

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
    li t0,GPIO00_CTRL
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
    