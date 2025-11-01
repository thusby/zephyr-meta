# Zephyr Meta - Prosjektstruktur

Dette dokumentet beskriv standardstrukturen for Zephyr Meta-prosjekt.

## Meta-repo Struktur

```
zephyr-meta/
├── README.md                 # Hovuddokumentasjon
├── LICENSE                   # MIT License
├── .gitignore               # Git ignore rules
├── .gitmodules              # Submodule configuration
│
├── templates/               # 🎨 Templates for nye prosjekt
│   ├── devcontainer/
│   │   ├── devcontainer.json
│   │   └── setup.sh
│   ├── app/
│   │   ├── CMakeLists.txt
│   │   ├── prj.conf
│   │   └── src/
│   │       └── main.c
│   ├── west.yml
│   └── .gitignore
│
├── lib/                     # 📚 Felles bibliotek
│   ├── common/
│   │   ├── README.md
│   │   ├── gpio_helpers.h
│   │   ├── gpio_helpers.c
│   │   ├── error_handling.h
│   │   └── error_handling.c
│   └── drivers/            # Custom drivers (framtidig)
│
├── scripts/                 # 🛠️ Utility scripts
│   ├── new-project.sh      # Generer nytt prosjekt
│   ├── build-all.sh        # Bygg alle prosjekt
│   ├── flash-board.sh      # Flash script
│   └── update-all.sh       # Oppdater alle submodules
│
├── standards/               # 📋 Kodestandardar
│   ├── .clang-format       # C/C++ formatting
│   ├── .editorconfig       # Editor configuration
│   ├── CODING_STYLE.md     # Coding guidelines
│   └── PROJECT_STRUCTURE.md # Dette dokumentet
│
├── boards/                  # 🔌 Board-spesifikke prosjekt (submodules)
│   ├── arduino-nano/       # → zephyr_dev (submodule)
│   ├── nrf52840/          # → zephyr_nrf52840 (submodule)
│   └── rpi-pico/          # → zephyr_pico (submodule)
│
└── docs/                    # 📖 Dokumentasjon
    ├── GETTING_STARTED.md
    ├── FAQ.md
    └── TROUBLESHOOTING.md
```

## Board-prosjekt Struktur

Kvart board-prosjekt følgjer denne strukturen:

```
<board-prosjekt>/
├── README.md                # Board-spesifikk dokumentasjon
├── LICENSE                  # MIT License
├── .gitignore              # Git ignore
├── west.yml                # West manifest (Zephyr v3.7.1)
│
├── .devcontainer/          # VS Code DevContainer
│   ├── devcontainer.json   # Container config
│   └── setup.sh            # Setup script
│
├── app/                    # Applikasjonskode
│   ├── CMakeLists.txt      # CMake build config
│   ├── prj.conf            # Zephyr Kconfig
│   ├── src/
│   │   └── main.c          # Main application
│   ├── include/            # (Valgfritt) Headers
│   └── boards/             # (Valgfritt) Board-spesifikke configs
│       ├── <board>.overlay # Device tree overlay
│       └── <board>.conf    # Board-spesifikk Kconfig
│
├── zephyr/                 # (Auto-generert av west update)
├── modules/                # (Auto-generert)
├── tools/                  # (Auto-generert)
├── bootloader/             # (Auto-generert for nRF)
└── build/                  # (Generert ved bygging)
```

## Filbeskrivingar

### Meta-repo Filer

#### `templates/`
Templates som blir brukt av `new-project.sh` til å generere nye board-prosjekt. Inneheld placeholders som `{{PROJECT_NAME}}`, `{{BOARD_NAME}}` etc.

#### `lib/common/`
Felles utility-kode som kan inkluderast i alle board-prosjekt:
- `gpio_helpers` - GPIO utility functions
- `error_handling` - Error handling helpers

**Bruk i prosjekt:**
```cmake
# I app/CMakeLists.txt
target_sources(app PRIVATE
    src/main.c
    ../../../lib/common/gpio_helpers.c
)

target_include_directories(app PRIVATE
    ../../../lib/common
)
```

#### `scripts/`
Utility scripts for å forenkle arbeidsflyten:
- **new-project.sh** - Generer nytt board-prosjekt frå templates
- **build-all.sh** - Bygg alle board-prosjekt
- **flash-board.sh** - Flash firmware til board
- **update-all.sh** - Oppdater submodules og Zephyr workspace

#### `standards/`
Kodestandardar og konfigurasjonsfiler:
- **.clang-format** - Automatisk C/C++ formatering
- **.editorconfig** - Editor-konfigurasjon
- **CODING_STYLE.md** - Kodestil guidelines
- **PROJECT_STRUCTURE.md** - Dette dokumentet

#### `boards/`
Git submodules som peikar til individuelle board-prosjekt repositories. Dette tillèt:
- Separate git-historikk for kvart board
- Individuell versjonering
- Enkel kloning av alle prosjekt samtidig

