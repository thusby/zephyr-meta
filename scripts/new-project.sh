#!/bin/bash
# new-project.sh - Generer nytt Zephyr prosjekt frå templates
# Bruk: ./new-project.sh <project_name> <board_name> [display_name]

set -e

# Fargekoder for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Sjekk arguments
if [ $# -lt 2 ]; then
    echo -e "${RED}Bruk: $0 <project_name> <board_name> [display_name]${NC}"
    echo ""
    echo "Eksempel:"
    echo "  $0 zephyr_esp32 esp32_devkitc_wroom \"ESP32 Development\""
    echo "  $0 zephyr_stm32 nucleo_f401re"
    echo ""
    echo "Populære boards:"
    echo "  - arduino_nano_33_iot"
    echo "  - nrf52840dk_nrf52840"
    echo "  - esp32_devkitc_wroom"
    echo "  - nucleo_f401re"
    echo "  - rpi_pico"
    exit 1
fi

PROJECT_NAME=$1
BOARD_NAME=$2
DISPLAY_NAME=${3:-"$PROJECT_NAME"}

# Finn meta-repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
META_ROOT="$(dirname "$SCRIPT_DIR")"
TEMPLATE_DIR="$META_ROOT/templates"
TARGET_DIR="$META_ROOT/boards/$PROJECT_NAME"

echo -e "${BLUE}=== Zephyr Meta Project Generator ===${NC}"
echo -e "${GREEN}Prosjekt:${NC} $PROJECT_NAME"
echo -e "${GREEN}Board:${NC} $BOARD_NAME"
echo -e "${GREEN}Display namn:${NC} $DISPLAY_NAME"
echo ""

# Sjekk om prosjekt allereie eksisterer
if [ -d "$TARGET_DIR" ]; then
    echo -e "${RED}Feil: Prosjekt '$PROJECT_NAME' eksisterer allereie i boards/${NC}"
    exit 1
fi

# Detekter board-familie for riktig toolchain
TOOLCHAIN_CMD="./setup.sh -t arm-zephyr-eabi -c"
FLASH_CMD="west flash"

case "$BOARD_NAME" in
    arduino_nano_33_iot)
        FLASH_CMD="west flash --bossac-port=/dev/ttyACM0"
        ;;
    nrf52840*)
        TOOLCHAIN_CMD="./setup.sh -t arm-zephyr-eabi -c"
        ;;
    esp32*)
        TOOLCHAIN_CMD="./setup.sh -t xtensa-espressif_esp32_zephyr-elf -c"
        ;;
    rpi_pico)
        TOOLCHAIN_CMD="./setup.sh -t arm-zephyr-eabi -c"
        FLASH_CMD="# Copy build/zephyr/zephyr.uf2 to Pico in bootloader mode"
        ;;
    nucleo_*)
        TOOLCHAIN_CMD="./setup.sh -t arm-zephyr-eabi -c"
        ;;
esac

# Opprett målkatalog
echo -e "${YELLOW}Opprettar prosjektstruktur...${NC}"
mkdir -p "$TARGET_DIR"/{.devcontainer,app/src}

# Kopier og erstatt templates
echo -e "${YELLOW}Genererer filer frå templates...${NC}"

# devcontainer.json
sed -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
    -e "s|{{PROJECT_DISPLAY_NAME}}|$DISPLAY_NAME|g" \
    "$TEMPLATE_DIR/devcontainer/devcontainer.json" > "$TARGET_DIR/.devcontainer/devcontainer.json"

# setup.sh
sed -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
    -e "s|{{PROJECT_DISPLAY_NAME}}|$DISPLAY_NAME|g" \
    -e "s|{{BOARD_NAME}}|$BOARD_NAME|g" \
    -e "s|{{TOOLCHAIN_INSTALL_CMD}}|$TOOLCHAIN_CMD|g" \
    -e "s|{{FLASH_COMMAND}}|$FLASH_CMD|g" \
    "$TEMPLATE_DIR/devcontainer/setup.sh" > "$TARGET_DIR/.devcontainer/setup.sh"
chmod +x "$TARGET_DIR/.devcontainer/setup.sh"

# west.yml
cp "$TEMPLATE_DIR/west.yml" "$TARGET_DIR/west.yml"

# CMakeLists.txt
sed -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
    "$TEMPLATE_DIR/app/CMakeLists.txt" > "$TARGET_DIR/app/CMakeLists.txt"

# prj.conf
sed -e "s|{{PROJECT_DISPLAY_NAME}}|$DISPLAY_NAME|g" \
    "$TEMPLATE_DIR/app/prj.conf" > "$TARGET_DIR/app/prj.conf"

# main.c
sed -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
    -e "s|{{PROJECT_DISPLAY_NAME}}|$DISPLAY_NAME|g" \
    -e "s|{{BOARD_NAME}}|$BOARD_NAME|g" \
    "$TEMPLATE_DIR/app/src/main.c" > "$TARGET_DIR/app/src/main.c"

# .gitignore
cp "$TEMPLATE_DIR/.gitignore" "$TARGET_DIR/.gitignore"

# LICENSE (kopier frå meta-repo om den eksisterer)
if [ -f "$META_ROOT/LICENSE" ]; then
    cp "$META_ROOT/LICENSE" "$TARGET_DIR/LICENSE"
fi

# Opprett README.md
cat > "$TARGET_DIR/README.md" <<EOF
# $DISPLAY_NAME

Zephyr RTOS prosjekt for **$BOARD_NAME**.

**Generert av:** zephyr-meta
**Forfatter:** Terje Husby
**Email:** terje@electricfarm.no

## Komme i gang

### 1. Opne i DevContainer

\`\`\`bash
code $PROJECT_NAME
# Vel "Reopen in Container"
\`\`\`

### 2. Bygg

\`\`\`bash
west build -b $BOARD_NAME app
\`\`\`

### 3. Flash

\`\`\`bash
$FLASH_CMD
\`\`\`

## Prosjektstruktur

- **app/** - Applikasjonskode
- **.devcontainer/** - VS Code DevContainer konfigurasjon
- **west.yml** - Zephyr workspace manifest

## Ressursar

- [Zephyr Documentation](https://docs.zephyrproject.org/)
- [Board Documentation](https://docs.zephyrproject.org/latest/boards/)
EOF

echo ""
echo -e "${GREEN}✓ Prosjekt '$PROJECT_NAME' generert!${NC}"
echo ""
echo "Neste steg:"
echo "  1. cd boards/$PROJECT_NAME"
echo "  2. code . (og vel 'Reopen in Container')"
echo "  3. west build -b $BOARD_NAME app"
echo "  4. $FLASH_CMD"
echo ""
echo -e "${BLUE}Lykke til! 🚀${NC}"
