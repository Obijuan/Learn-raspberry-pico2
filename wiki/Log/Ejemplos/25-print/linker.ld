    OUTPUT_ARCH(riscv)
    ENTRY(_start)

    MEMORY {
        FLASH (rx)  : ORIGIN = 0x10000000, LENGTH = 2M
        RAM   (rwx) : ORIGIN = 0x20000000, LENGTH = 256K
    }

    SECTIONS {
        .text : {
            *(.text*)
        } > FLASH

        .rodata : {
            *(.rodata*)
        } >  FLASH

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