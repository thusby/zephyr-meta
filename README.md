# Zephyr Meta - Unified Zephyr RTOS Development Environment

Meta-repository for alle Zephyr RTOS embedded systems prosjekt. Dette repoet inneheld felles templates, bibliotek, scripts og kodestandardar for rask og konsekvent utvikling på tvers av ulike hardware-plattformer.

**Forfatter:** Terje Husby
**Email:** terje@electricfarm.no
**Lisens:** MIT

## 🎯 Oversikt

Zephyr Meta gir deg:

- ✅ **Templates** for raske nye prosjekt (DevContainer, west.yml, CMakeLists.txt)
- ✅ **Felles bibliotek** (`lib/common/`) med GPIO, error handling, og meir
- ✅ **Utility scripts** for å generere, bygge, og flashe prosjekt
- ✅ **Kodestandardar** (.clang-format, .editorconfig)
- ✅ **Git submodules** for separate board-prosjekt

## 📁 Prosjektstruktur

```
zephyr-meta/
├── templates/          # 🎨 Templates for nye prosjekt
├── lib/common/         # 📚 Felles utility-kode
├── scripts/            # 🛠️ Build, flash, og oppdateringsscripts
├── standards/          # 📋 Kodestandardar og formatering
├── boards/             # 🔌 Board-prosjekt (git submodules)
│   ├── arduino-nano/   → zephyr_dev
│   ├── nrf52840/      → zephyr_nrf52840
│   └── rpi-pico/      → zephyr_pico
└── docs/               # 📖 Dokumentasjon
```

## 🚀 Komme i gang

### 1. Clone meta-repo med submodules

```bash
git clone --recursive git@github.com:thusby/zephyr-meta.git
cd zephyr-meta
```

### 2. Opprette nytt board-prosjekt

```bash
./scripts/new-project.sh my_project_name <board_name> "Display Name"
```

**Eksempel:**
```bash
./scripts/new-project.sh zephyr_esp32 esp32_devkitc_wroom "ESP32 Development"
```

**Populære boards:**
- `arduino_nano_33_iot` - Arduino Nano 33 IoT
- `nrf52840dk_nrf52840` - Nordic nRF52840 DK
- `esp32_devkitc_wroom` - ESP32 DevKit
- `nucleo_f401re` - STM32 Nucleo F401RE
- `rpi_pico` - Raspberry Pi Pico

### 3. Opne i VS Code DevContainer

```bash
cd boards/my_project_name
code .
# Vel "Reopen in Container" når VS Code opnar
```

Første oppstart lastar ned Zephyr OS og SDK (10-15 minutt).

### 4. Bygg prosjektet

```bash
west build -b <board_name> app
```

### 5. Flash til board

```bash
west flash
# Eller bruk helper script frå meta-repo root:
../../scripts/flash-board.sh my_project_name
```

## 🛠️ Nyttige Scripts

### new-project.sh
Genererer eit nytt board-prosjekt frå templates.

```bash
./scripts/new-project.sh <project_name> <board_name> [display_name]
```

### build-all.sh
Bygg alle board-prosjekt.

```bash
./scripts/build-all.sh        # Normal build
./scripts/build-all.sh clean  # Clean build
```

### flash-board.sh
Flash firmware til spesifikt board.

```bash
./scripts/flash-board.sh <project_name>
```

### update-all.sh
Oppdater meta-repo og alle submodules.

```bash
./scripts/update-all.sh
```

## 📚 Felles Bibliotek

`lib/common/` inneheld utility functions for alle prosjekt:

### gpio_helpers
```c
#include "gpio_helpers.h"

// Initialiser LED
ZH_CHECK_RET(zh_init_led(&led));

// Toggle LED
zh_toggle_led(&led);
```

### error_handling
```c
#include "error_handling.h"

// Auto-return ved feil
ZH_CHECK_RET(some_function());

// Error til string
const char *msg = zh_error_to_string(ret);
```

**Bruk i prosjekt:**
```cmake
# app/CMakeLists.txt
target_sources(app PRIVATE
    src/main.c
    ../../../lib/common/gpio_helpers.c
    ../../../lib/common/error_handling.c
)

target_include_directories(app PRIVATE
    ../../../lib/common
)
```

## 📋 Kodestandardar

- **C/C++:** Zephyr RTOS style (tabs, K&R brackets)
- **Formatering:** `.clang-format` og `.editorconfig`
- **Namnekonvensjon:** `zh_` prefix for felles functions

Sjå [CODING_STYLE.md](standards/CODING_STYLE.md) for detaljar.

## 🔌 Støtta Boards

| Board | Prosjekt | MCU | Status |
|-------|----------|-----|--------|
| Arduino Nano 33 IoT | `arduino-nano` | SAMD21 (ARM Cortex-M0+) | ✅ |
| nRF52840 DK | `nrf52840` | nRF52840 (ARM Cortex-M4) | ✅ |
| Raspberry Pi Pico | `rpi-pico` | RP2040 (ARM Cortex-M0+) | 🚧 |

## 📖 Dokumentasjon

- [Project Structure](standards/PROJECT_STRUCTURE.md) - Detaljert prosjektstruktur
- [Coding Style](standards/CODING_STYLE.md) - Kodestil og best practices
- [Common Library](lib/common/README.md) - Felles utility functions

## 🤝 Workflow

### Legg til eksisterande prosjekt som submodule

```bash
git submodule add git@github.com:thusby/zephyr_project.git boards/project_name
git commit -m "Add project_name submodule"
git push
```

### Oppdater submodule

```bash
cd boards/project_name
git pull origin main
cd ../..
git add boards/project_name
git commit -m "Update project_name submodule"
git push
```

## 🧪 Testing

Bygg alle prosjekt for å verifisere at templates og lib/ fungerer:

```bash
./scripts/build-all.sh
```

## 📦 Versjonar

- **Zephyr RTOS:** v3.7.1
- **Zephyr SDK:** 0.16.8
- **DevContainer:** zephyrprojectrtos/ci:v0.26.13

## 🐛 Feilsøking

### USB device ikkje synleg
Sikre at DevContainer har USB-tilgang:
```json
"runArgs": ["--privileged", "--device=/dev/bus/usb"],
"mounts": ["type=bind,source=/dev,target=/dev"]
```

### Flash feiler (Arduino)
Dobbelklikk reset-knappen på Arduino (LED pulsar oransje), deretter flash raskt.

### "west: unknown command 'build'"
Zephyr ikkje initialisert. Køyr:
```bash
west init -l .
west update
west zephyr-export
```

## 🔗 Ressursar

- [Zephyr Documentation](https://docs.zephyrproject.org/)
- [Zephyr Getting Started](https://docs.zephyrproject.org/latest/develop/getting_started/index.html)
- [West Tool](https://docs.zephyrproject.org/latest/develop/west/index.html)
- [Git Submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)

## 📄 Lisens

MIT License - sjå [LICENSE](LICENSE)

---

**Laga med ❤️ av Terje Husby**
