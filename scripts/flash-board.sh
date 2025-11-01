#!/bin/bash
# flash-board.sh - Smart flash script med auto-detect
# Bruk: ./flash-board.sh [project_name]

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
META_ROOT="$(dirname "$SCRIPT_DIR")"
BOARDS_DIR="$META_ROOT/boards"

# Viss project_name er spesifisert
if [ $# -ge 1 ]; then
    PROJECT_NAME=$1
    PROJECT_DIR="$BOARDS_DIR/$PROJECT_NAME"

    if [ ! -d "$PROJECT_DIR" ]; then
        echo -e "${RED}Feil: Prosjekt '$PROJECT_NAME' finst ikkje${NC}"
        exit 1
    fi
else
    # Auto-detect: finn prosjekt basert på cwd
    CURRENT_DIR=$(pwd)
    PROJECT_DIR="$CURRENT_DIR"

    # Sjekk om vi er i eit board-prosjekt
    if [[ "$CURRENT_DIR" == *"/boards/"* ]]; then
        PROJECT_NAME=$(basename "$CURRENT_DIR")
    else
        echo -e "${RED}Feil: Må spesifisere project_name eller køyre frå board-katalog${NC}"
        echo "Bruk: $0 <project_name>"
        exit 1
    fi
fi

echo -e "${YELLOW}=== Flashing $PROJECT_NAME ===${NC}"

cd "$PROJECT_DIR"

# Sjekk om build/ finst
if [ ! -d "build" ]; then
    echo -e "${RED}Feil: Ingen build/-katalog funne. Køyr 'west build' først.${NC}"
    exit 1
fi

# Hent flash-kommando frå setup.sh
FLASH_CMD=$(grep -oP 'Flash with: \K.*' .devcontainer/setup.sh 2>/dev/null || echo "west flash")

echo -e "${YELLOW}Flash-kommando: $FLASH_CMD${NC}"

# Køyr flash
if eval "$FLASH_CMD"; then
    echo -e "${GREEN}✓ $PROJECT_NAME flasha! 🎉${NC}"
else
    echo -e "${RED}✗ Flash feila${NC}"
    echo ""
    echo "Tips:"
    echo "  - Sjekk at enheten er kopla til"
    echo "  - For Arduino: Dobbelklikk reset-knappen"
    echo "  - Sjekk USB-tilgang: ls -l /dev/ttyACM* /dev/ttyUSB*"
    exit 1
fi
