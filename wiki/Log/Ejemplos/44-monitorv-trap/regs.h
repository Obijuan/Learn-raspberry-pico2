# ----------------------------------------------
# -- Definiciones de las posiciones de los bits
# ----------------------------------------------
.equ BIT0,  (1 <<  0)  # 0x0000_0001
.equ BIT1,  (1 <<  1)  # 0x0000_0002
.equ BIT2,  (1 <<  2)  # 0x0000_0004
.equ BIT3,  (1 <<  3)  # 0x0000_0008
.equ BIT4,  (1 <<  4)  # 0x0000_0010
.equ BIT5,  (1 <<  5)  # 0x0000_0020
.equ BIT6,  (1 <<  6)  # 0x0000_0040
.equ BIT7,  (1 <<  7)  # 0x0000_0080
.equ BIT8,  (1 <<  8)  # 0x0000_0100
.equ BIT9,  (1 <<  9)  # 0x0000_0200
.equ BIT10, (1 << 10)  # 0x0000_0400
.equ BIT11, (1 << 11)  # 0x0000_0800
.equ BIT12, (1 << 12)  # 0x0000_1000
.equ BIT13, (1 << 13)  # 0x0000_2000
.equ BIT14, (1 << 14)  # 0x0000_4000
.equ BIT15, (1 << 15)  # 0x0000_8000
.equ BIT16, (1 << 16)  # 0x0001_0000
.equ BIT17, (1 << 17)  # 0x0002_0000
.equ BIT18, (1 << 18)  # 0x0004_0000
.equ BIT19, (1 << 19)  # 0x0008_0000
.equ BIT20, (1 << 20)  # 0x0010_0000
.equ BIT21, (1 << 21)  # 0x0020_0000
.equ BIT22, (1 << 22)  # 0x0040_0000
.equ BIT23, (1 << 23)  # 0x0080_0000
.equ BIT24, (1 << 24)  # 0x0100_0000
.equ BIT25, (1 << 25)  # 0x0200_0000
.equ BIT26, (1 << 26)  # 0x0400_0000
.equ BIT27, (1 << 27)  # 0x0800_0000
.equ BIT28, (1 << 28)  # 0x1000_0000
.equ BIT29, (1 << 29)  # 0x2000_0000
.equ BIT30, (1 << 30)  # 0x4000_0000
.equ BIT31, (1 << 31)  # 0x8000_0000



# ----------------------------------------------------------
# -- Registros de control del GPIO
# ---------------------------------------------------------- 
# -- La información sobre los registros de control se encuentra
# -- en la sección 9.11.1, página 601 del datasheet del RP2350
# -- https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf
#
# | 31 32 | 28:29  | 27:18 | 17:16  | 15:14  | 13:12   | 11:5 | 4:0     |
# | Res   | IRQOVER| Res   | INOVER | OEOVER | OUTOVER | Res  | FUNCSEL |

# -- Direcciones
.equ GPIO0_STATUS, 0x40028000
.equ GPIO0_CTRL,   0x40028004
.equ GPIO1_STATUS, 0x40028008
.equ GPIO1_CTRL,   0x4002800C
.equ GPIO15_CTRL,  0x4002807C
.equ GPIO25_CTRL,  0x400280CC

# -- CAMPO FUNCSEL
.equ FUNC_UART0   , 0x02  #-- UART0
.equ FUNC_SOFTWARE, 0x05  #-- Control por software
.equ FUNC_NULL,     0x1F  #-- Sin usar

# ----------------------------------------------------------
# -- Registros de los PADs
# ----------------------------------------------------------
# -- Sección 9.11.3, página 782 del datasheet del RP2350
# -- https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf
#
# | 31:9 | 8   | 7  | 6  | 5:4   | 3   | 2   | 1      | 0        | 
# | Res  | ISO | OD | IE | Drive | PUE | PDE | SCHMIT | SLEWFAST |
# |------|  1  |  0 | 0  | 01    |  0  |  1  |  1     | 0        |
#
# * ISO: PAD Aislado (no conectado)
#   - 0: Conectado
#   - 1: Aislado
# * OD (0): Output Disable: Deshabilitacion de salida
#   -  0: Salida habilitada
#   -  1: Salida Deshabilitada
# * IE (0): Input Enable: Habilitacion de entrada
#   -  0: Entrada no habilitada
#   -  1: Entrada habilitada
# * Drive (01): Corriente de salida del pin
# * PUE (0): Pull Up Enable. Habilitacion de resistencia pull up
#   - 0: Resistencia pull up deshabilitada
#   - 1: Resistencia pull up habilitada
# * PDE (1): Pull Down Enable. Habilitacion de resistencia pull down
#   - 0: Resistencia pull down deshabilitada
#   - 1: Resistencia pull down habilitada
# * SCHMIT (1): Habilitacion de la entrada Schmitt
# * SLEWFAST (0): 1= rápido. 0= lento
#

