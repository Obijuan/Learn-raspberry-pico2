#--------------------------
#-- Funciones de interfaz
#--------------------------
.global isr_monitor
.global monitorv_trap

.include "riscv.h"
.include "regs.h"
.include "uart.h"
.include "ansi.h"

.section .data
modo: .word 0

.section .text


#--------------------------------------
#-- Arranque de la aplicacion
#--------------------------------------
monitorv_trap:
    #-- Por defecto estamos en modo M
    #-- Guardarlo en una variable
    la t0, modo
    li t1, MODO_MACHINE
    sw t1, 0(t0)

_menu:
    CLS
    PRINT "Test de interrupciones\n"
    jal print_modo
    PRINT "1.- Ecall\n"
    PRINT "2.- Instruccion ilegal\n"
    PRINT "3.- BREAKPOINT\n"
    PRINT "4.- LOAD en direccion NO alineada\n"
    PRINT "5.- STORE en direccion NO alineada\n"
    PRINT "6.- Pasar a modo usuario\n"
    PRINT "7.- Acceso a memoria no permitida (Lectura)\n"
    PRINT "8.- Acceso a memoria no permitida (Escritura)\n"

prompt:
    PRINT "> "
    jal getchar

    #-- Salvar la tecla
    mv s0, a0

    #-- Eco de al tecla
    jal putchar
    PUTCHAR '\n'

    #-- Recuperar tecla
    mv a0, s0

    li t0, ' ' 
    beq a0, t0, _menu

    li t0, '1'
    beq a0, t0, opcion1

    li t0, '2'
    beq a0, t0, opcion2

    li t0, '3'
    beq a0, t0, opcion3

    li t0, '4'
    beq a0, t0, opcion4

    li t0, '5'
    beq a0, t0, opcion5

    li t0, '6'
    beq a0, t0, opcion6

    li t0, '7'
    beq a0, t0, opcion7

    li t0, '8'
    beq a0, t0, opcion8

    j prompt


opcion1:
    ecall
    j prompt

opcion2:
    .word 0  #-- Instruccion ilegal
    j prompt

opcion3:
    ebreak
    j prompt

opcion4:
    li t0, 1
    lw t0, 0(t0)  #-- Acceso a direccion no alineada
    j prompt

opcion5: 
    li t0, 1
    sw zero, 0(t0) #-- Acceso a direccion no alineada
    j prompt

opcion6:
    #------- PASAR A MODO USUARIO
    jal print_mstatus    

    #-- Poner a 0 bits del campo MPP
    #-- Para que el modo de privilegio sea de usuario
    csrw mstatus, zero

    #-- Meter en mepc la direccion de retorno
    la t0, user_mode_entry
    csrw mepc, t0

    #-- Saltar a modo usuario
    mret 

opcion7:
    PRINT "LEYENDO MEMORIA PROTEGIDA...\n"
    #-- Acceso a memoria no permitida
    #-- Vamos a leer un registro de la UART1
    li t0, UART1_UARTF
    lw t1, 0(t0)  #-- Acceso a un registro no permitido

opcion8:
    PRINT "ESCRIBIENDO MEMORIA PROTEGIDA...\n"

    li t0, UART1_UARTDR
    li t1, 'A'
    sw t1, 0(t0)  #-- Acceso a un registro no permitido

    j prompt


#------------------------------
# Código en modo usuario
#------------------------------
user_mode_entry:

    PRINT "MODO USUARIO!\n"

    #-- Cambiar la variable a MODO_USER
    la t0, modo
    li t1, MODO_USER
    sw t1, 0(t0)

    j prompt


#-------------------------------
#-- Imprimir el modo actual
#-------------------------------
print_modo:
FUNC_START4

    PRINT "Modo actual: "

    #-- Leer el modo actual
    la t0, modo
    lw t1, 0(t0)

    #-- Comprobar su valor
    li t2, MODO_USER
    beq t1, t2, _modo_user

    li t2, MODO_MACHINE
    beq t1, t2, _modo_machine

    PRINT "DESCONOCIDO\n"
    j print_modo_end

