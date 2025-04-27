# Configuracion del proyecto

1. pico-sdk tiene que estar instalado
2. Las toolchains de riscv tienen que estar instaladas
3. makdir build
4. cd build
5. export PICO_SDK_PATH=/home/obijuan/Develop/pico/pico-sdk
6. export PICO_TOOLCHAIN_PATH=/home/obijuan/Develop/pico/corev-openhw-gcc-ubuntu2204-20240530
7. cmake -DPICO_PLATFORM=rp2350-riscv ..


# Compilacion

Ejecutar `make` (desde el directorio build)

# Ejecución

* Poner la pico2 en modo BOOT
* Copiar el fichero ejecutab .uf2 en /media/obijuan/RP2350

```
cp 01-blinky-gpio15.uf2 /media/obijuan/RP2350
```

