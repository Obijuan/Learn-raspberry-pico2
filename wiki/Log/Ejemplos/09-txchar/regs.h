.equ CLOCK_BASE,         0x40010000

.equ CLOCK_REF_CTRL,     0x40010030
  .equ CLK_REF_CTRL_XOR, 0x40011030
  .equ CLK_REF_CTRL_SET, 0x40012030
  .equ CLK_REF_CTRL_CLR, 0x40013030
.equ CLK_REF_DIV,        0x40010034
.equ CLK_REF_SELECTED,   0x40010038 

.equ CLK_SYS_CTRL,       0x4001003C
  .equ CLK_SYS_CTRL_XOR, 0x4001103C
  .equ CLK_SYS_CTRL_SET, 0x4001203C
  .equ CLK_SYS_CTRL_CLR, 0x4001303C
.equ CLK_SYS_DIV,        0x40010040
.equ CLK_SYS_SELECTED,   0x40010044

.equ CLK_PERI_CTRL,       0x40010048
  .equ CLK_PERI_CTRL_XOR, 0x40011048
  .equ CLK_PERI_CTRL_SET, 0x40012048
  .equ CLK_PERI_CTRL_CLR, 0x40013048
.equ CLK_PERI_DIV,        0x4001004C
.equ CLK_PERI_SELECTED,   0x40010050

.equ CLK_HSTX_CTRL,       0x40010054
  .equ CLK_HSTX_CTRL_XOR, 0x40011054
  .equ CLK_HSTX_CTRL_SET, 0x40012054
  .equ CLK_HSTX_CTRL_CLR, 0x40013054
.equ CLK_HSTX_DIV,        0x40010058
.equ CLK_HSTX_SELECTED,   0x4001005C   

.equ CLK_USB_CTRL,       0x40010060
  .equ CLK_USB_CTRL_XOR, 0x40011060
  .equ CLK_USB_CTRL_SET, 0x40012060
  .equ CLK_USB_CTRL_CLR, 0x40013060
.equ CLK_USB_DIV,        0x40010064

.equ CLK_ADC_CTRL,       0x4001006C
  .equ CLK_ADC_CTRL_XOR, 0x4001106C
  .equ CLK_ADC_CTRL_SET, 0x4001206C
  .equ CLK_ADC_CTRL_CLR, 0x4001306C
.equ CLK_ADC_DIV,        0x40010070

.equ CLK_SYS_RESUS_CTRL, 0x40010084



# -----------------------------------
# -- Registro de Control del Reset 
# -----------------------------------
# https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf#tab-registerlist_resets
# 
# * Bit 26: UART0
# -----------------------------------
.equ RESET_CTRL,     0x40020000
  .equ RESET_CTRL_XOR, 0x40021000
  .equ RESET_CTRL_SET, 0x40022000
  .equ RESET_CTRL_CLR, 0x40023000

# --- Valor del registro de reset
.equ RESET_UART0,   BIT26
.equ RESET_PLL_SYS, BIT14
.equ RESET_PLL_USB, BIT15

# -----------------------------------
# -- Registro de Status del reset
# -- Pone a 1 el bit correspondiente
# -- cuando el periférico se ha reseteado 
# -----------------------------------
.equ RESET_DONE, 0x40020008

.equ SRAM_BASE,             0x20000000
.equ UART0_BASE,            0x40070000

#-- Registro de datos de la uart
.equ UART0_UARTDR,          0x40070000

#-- Registro flags de la UART
.equ UART0_UARTF,           0x40070018

  #-- Transmisor ocupado
  .equ TXFF, 0x20

.equ UART0_UARTIBRD,        0x40070024
.equ UART0_UARTFBRD,        0x40070028
.equ UART0_UARTLCR_H,       0x4007002C
  .equ UART0_UARTLCR_H_XOR, 0x4007102C
.equ UART0_UARTCR,          0x40070030 
.equ UART0_UARTDMACR,       0x40070048

.equ UART1_BASE,     0x40078000

#-- Crystal oscillator
.equ XOSC_BASE,    0x40048000
.equ XOSC_CTRL,    0x40048000
  .equ XOSC_CTRL_SET,0x4004A000

.equ XOSC_STATUS,  0x40048004
.equ XOSC_STARTUP, 0x4004800C

.equ PLL_SYS_BASE,      0x40050000 
.equ PLL_SYS_CR,        0x40050000
.equ PLL_SYS_PWR,       0x40050004
  .equ PLL_SYS_PWR_CLR, 0x40053004
.equ PLL_SYS_FBDIV_INT, 0x40050008
.equ PLL_SYS_PRIM,      0x4005000C

.equ PLL_USB_BASE,      0x40058000
.equ PLL_USB_CR,        0x40058000
.equ PLL_USB_PWR,       0x40058004
  .equ PLL_USB_PWR_CLR, 0x4005B004
.equ PLL_USB_FBDIV_INT, 0x40058008
.equ PLL_USB_PRIM,      0x4005800C



.equ USBCTRL_REGS_BASE, 0x50110000
.equ USB_SIE_CTRL,      0x5011004c
.equ USB_SIE_CTRL_SET,  0x5011204c
