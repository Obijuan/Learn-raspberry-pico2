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
.equ GPIO15_CTRL, 0x4002807C
.equ GPIO25_CTRL, 0x400280CC

# -- CAMPO FUNCSEL
.equ FUNC_SOFTWARE, 0x05  #-- Control por software
.equ FUNC_NULL,     0x1F  #-- Sin usar

# ----------------------------------------------------------
# -- Registros de los PADs
# ----------------------------------------------------------
# -- Sección 9.11.3, página 782 del datasheet del RP2350
# -- https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf

# -- Direcciones
.equ GPIO00_PAD_ISO, 0x40038004
.equ GPIO15_PAD_ISO, 0x40038040
.equ GPIO25_PAD_ISO, 0x40038068

# -- Valor para habilitar el PAD
# -- Y dejar el resto de campos a su valores por defecto
.equ PAD_ENABLE, 0x016


# ---------------------------------------------------------
# -- REGISTROS DEL BANCO SIO
# ---------------------------------------------------------
# -- Sección 3.1.11. Página 54 del datasheet del RP2350
# -- https://datasheets.raspberrypi.com/rp2350/rp2350-datasheet.pdf

# --- DIRECCIONES ---------------------------------

# --------------------------------------
# -- Registro de habilitacion de salida
# -- GPIOs de 0 a 31
# --------------------------------------
.equ GPIO_OE, 0xD0000030

# --------------------------------------
# -- Registro de salida
# -- GPIOs de 0 a 31
# --------------------------------------
.equ GPIO_OUT, 0xD0000010

# ----------------------------------------------
# -- Definiciones de las posiciones de los bits
# -- Se usan como valores para GPIO_OE y GPIO_OUT
# ----------------------------------------------
.equ BIT0,  0x00000001
.equ BIT25, (1 << 25)  # 0x0200_0000

