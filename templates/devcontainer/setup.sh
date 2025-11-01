#!/bin/bash
set -e

echo "=== Zephyr Development Setup for {{PROJECT_DISPLAY_NAME}} ==="

cd /workspaces/{{PROJECT_NAME}}

# Initialize Zephyr workspace if not already done
if [ ! -d "zephyr" ]; then
    echo "Initializing Zephyr workspace..."
    west init -l .

    echo "Downloading Zephyr and modules (this takes time)..."
    west update --narrow -o=--depth=1

    echo "Exporting Zephyr CMake packages..."
    west zephyr-export

    echo "Installing Python requirements..."
    if [ -f "zephyr/scripts/requirements.txt" ]; then
        pip3 install -r zephyr/scripts/requirements.txt
    else
        echo "Warning: requirements.txt not found, skipping..."
    fi
else
    echo "Zephyr already initialized"
fi

# Install Zephyr SDK if not present
if [ ! -d "zephyr-sdk-0.16.8" ]; then
    echo "Installing Zephyr SDK..."
    wget -q --show-progress https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v0.16.8/zephyr-sdk-0.16.8_linux-x86_64_minimal.tar.xz
    tar xf zephyr-sdk-0.16.8_linux-x86_64_minimal.tar.xz
    rm zephyr-sdk-0.16.8_linux-x86_64_minimal.tar.xz

    cd zephyr-sdk-0.16.8
    # Install toolchain based on board architecture
    {{TOOLCHAIN_INSTALL_CMD}}
    cd ..
else
    echo "Zephyr SDK already installed"
fi

echo ""
echo "=== Setup complete! ==="
echo "Build with: west build -b {{BOARD_NAME}} app"
echo "Flash with: {{FLASH_COMMAND}}"