.equ PADS_BANK0_BASE,  0x40038000

# -- Direcciones
.equ PAD_GPIO0,       0x40038004
  .equ PAD_GPIO0_XOR, 0x40039004
  .equ PAD_GPIO0_SET, 0x4003A004
  .equ PAD_GPIO0_CLR, 0x4003B004 

.equ PAD_GPIO1,       0x40038008
  .equ PAD_GPIO1_XOR, 0x40039008
  .equ PAD_GPIO1_SET, 0x4003A008
  .equ PAD_GPIO1_CLR, 0x4003B008 

.equ PAD_GPIO15, 0x40038040
.equ PAD_GPIO25, 0x40038068

# -- Valor para habilitar el PAD
# -- Y dejar el resto de campos a su valores por defecto
.equ PAD_ENABLE_OUT, 0x016  # ISO = 1, 

# ---------------------------------------------------------
# -- REGISTROS DEL BANCO SIO
# ---------------------------------------------------------
# -- Sección 3.1.11. Página 54 del datasheet del RP2350
# -- https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf

# --- DIRECCIONES ---------------------------------

# --------------------------------------
# -- Registro de entrada/salida
# -- GPIOs de 0 a 31
# --------------------------------------
.equ GPIO_IN,      0xD0000004  #-- Lectura de GPIOs
.equ GPIO_OUT,     0xD0000010  #-- Escritura de GPIOs
.equ GPIO_OUT_SET, 0xD0000018  #-- Poner a 1 los GPIOs
.equ GPIO_OUT_CLR, 0xD0000020  #-- Poner a 0 los GPIOs
.equ GPIO_OUT_XOR, 0xD0000028  #-- Invertir el estado de los GPIOs
.equ GPIO_OE,      0xD0000030  #-- Establecer habilitación de salida
.equ GPIO_OE_SET,  0xD0000038  #-- Habilitar la salida GPIOs indicados
.equ GPIO_OE_CLR,  0xD0000040  #-- Deshabilitar la salida GPIOs indicados



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


.equ ACCESSCTRL_BASE,            0x40060000
.equ ACCESSCTRL_GPIO_NSMASK0,    0x4006000C
.equ ACCESSCTRL_UART0,           0x400600a0

.equ SRAM_BASE,             0x20000000
.equ UART0_BASE,            0x40070000

#-- Registro de datos de la uart
.equ UART0_UARTDR,          0x40070000

#-- Registro flags de la UART
.equ UART0_UARTF,           0x40070018

  #-- Transmisor ocupado
  .equ TXFF, 0x20

  #-- Receptor vacio
  .equ RXFF, 0x10

.equ UART0_UARTIBRD,        0x40070024
.equ UART0_UARTFBRD,        0x40070028
.equ UART0_UARTLCR_H,       0x4007002C
  .equ UART0_UARTLCR_H_XOR, 0x4007102C
.equ UART0_UARTCR,          0x40070030 
.equ UART0_UARTDMACR,       0x40070048

.equ UART1_BASE,            0x40078000
.equ UART1_UARTDR,          0x40078000
.equ UART1_UARTF,           0x40078018

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

.equ POWMAN_BASE,         0x40100000
.equ LPOSC_FREQ_KHZ_INT,  0x40100050
.equ LPOSC_FREQ_KHZ_FRAC, 0x40100054 
.equ READ_TIME_LOWER,     0x40100074
.equ POWMAN_TIMER,        0x40100088
  .equ POWMAN_TIMER_XOR,  0x40101088
  .equ POWMAN_TIMER_SET,  0x40102088
  .equ POWMAN_TIMER_CLR,  0x40103088

  #-- Valor de seguridad
  .equ SAFE, 0x5afe0000

  #-- Campos del TIMER
  .equ RUN, SAFE + BIT1 #-- Start/Stop

.equ USBCTRL_REGS_BASE, 0x50110000
.equ USB_SIE_CTRL,      0x5011004c
.equ USB_SIE_CTRL_SET,  0x5011204c

