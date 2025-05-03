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
.equ GPIO00_CTRL, 0x40028004 
.equ GPIO15_CTRL, 0x4002807C
.equ GPIO25_CTRL, 0x400280CC

# -- CAMPO FUNCSEL
.equ FUNC_UART0_TX, 0x02  #-- UART0 TX
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
# -- Direcciones
.equ PAD_GPIO0,       0x40038004
  .equ PAD_GPIO0_SET, 0x4003A004
  .equ PAD_GPIO0_XOR, 0x4003B004 
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


# ----------------------------------------------
# -- Definiciones de las posiciones de los bits
# -- Se usan como valores para GPIO_OE y GPIO_OUT
# ----------------------------------------------
.equ BIT0,  (1 <<  0)  # 0x0000_0001
.equ BIT25, (1 << 25)  # 0x0200_0000
.equ BIT26, (1 << 26)  # 0x0400_0000