_modo_user:
    PRINT "USUARIO\n"
    j print_modo_end

_modo_machine:
    PRINT "MAQUINA\n"
    j print_modo_end

print_modo_end:
    NL
FUNC_END4






#------------------------------------------
#-- Rutina de atencion a la interrupcion 
#------------------------------------------
isr_monitor:

    #--- Guardar el contexto
    #-- Todos los registros menos x2 (sp) y x0 (zero)
    addi sp, sp, -128  
    sw x0, 0(sp)    #-- Guardar x0 (No necesario). Hecho asi por simetria... 
    sw x1, 4(sp)    #-- Guardar x1
    sw x3, 12(sp)   #-- Guardar x3
    sw x4, 16(sp)   #-- Guardar x4
    sw x5, 20(sp)   #-- Guardar x5
    sw x6, 24(sp)   #-- Guardar x6
    sw x7, 28(sp)   #-- Guardar x7
    sw x8, 32(sp)   #-- Guardar x8
    sw x9, 36(sp)   #-- Guardar x9
    sw x10, 40(sp)  #-- Guardar x10
    sw x11, 44(sp)  #-- Guardar x11
    sw x12, 48(sp)  #-- Guardar x12
    sw x13, 52(sp)  #-- Guardar x13
    sw x14, 56(sp)  #-- Guardar x14
    sw x15, 60(sp)  #-- Guardar x15
    sw x16, 64(sp)  #-- Guardar x16
    sw x17, 68(sp)  #-- Guardar x17
    sw x18, 72(sp)  #-- Guardar x18
    sw x19, 76(sp)  #-- Guardar x19
    sw x20, 80(sp)  #-- Guardar x20
    sw x21, 84(sp)  #-- Guardar x21
    sw x22, 88(sp)  #-- Guardar x22
    sw x23, 92(sp)  #-- Guardar x23
    sw x24, 96(sp)  #-- Guardar x24
    sw x25, 100(sp) #-- Guardar x25
    sw x26, 104(sp) #-- Guardar x26
    sw x27, 108(sp) #-- Guardar x27
    sw x28, 112(sp) #-- Guardar x28
    sw x29, 116(sp) #-- Guardar x29
    sw x30, 120(sp) #-- Guardar x30
    sw x31, 124(sp) #-- Guardar x31


    CPRINT RED, "----> Interrupción!\n"
    jal print_mstatus
    #--- Lo primero que hacemos es averiguar la causa de la 
    #--- interrupción
    #--- eso se encuentra en el registro mcause
    jal print_mcause

    #-- Leer causa
    csrr a0, mcause

    #-- Comprobar si la causa es por una excepcion
    #-- o por una interrupcion
    #-- Esto se hace comprobando el bit INT (el de mayor peso)
    bge a0, zero, es_excepcion

    #-- Es una interrupcion
    PRINT "TIPO: Interrupcion\n"
    PRINT "Desconocida...\n"
    jal led_blinky3

es_excepcion:
    PRINT "TIPO: Excepcion\n"

    #-- Comprobar qué tipo de excepcion es
    csrr t0, mcause

    #-- Aislar la causa
    andi t0, t0, 0xF
    
    li t1, ECALL_M
    beq t0, t1, es_ecall_m

    li t1, ECALL_U
    beq t0, t1, es_ecall_u

    li t1, ILEGAL_INST
    beq t0, t1, excep_ilegal_inst

    li t1, BREAKPOINT
    beq t0, t1, es_ebreak

    li t1, NOT_ALIGN_LOAD
    beq t0, t1, excep_not_align_load

    li t1, NOT_ALIGN_STORE
    beq t0, t1, excep_not_align_store

    li t1, INST_FAULT
    beq t0, t1, excep_inst_fault

    li t1, LOAD_FAULT
    beq t0, t1, excep_load_fault

    li t1, STORE_FAULT
    beq t0, t1, excep_store_fault

    #-- Causa desconocida
    PRINT "Desconocida\n"
    jal led_blinky3

