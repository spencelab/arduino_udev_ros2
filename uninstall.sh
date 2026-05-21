#!/usr/bin/env bash
set -euo pipefail

echo "[arduino-udev] Removing installed files..."
sudo rm -f /usr/lib/python3/dist-packages/arduinoudev.py
sudo rm -f /usr/lib/python3/dist-packages/__pycache__/arduinoudev*.pyc
sudo rm -f /usr/bin/arduino-udev-name
sudo rm -f /etc/udev/rules.d/99-arduino-udev.rules

echo "[arduino-udev] Reloading udev rules..."
sudo udevadm control --reload-rules
sudo udevadm trigger || true

echo "[arduino-udev] Uninstall complete."