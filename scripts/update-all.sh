#!/bin/bash
# update-all.sh - Oppdater alle submodules og Zephyr workspace
# Bruk: ./update-all.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
META_ROOT="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}=== Oppdaterer zephyr-meta ===${NC}"
echo ""

# Oppdater meta-repo
echo -e "${YELLOW}→ Oppdaterer meta-repo...${NC}"
cd "$META_ROOT"
git pull
echo -e "${GREEN}✓ Meta-repo oppdatert${NC}"

# Oppdater submodules
if [ -f ".gitmodules" ]; then
    echo ""
    echo -e "${YELLOW}→ Oppdaterer submodules...${NC}"
    git submodule update --remote --merge
    echo -e "${GREEN}✓ Submodules oppdatert${NC}"
fi

# Oppdater Zephyr workspace i alle board-prosjekt
echo ""
echo -e "${YELLOW}→ Oppdaterer Zephyr workspace i alle prosjekt...${NC}"

for project_dir in "$META_ROOT/boards"/*; do
    if [ ! -d "$project_dir" ]; then
        continue
    fi

    project_name=$(basename "$project_dir")

    if [ ! -f "$project_dir/west.yml" ]; then
        continue
    fi

    echo -e "${YELLOW}  → $project_name${NC}"
    cd "$project_dir"

    if [ -d "zephyr" ]; then
        west update
        echo -e "${GREEN}    ✓ $project_name oppdatert${NC}"
    else
        echo -e "${YELLOW}    ⊘ Zephyr ikkje initialisert, hoppar over${NC}"
    fi
done

cd "$META_ROOT"

echo ""
echo -e "${GREEN}✓ Alle prosjekt oppdatert! 🎉${NC}"
