#!/bin/bash
# update-zephyr-version.sh - Oppdater Zephyr-versjon i alle prosjekt
# Bruk: ./update-zephyr-version.sh <new_version> [--template-only|--all]

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

if [ $# -lt 1 ]; then
    echo -e "${RED}Bruk: $0 <new_version> [--template-only|--all]${NC}"
    echo ""
    echo "Eksempel:"
    echo -e "  $0 v4.2.1                    # Oppdater berre template"
    echo -e "  $0 v4.2.1 --all              # Oppdater template + alle prosjekt"
    echo -e "  $0 v4.2.1 --template-only    # Oppdater kun template"
    echo ""
    echo "Populære versjonar:"
    echo -e "  ${GREEN}v4.2.1${NC} - Latest stable (October 2024)"
    echo -e "  ${GREEN}v3.7.1${NC} - LTS release (July 2024)"
    echo -e "  ${CYAN}main${NC}   - Bleeding edge (ikke anbefalt)"
    exit 1
fi

NEW_VERSION=$1
UPDATE_MODE=${2:-"--template-only"}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
META_ROOT="$(dirname "$SCRIPT_DIR")"
TEMPLATE_FILE="$META_ROOT/templates/west.yml"
BOARDS_DIR="$META_ROOT/boards"

echo -e "${BLUE}=== Zephyr Version Update ===${NC}"
echo -e "${CYAN}Ny versjon: $NEW_VERSION${NC}"
echo -e "${CYAN}Mode: $UPDATE_MODE${NC}"
echo ""

# Bekreftelse
read -p "Er du sikker? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Avbryt${NC}"
    exit 0
fi

# Oppdater template
echo -e "${YELLOW}→ Oppdaterer template...${NC}"
if [ -f "$TEMPLATE_FILE" ]; then
    sed -i "s/revision: .*/revision: $NEW_VERSION/" "$TEMPLATE_FILE"
    echo -e "${GREEN}✓ Template oppdatert til $NEW_VERSION${NC}"
else
    echo -e "${RED}✗ Template ikke funnet${NC}"
    exit 1
fi

# Oppdater alle prosjekt hvis --all
if [ "$UPDATE_MODE" == "--all" ]; then
    echo ""
    echo -e "${YELLOW}→ Oppdaterer alle board-prosjekt...${NC}"

    for project_dir in "$BOARDS_DIR"/*; do
        if [ ! -d "$project_dir" ]; then
            continue
        fi

        project_name=$(basename "$project_dir")
        west_file="$project_dir/west.yml"

        if [ ! -f "$west_file" ]; then
            echo -e "  ${project_name}: ${YELLOW}Ingen west.yml, hoppar over${NC}"
            continue
        fi

        # Oppdater west.yml
        OLD_VERSION=$(grep "revision:" "$west_file" | awk '{print $2}')
        sed -i "s/revision: .*/revision: $NEW_VERSION/" "$west_file"
        echo -e "  ${project_name}: ${CYAN}$OLD_VERSION${NC} → ${GREEN}$NEW_VERSION${NC}"

        # Køyr west update hvis zephyr/ eksisterer
        if [ -d "$project_dir/zephyr" ]; then
            echo -e "    ${YELLOW}Køyrer west update...${NC}"
            cd "$project_dir"
            if west update > /dev/null 2>&1; then
                echo -e "    ${GREEN}✓ West update suksess${NC}"
            else
                echo -e "    ${RED}✗ West update feila${NC}"
            fi
            cd - > /dev/null
        fi
    done
fi

echo ""
echo -e "${GREEN}✓ Oppdatering ferdig!${NC}"
echo ""
echo -e "${YELLOW}Neste steg:${NC}"
if [ "$UPDATE_MODE" == "--template-only" ]; then
    echo -e "  1. Nye prosjekt vil bruke ${GREEN}$NEW_VERSION${NC}"
    echo -e "  2. Eksisterande prosjekt må oppdaterast manuelt:"
    echo -e "     - Rediger boards/<project>/west.yml"
    echo -e "     - Køyr: cd boards/<project> && west update"
    echo -e "  3. Eller køyr: $0 $NEW_VERSION --all"
else
    echo -e "  1. Test bygg alle prosjekt:"
    echo -e "     ./scripts/build-all.sh"
    echo -e "  2. Commit endringane:"
    echo -e "     git add ."
    echo -e "     git commit -m \"Update Zephyr to $NEW_VERSION\""
    echo -e "     git push"
    echo -e "  3. Oppdater submodules i meta-repo:"
    echo -e "     cd boards/<project> && git add west.yml && git commit -m \"Update Zephyr to $NEW_VERSION\" && git push"
    echo -e "     cd ../.. && git submodule update --remote --merge"
fi
