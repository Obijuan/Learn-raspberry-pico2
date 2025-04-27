.global main      # Provide program starting address to linker

.equ SYSCTL_BASE,    0x40000000
.equ CLK_EN_REG,     SYSCTL_BASE + 0x100   # Clock enable register

.equ PAD_ISO_REG,    0x40038000 + 0x40   # Pad isolation control register for GPIO15

.equ IOMUX_BASE,     0x40028000
.equ IOMUX_GPIO15,   IOMUX_BASE + 0x7C     # IOMUX register for GPIO15

.equ SIO_BASE,       0xD0000000
.equ GPIO_OUT_REG,   SIO_BASE + 0x10       # GPIO output register
.equ GPIO_OUT_SET,   SIO_BASE + 0x14       # GPIO output set register
.equ GPIO_OUT_CLR,   SIO_BASE + 0x18       # GPIO output clear register
.equ GPIO_DIR_REG,   SIO_BASE + 0x30       # ✅ **Corrected: GPIO direction register**

.equ GPIO15_MASK,    (1 << 15)             # Bitmask for GPIO15


main:   


    # 1 Enable clock for GPIO peripheral (NOT NEEDED)
    ; li t0, CLK_EN_REG
    ; lw t1, 0(t0)         # Read current clock enable register
    ; li t2, 0x00000020    # Enable GPIO clock (check RP2350 datasheet)
    ; or t1, t1, t2
    ; sw t1, 0(t0)         # Write back to enable GPIO clock

    # 2 Configure IOMUX for GPIO15
    li t0, IOMUX_GPIO15
    lw t1, 0(t0)
    li t2, ~0x1F
    and t1, t1, t2   # clear it first
    ori t1, t1, 5        # Function 5 selects GPIO mode
    sw t1, 0(t0)         # Set IOMUX for GPIO15

    # 3 Set GPIO15 as an output
    li t0, GPIO_DIR_REG
    lw t1, 0(t0)         # Read current GPIO direction register
    li t2, GPIO15_MASK
    or t1, t1, t2
    sw t1, 0(t0)         # Set GPIO15 as output

    # 4 Clear Pad Isolation for GPIO
    li t0, PAD_ISO_REG
    lw t1, 0(t0)
    li t2, ~0x100
    and t1, t1, t2  # Clear GPIO15 isolation bit
    sw t1, 0(t0)

loop:
    # 5 Turn LED ON (Use SIO fast register access)
    li t0, GPIO_OUT_REG
    lw t1, 0(t0)        # Read current GPIO_OUT
    li t2, GPIO15_MASK
    or t1, t1, t2
    sw t1, 0(t0)        # Set GPIO15 high

    call delay

    # 6 Turn LED OFF
    li t0, GPIO_OUT_REG
    lw t1, 0(t0)
    li t2, ~GPIO15_MASK
    and t1, t1, t2
    sw t1, 0(t0)        # Set GPIO15 low

    call delay
    j loop

delay:
    li t0, 0xFFFFFF        # Simple delay loop
1:
    addi t0, t0, -1
    bnez t0, 1b
    ret


