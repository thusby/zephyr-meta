#!/bin/bash
# build-all.sh - Bygg alle board-prosjekt
# Bruk: ./build-all.sh [clean]

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
META_ROOT="$(dirname "$SCRIPT_DIR")"
BOARDS_DIR="$META_ROOT/boards"

CLEAN_BUILD=false
if [ "$1" == "clean" ]; then
    CLEAN_BUILD=true
fi

echo -e "${YELLOW}=== Building all Zephyr projects ===${NC}"
echo ""

SUCCESS_COUNT=0
FAIL_COUNT=0
FAILED_PROJECTS=()

# Iterer gjennom alle prosjekt i boards/
for project_dir in "$BOARDS_DIR"/*; do
    if [ ! -d "$project_dir" ]; then
        continue
    fi

    project_name=$(basename "$project_dir")

    # Hopp over viss det ikkje er eit Zephyr prosjekt
    if [ ! -f "$project_dir/west.yml" ]; then
        echo -e "${YELLOW}⊘ Hoppar over $project_name (ikkje eit Zephyr prosjekt)${NC}"
        continue
    fi

    echo -e "${YELLOW}→ Byggjer $project_name...${NC}"

    cd "$project_dir"

    # Sjekk om zephyr er initialisert
    if [ ! -d "zephyr" ]; then
        echo -e "${RED}  ✗ Zephyr ikkje initialisert. Køyr 'west init -l .' først.${NC}"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        FAILED_PROJECTS+=("$project_name (not initialized)")
        continue
    fi

    # Detekter board-namn frå setup.sh eller CMakeLists.txt
    BOARD_NAME=$(grep -oP 'west build -b \K[a-z0-9_]+' .devcontainer/setup.sh 2>/dev/null || echo "")

    if [ -z "$BOARD_NAME" ]; then
        echo -e "${RED}  ✗ Kunne ikkje finne board-namn${NC}"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        FAILED_PROJECTS+=("$project_name (unknown board)")
        continue
    fi

    # Bygg
    BUILD_CMD="west build -b $BOARD_NAME app"
    if [ "$CLEAN_BUILD" = true ]; then
        BUILD_CMD="west build -p auto -b $BOARD_NAME app"
    fi

    if $BUILD_CMD > /dev/null 2>&1; then
        echo -e "${GREEN}  ✓ $project_name bygd (board: $BOARD_NAME)${NC}"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo -e "${RED}  ✗ $project_name feila${NC}"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        FAILED_PROJECTS+=("$project_name")
    fi

    cd - > /dev/null
done

echo ""
echo -e "${YELLOW}=== Build Summary ===${NC}"
echo -e "${GREEN}Suksess: $SUCCESS_COUNT${NC}"
echo -e "${RED}Feila: $FAIL_COUNT${NC}"

if [ $FAIL_COUNT -gt 0 ]; then
    echo ""
    echo "Feila prosjekt:"
    for failed in "${FAILED_PROJECTS[@]}"; do
        echo "  - $failed"
    done
    exit 1
fi

echo -e "${GREEN}Alle prosjekt bygd! 🎉${NC}"
