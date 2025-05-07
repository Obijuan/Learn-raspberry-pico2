
#include <stdio.h>
#include "pico/stdlib.h"
#include "hardware/uart.h"


#define UART_ID uart0
#define BAUD_RATE 115200

// We are using pins 0 and 1, but see the GPIO function select table in the
// datasheet for information on which other pins can be used.
#define UART_TX_PIN 0
#define UART_RX_PIN 1

int main() {
    char c;

    // Set up our UART with the required speed.
    uart_init(UART_ID, BAUD_RATE);

    // Set the TX and RX pins by using the function select on the GPIO
    // Set datasheet for more information on function select
    gpio_set_function(UART_TX_PIN, UART_FUNCSEL_NUM(UART_ID, UART_TX_PIN));
    gpio_set_function(UART_RX_PIN, UART_FUNCSEL_NUM(UART_ID, UART_RX_PIN));

    // Use some the various UART functions to send out data
    // In a default system, printf will also output via the default UART

    while (1) {
        c = uart_getc(UART_ID);

        // Send out a character without any conversions
        uart_putc_raw(UART_ID, c);
    }

    return 0;
}

