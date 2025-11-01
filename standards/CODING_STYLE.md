# Zephyr Meta - Kodestil

Dette dokumentet definerer kodestilen for alle Zephyr Meta-prosjekt.

## Overordna prinsipp

Vi følgjer [Zephyr RTOS Coding Style](https://docs.zephyrproject.org/latest/contribute/guidelines.html#coding-style) med nokre tilpassingar.

## C/C++ Kode

### Indentering

- **Bruk TABS** (ikkje spaces)
- Tab-størrelse: **8 spaces**
- Alignment: Bruk spaces for alignment etter innledande tabs

```c
int main(void)
{
	int ret;			// Tab-indentert
	const struct device *dev;	// Aligned med spaces etter tab

	if (condition) {
		do_something();		// Tab-indentert
	}
}
```

### Brackets

- **K&R style** (Linux kernel style)
- Opening brace på same linje for functions og statements
- Closing brace på eiga linje

```c
int function(void)
{
	if (condition) {
		do_something();
	} else {
		do_something_else();
	}

	while (condition) {
		loop_body();
	}
}
```

### Namnekonvensjonar

| Type | Konvensjon | Eksempel |
|------|------------|----------|
| Functions | `lowercase_with_underscores` | `zh_init_led()` |
| Variablar | `lowercase_with_underscores` | `int error_code;` |
| Konstanter/Makroar | `UPPERCASE_WITH_UNDERSCORES` | `#define MAX_SIZE 100` |
| Structs/Enums | `lowercase_with_underscores` | `struct gpio_config` |
| Typedefs | `lowercase_with_underscores_t` | `typedef uint32_t config_t;` |

### Prefiks for felles bibliotek

Alle functions i `lib/common` skal ha `zh_` prefix (Zephyr Helper):

```c
int zh_init_led(const struct gpio_dt_spec *led);
int zh_toggle_led(const struct gpio_dt_spec *led);
```

### Linjelengde

- **Maks 100 teikn** per linje
- Bryt lange linjer på fornuftige stadar

### Kommentarar

- **Single-line:** `// Kommentar`
- **Multi-line:** `/* Kommentar */`
- **Doxygen-style for public API:**

```c
/**
 * @brief Initialiser LED med error handling
 *
 * @param led Peikar til gpio_dt_spec struktur
 * @return 0 ved suksess, negativ feilkode ellers
 */
int zh_init_led(const struct gpio_dt_spec *led);
```

### Error Handling

Bruk konsekvent error handling:

```c
int ret = some_function();
if (ret < 0) {
	LOG_ERR("Function failed: %d", ret);
	return ret;
}
```

Eller med helper-makroar:

```c
ZH_CHECK_RET(gpio_pin_configure_dt(&led, GPIO_OUTPUT));
```

### Include Order

1. Standard C headers (`<stdio.h>`, `<string.h>`)
2. Zephyr headers (`<zephyr/kernel.h>`, `<zephyr/drivers/gpio.h>`)
3. Project headers (`"gpio_helpers.h"`)

```c
#include <string.h>

#include <zephyr/kernel.h>
#include <zephyr/drivers/gpio.h>
#include <zephyr/logging/log.h>

#include "gpio_helpers.h"
#include "error_handling.h"
```

## CMake

- **Indent:** 4 spaces
- Lowercase for kommandoar
- Uppercase for variablar

```cmake
cmake_minimum_required(VERSION 3.20.0)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(my_project)

target_sources(app PRIVATE
    src/main.c
    src/helper.c
)
```

## Python

- **PEP 8** style
- **Indent:** 4 spaces
- Max linjelengde: 100 teikn

## Shell Scripts

- **Indent:** Tabs (4 spaces visuelt)
- Bruk `set -e` for å stoppe ved feil
- Bruk doble quotes for variablar: `"$VAR"`

```bash
#!/bin/bash
set -e

PROJECT_NAME="$1"

if [ -z "$PROJECT_NAME" ]; then
	echo "Error: Missing project name"
	exit 1
fi
```

## YAML

- **Indent:** 2 spaces
- Bruk lowercase for keys

```yaml
manifest:
  remotes:
    - name: zephyrproject-rtos
      url-base: https://github.com/zephyrproject-rtos
```

## Formatering

### Automatisk formatering

Alle C/C++-filer skal formaterast med `clang-format`:

```bash
clang-format -i src/*.c include/*.h
```

### Pre-commit hook

Installer pre-commit hook for automatisk formatering:

```bash
cp standards/hooks/pre-commit .git/hooks/
chmod +x .git/hooks/pre-commit
```

### VS Code

VS Code er konfigurert til å formatere automatisk ved lagring (sjå `.devcontainer/devcontainer.json`).

## Logging

Bruk Zephyr logging API:

```c
#include <zephyr/logging/log.h>

LOG_MODULE_REGISTER(module_name, LOG_LEVEL_INF);

LOG_ERR("Error: %d", error_code);
LOG_WRN("Warning message");
LOG_INF("Info message");
LOG_DBG("Debug: value=%d", value);
```

## Best Practices

### Device Tree

Bruk device tree aliaser:

```c
#define LED0_NODE DT_ALIAS(led0)
static const struct gpio_dt_spec led = GPIO_DT_SPEC_GET(LED0_NODE, gpios);
```

### Null Pointer Checks

Alltid sjekk NULL pointers:

```c
if (!led) {
	LOG_ERR("NULL pointer");
	return -EINVAL;
}
```

### Return Values

- `0` for suksess
- Negativ verdi for feil (Zephyr errno)

### Const Correctness

Bruk `const` for read-only parametere:

```c
int process_data(const uint8_t *data, size_t len);
```

## Dokumentasjon

### README.md

Kvart prosjekt må ha README.md med:
- Prosjektnamn og beskriving
- Board-informasjon
- Build-instruksjonar
- Flash-instruksjonar

### Code Comments

- Forklar **kvifor**, ikkje **kva**
- Doxygen-comments for public API
- Inline comments for kompleks logikk

### Eksempel

```c
/**
 * @brief Initialize LED with error handling
 *
 * This function checks if the GPIO device is ready and configures
 * the LED pin as output.
 *
 * @param led Pointer to gpio_dt_spec structure
 * @return 0 on success, negative errno on failure
 */
int zh_init_led(const struct gpio_dt_spec *led)
{
	if (!led) {
		return -EINVAL;
	}

	// Check if device is ready before configuration
	if (!gpio_is_ready_dt(led)) {
		LOG_ERR("GPIO device not ready");
		return -ENODEV;
	}

	return gpio_pin_configure_dt(led, GPIO_OUTPUT_INACTIVE);
}
```

## Git Commit Messages

- **Format:** `<type>: <subject>`
- **Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- **Subject:** Kort (max 50 teikn), imperativ form

Eksempel:
```
feat: add UART helper functions
fix: correct error handling in zh_init_led
docs: update README with build instructions
```

## Ressursar

- [Zephyr Coding Guidelines](https://docs.zephyrproject.org/latest/contribute/guidelines.html)
- [Linux Kernel Coding Style](https://www.kernel.org/doc/html/latest/process/coding-style.html)
- [Zephyr API Documentation](https://docs.zephyrproject.org/latest/doxygen/html/index.html)
