#include "pico/stdlib.h"

// -- Pines de los recursos
#define LED 25
#define BTN 0

int main() {

  // -- Configurar LED
  gpio_init(LED);
  gpio_set_dir(LED, GPIO_OUT);

  // -- Configurar GPIO 0 como entrada
  gpio_init(BTN);
  gpio_set_dir(BTN, GPIO_IN);
  gpio_pull_up(BTN);
  
  //-- Mostrar el valor de GPIO0 en el LED
  while (1) {
    if (gpio_get(BTN)) {
      gpio_put(LED, 1);
    } else {
      gpio_put(LED, 0);
    }
  }

}