### Board-prosjekt Filer

#### `west.yml`
West manifest som definerer Zephyr-versjon og dependencies:
```yaml
manifest:
  self:
    path: app
  remotes:
    - name: zephyrproject-rtos
      url-base: https://github.com/zephyrproject-rtos
  projects:
    - name: zephyr
      remote: zephyrproject-rtos
      revision: v3.7.1
      import: true
```

#### `.devcontainer/devcontainer.json`
VS Code DevContainer-konfigurasjon. Definerer:
- Docker image: `zephyrprojectrtos/ci:v0.26.13`
- USB access for flashing
- VS Code extensions
- Post-create setup script

#### `.devcontainer/setup.sh`
Setup script som køyrer ved første container-oppstart:
1. Initialiserer West workspace
2. Lastar ned Zephyr og modules
3. Installerer Zephyr SDK
4. Installerer Python dependencies

#### `app/CMakeLists.txt`
CMake build-konfigurasjon:
```cmake
cmake_minimum_required(VERSION 3.20.0)
find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(project_name)

target_sources(app PRIVATE
    src/main.c
)
```

#### `app/prj.conf`
Zephyr Kconfig-konfigurasjon:
```conf
# Serial console
CONFIG_SERIAL=y
CONFIG_UART_CONSOLE=y

# Logging
CONFIG_LOG=y
CONFIG_LOG_DEFAULT_LEVEL=3

# GPIO
CONFIG_GPIO=y
```

#### `app/src/main.c`
Hovud-applikasjonsfil med `main()` function.

## Git Submodules

### Leggje til submodule

```bash
cd zephyr-meta
git submodule add git@github.com:thusby/zephyr_dev.git boards/arduino-nano
git submodule add git@github.com:thusby/zephyr_nrf52840.git boards/nrf52840
```

### Clone meta-repo med submodules

```bash
git clone --recursive git@github.com:thusby/zephyr-meta.git
```

### Oppdatere submodules

```bash
git submodule update --remote --merge
```

Eller bruk:
```bash
./scripts/update-all.sh
```

## Arbeidsflyt

### 1. Opprette nytt board-prosjekt

```bash
cd zephyr-meta
./scripts/new-project.sh my_esp32_project esp32_devkitc_wroom "ESP32 Dev"
```

### 2. Opne i DevContainer

```bash
cd boards/my_esp32_project
code .
# Vel "Reopen in Container"
```

### 3. Bygg

```bash
west build -b esp32_devkitc_wroom app
```

### 4. Flash

```bash
west flash
# Eller
cd ../../
./scripts/flash-board.sh my_esp32_project
```

### 5. Legg til som submodule

```bash
# Opprett GitHub repo først
cd boards/my_esp32_project
git init
git add .
git commit -m "Initial commit"
gh repo create thusby/my_esp32_project --private --source=. --push

# Legg til som submodule i meta-repo
cd ../..
git submodule add git@github.com:thusby/my_esp32_project.git boards/my_esp32_project
git commit -m "Add my_esp32_project submodule"
```

## Navnekonvensjonar

| Type | Format | Eksempel |
|------|--------|----------|
| Meta-repo | `zephyr-meta` | `zephyr-meta` |
| Board-prosjekt | `zephyr_<board>` | `zephyr_esp32` |
| Submodule path | `boards/<board-namn>` | `boards/esp32` |
| Functions (lib) | `zh_<name>` | `zh_init_led()` |

## Best Practices

### 1. DRY (Don't Repeat Yourself)
Bruk felles kode frå `lib/common` i staden for å duplisere.

### 2. Templates
Alle nye prosjekt skal genererast frå templates med `new-project.sh`.

### 3. Versjonering
- Meta-repo: Versjonerer templates, scripts, og standards
- Board-prosjekt: Versjonerer applikasjonskode og konfigurasjon
- Submodules: Peik til spesifikke commits i board-prosjekt

### 4. Dokumentasjon
Kvart board-prosjekt må ha:
- README.md med build/flash-instruksjonar
- Kommentert kode
- Board-spesifikk dokumentasjon

### 5. Testing
Bruk `build-all.sh` for å sikre at alle prosjekt byggjer etter endringar i templates eller lib/.

## Framtidige Utvidingar

- **CI/CD**: GitHub Actions for automatisk bygging
- **lib/drivers/**: Custom sensor drivers
- **tests/**: Unit tests for lib/common
- **docs/**: Utvidd dokumentasjon
- **examples/**: Eksempelprosjekt for ulike boards

## Ressursar

- [West Workspace](https://docs.zephyrproject.org/latest/develop/west/workspaces.html)
- [Git Submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [Zephyr Application Development](https://docs.zephyrproject.org/latest/develop/application/index.html)
