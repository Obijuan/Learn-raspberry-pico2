
.include "boot.h"
.include "regs.h"

.section .data
v1:  .word 0xCACABACA

.section .text

# -- Punto de entrada
.global _start
_start:

    #-- Inicializar la pila
    la sp, _stack_top

    #-- Inicializar el sistema
    jal	runtime_init

    #-- Copiar los valores iniciales
    #-- de las variables

    #-- Configurar el LED
    jal led_init

    #-- Inicializar la UART
    #-- Velocidad: 115200 (con runtime actual)
    jal uart_init 

    #-- Encender el LED
    jal led_on

    la s0, __data_flash_ini
    la s1, __data_ram_ini
    la s2, __data_ram_end

    mv a0, s0
    jal print_hex32
    jal print_nl

    mv a0, s1
    jal print_hex32
    jal print_nl

    mv a0, s2
    la a0, __data_ram_end
    jal print_hex32
    jal print_nl

    #-- Inicializar las variables
init_vars:
    #-- Comprobar si la direccion actual destino ha alcanzado el limite
    #-- Si es asi hemos terminado
    beq s1, s2, main

    #-- Leer palabra de la flash
    lw t3, 0(s0)

    #-- Copiarla en la RAM
    sw t3, 0(s1)

    #-- Incrementar las direcciones
    addi s0, s0, 4
    addi s1, s1, 4

    #-- Repetir
    j init_vars


main: 
    #--- Imprimir variable v1 (Palabra)
    la t0, v1
    lw a0, 0(t0)     #-- Leer variable
    jal print_hex32  #-- Imprimir

    #--- Salto de linea
    jal print_nl

    #-- Esperar a que se reciba un caracter
    jal getchar

    #-- Cambiar estado del led
    jal led_toggle

    j main

