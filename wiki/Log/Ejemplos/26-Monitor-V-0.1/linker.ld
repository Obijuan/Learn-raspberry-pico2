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

            /* Colocar primero las secciones .text de todos los ficheros */
            *(.text*)

            /* Tras el codigo poner los valores de las           */
            /* variables de solo lectura de todos los ficheros   */
            *(.rodata*)  
        } > FLASH

        DATA : {
		    __data_flash_ini = LOADADDR(DATA);
		    __data_ram_ini = .;
		    *(.data)
		    __data_ram_end = .;
	    } > RAM AT> FLASH


        .bss : {
            *(.bss*)
        } > RAM

        .stack (NOLOAD) : {
            . = ALIGN(8);
            _stack_top = . + 4K; /* 4KB stack */
        } > RAM
    }