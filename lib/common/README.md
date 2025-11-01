# Zephyr Common Library

Felles utility functions for Zephyr RTOS prosjekt.

## Innhald

### gpio_helpers.h/c
Utility functions for GPIO-operasjonar:
- `zh_init_led()` - Initialiser LED med error handling
- `zh_toggle_led()` - Toggle LED
- `zh_set_led()` - Sett LED til spesifikk tilstand
- `zh_init_button()` - Initialiser button input pin
- `zh_read_button()` - Les button tilstand

### error_handling.h/c
Error handling utilities:
- `zh_error_to_string()` - Konverter feilkode til lesbar streng
- `zh_check_error()` - Sjekk og logg feil
- `ZH_CHECK_RET()` - Makro for å returnere ved feil
- `ZH_CHECK_GOTO()` - Makro for å hoppe til cleanup ved feil

## Bruk

### Inkluder i CMakeLists.txt

```cmake
# Legg til i app/CMakeLists.txt
target_sources(app PRIVATE
    src/main.c
    ../lib/common/gpio_helpers.c
    ../lib/common/error_handling.c
)

target_include_directories(app PRIVATE
    ../lib/common
)
```

### Eksempel

```c
#include <zephyr/kernel.h>
#include "gpio_helpers.h"
#include "error_handling.h"

#define LED0_NODE DT_ALIAS(led0)
static const struct gpio_dt_spec led = GPIO_DT_SPEC_GET(LED0_NODE, gpios);

int main(void)
{
    // Initialiser LED med error handling
    ZH_CHECK_RET(zh_init_led(&led));

    while (1) {
        zh_toggle_led(&led);
        k_msleep(1000);
    }

    return 0;
}
```

## Namnekonvensjon

Alle functions er prefiksa med `zh_` (Zephyr Helper) for å unngå namekonfliktar.
