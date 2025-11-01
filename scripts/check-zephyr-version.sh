#!/bin/bash
# check-zephyr-version.sh - Sjekk Zephyr-versjonar i alle prosjekt
# Bruk: ./check-zephyr-version.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
META_ROOT="$(dirname "$SCRIPT_DIR")"
BOARDS_DIR="$META_ROOT/boards"

echo -e "${BLUE}=== Zephyr Version Check ===${NC}"
echo ""

# Sjekk template
echo -e "${YELLOW}Template:${NC}"
if [ -f "$META_ROOT/templates/west.yml" ]; then
    TEMPLATE_VERSION=$(grep "revision:" "$META_ROOT/templates/west.yml" | awk '{print $2}')
    echo -e "  ${CYAN}$TEMPLATE_VERSION${NC}"
else
    echo -e "  ${YELLOW}Template ikke funnet${NC}"
fi

echo ""
echo -e "${YELLOW}Board prosjekt:${NC}"

# Sjekk alle board-prosjekt
for project_dir in "$BOARDS_DIR"/*; do
    if [ ! -d "$project_dir" ]; then
        continue
    fi

    project_name=$(basename "$project_dir")

    if [ ! -f "$project_dir/west.yml" ]; then
        echo -e "  ${project_name}: ${YELLOW}Ingen west.yml${NC}"
        continue
    fi

    VERSION=$(grep "revision:" "$project_dir/west.yml" | awk '{print $2}')

    # Sjekk om zephyr/ er initialisert
    if [ -d "$project_dir/zephyr" ]; then
        cd "$project_dir/zephyr"
        ACTUAL_VERSION=$(git describe --tags 2>/dev/null || echo "unknown")
        echo -e "  ${project_name}: ${CYAN}$VERSION${NC} (installed: ${GREEN}$ACTUAL_VERSION${NC})"
        cd - > /dev/null
    else
        echo -e "  ${project_name}: ${CYAN}$VERSION${NC} (${YELLOW}not initialized${NC})"
    fi
done

echo ""
echo -e "${BLUE}Latest Zephyr releases:${NC}"
echo -e "  Visit: ${CYAN}https://github.com/zephyrproject-rtos/zephyr/releases${NC}"
echo -e "  Current stable: ${GREEN}v4.2.1${NC} (October 2024)"
echo -e "  LTS: ${GREEN}v3.7.1${NC} (July 2024)"
echo ""
echo -e "${YELLOW}To update a project:${NC}"
echo -e "  1. Edit boards/<project>/west.yml"
echo -e "  2. Change revision: to desired version"
echo -e "  3. Run: cd boards/<project> && west update"
echo -e "  4. Test build: west build -b <board> app"
