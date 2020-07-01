#include <stdint.h>

volatile uint32_t *millis_ptr = (uint32_t*) 0x80000020;
uint32_t millis() {
    return *(millis_ptr);
}

void sleep(uint32_t time_ms) {
    uint32_t start_time = millis();
    while((millis() - start_time) < time_ms);
}

volatile uint32_t *gpio_ptr = (uint32_t*) 0x80000000;
int main() {
    while (1) {
        (*gpio_ptr) = (*gpio_ptr) + 1;
        sleep(1000);
    }
}