#---- La excepcion es debida a ecall
es_ecall_m:

    PRINT "ECALL desde modo M\n\n"
    j isr_end

es_ecall_u:
    PRINT "ECALL desde modo U\n\n"
    j isr_end

es_ebreak:
    PRINT "EBREAK\n\n"
    j isr_end

#--- La excepcion es por instruccion ilegal
excep_ilegal_inst:
    PRINT "INSTRUCCION ILEGAL\n\n"
    j isr_end

#--- La excepcion es por error de alineamiento
excep_not_align_load:
    PRINT "ERROR DE ALINEAMIENTO EN LECTURA\n\n"
    j isr_end

#--- Error de alineamiento en store
excep_not_align_store:
    PRINT "ERROR DE ALINEAMIENTO EN ESCRITURA\n\n"
    j isr_end

#-- Instruction fault
excep_inst_fault:
    PRINT "FALLO EN INSTRUCCION\n"

    #-- Imprimir mepc: es la instruccion que causo el fallo
    csrr a0, mepc
    jal print_0x_hex32
    NL
    jal led_blinky3

#-- Load fault
excep_load_fault:
    PRINT "LOAD FAULT: No se tiene permisos para LEER!\n"
    j isr_end

#-- Store fault
excep_store_fault:
    PRINT "STORE FAULT: No se tiene permisos para ESCRIBIR!\n"
    j isr_end

isr_end:
    #-- TERMINAR---------------------------
    #--- Leer la direccion de retorno
    csrr t0, mepc

    #-- Incrementar la direccion en 4 para retornar a la
    #-- siguiente instruccion a ecall
    addi t0, t0, 4
    csrw mepc, t0

    #-- Restaurar el contexto
    lw x1, 4(sp)    #-- Restaurar x1
    lw x3, 12(sp)   #-- Restaurar x3
    lw x4, 16(sp)   #-- Restaurar x4
    lw x5, 20(sp)   #-- Restaurar x5
    lw x6, 24(sp)   #-- Restaurar x6
    lw x7, 28(sp)   #-- Restaurar x7 
    lw x8, 32(sp)   #-- Restaurar x8
    lw x9, 36(sp)   #-- Restaurar x9
    lw x10, 40(sp)  #-- Restaurar x10
    lw x11, 44(sp)  #-- Restaurar x11
    lw x12, 48(sp)  #-- Restaurar x12
    lw x13, 52(sp)  #-- Restaurar x13
    lw x14, 56(sp)  #-- Restaurar x14
    lw x15, 60(sp)  #-- Restaurar x15
    lw x16, 64(sp)  #-- Restaurar x16
    lw x17, 68(sp)  #-- Restaurar x17
    lw x18, 72(sp)  #-- Restaurar x18
    lw x19, 76(sp)  #-- Restaurar x19
    lw x20, 80(sp)  #-- Restaurar x20
    lw x21, 84(sp)  #-- Restaurar x21
    lw x22, 88(sp)  #-- Restaurar x22
    lw x23, 92(sp)  #-- Restaurar x23
    lw x24, 96(sp)  #-- Restaurar x24
    lw x25, 100(sp) #-- Restaurar x25
    lw x26, 104(sp) #-- Restaurar x26
    lw x27, 108(sp) #-- Restaurar x27
    lw x28, 112(sp) #-- Restaurar x28
    lw x29, 116(sp) #-- Restaurar x29
    lw x30, 120(sp) #-- Restaurar x30
    lw x31, 124(sp) #-- Restaurar x31
    addi sp, sp, 128       

    #-- Retornar
    mret
