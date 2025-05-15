    OUTPUT_ARCH(riscv)
    ENTRY(_start)

    /*  Direcciones de memoria */
    MEMORY {
        FLASH (rx)  : ORIGIN = 0x10000000, LENGTH = 2M
        RAM   (rwx) : ORIGIN = 0x20000000, LENGTH = 256K
    }


    /*  Secciones de salida  */
    SECTIONS {

        /* Codigo. Se situa en la memoria Flash */
        /* Contiene codigo y valores de variables de solo lectura */
        TEXT : {
            /* Etiqueta que contiene la direccion inicial de la flash */
            __flash_ini = .;

            /* Colocar la tabla de vectores de interrupcion */
            *(.vector)

            /* Colocar primero la seccion .boot */
            *(.boot*)

            /* Colocar despues las secciones .text de todos los ficheros */
            *(.text*)

            /* Obtener la direccion del comienzo de las variables de
               solo lectura                                          */
            __flash_ro_vars = .;

            /* Tras el codigo poner los valores de las           */
            /* variables de solo lectura de todos los ficheros   */
            *(.rodata*)

            /* Obtener la direccion del final del programa */
            __flash_end = .;  
        } > FLASH

        /* Datos inicializados
           Los valores de las variables estan guardados en la flash
           Antes de empezar el programa se deben copiar a la ram
           El linker calcula las direccion de memoria RAM
        */
        DATA : {

            /* Obtener la direccion de la flash donde comienzan los datos 
               que deben ser copiados en la ram  */
		    __data_flash_ini = LOADADDR(DATA);

            /* Obtener la direccion de la ram donde comienzan los datos */
		    __data_ram_ini = .;

            /* Situar las secciones .data de todos los ficheros */
		    *(.data)

            /* Obtener la direccion de ram donde finalizan los datos */
		    __data_ram_end = .;

	    } > RAM AT> FLASH
        /* La seccion DATA está en la memoria RAM, PERO su origen es la flash */


        /* Seccion con las VARIABLES NO INICIALIZADAS */
        BSS : {

            /* Obtener la direccion de comienzo de las variables no inicializadas  */
            __var_no_init = .;

            /* Colocar las secciones .bss de todos los ficheros */
            *(.bss*)

            /* Obtener la direccion del final de la ram */
            __data_end = .;
        } > RAM

        /* Seccion para la pila. Está solo en la RAM, y no tiene que ser 
           inicializada con ningun valor. Por eso tiene NOLOAD            */
        STACK (NOLOAD) : {

            /* Debe comenzar en una direccion alineada a doble palabra
               Es decir, que su direccion sea multiplo de 8             */
            . = ALIGN(8);

            /* Obtener la direccion de la cima de la pila */
            __stack_top = . + 4K; /* 4KB stack */
        } > RAM
    }