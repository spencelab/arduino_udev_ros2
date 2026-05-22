#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PY_DIST="/usr/lib/python3/dist-packages"
BIN_DIR="/usr/bin"
UDEV_RULES_DIR="/etc/udev/rules.d"

echo "[arduino-udev] Installing dependencies..."
sudo apt update
sudo apt install -y python3-serial

echo "[arduino-udev] Installing Python module..."
sudo install -m 0644 "${REPO_DIR}/src/arduinoudev.py" \
  "${PY_DIST}/arduinoudev.py"

echo "[arduino-udev] Installing executable..."
sudo install -m 0755 "${REPO_DIR}/bin/arduino-udev-name" \
  "${BIN_DIR}/arduino-udev-name"

echo "[arduino-udev] Installing udev rules..."
sudo install -m 0644 "${REPO_DIR}/udev/99-arduino-udev.rules" \
  "${UDEV_RULES_DIR}/99-arduino-udev.rules"

echo "[arduino-udev] Reloading udev rules..."
sudo udevadm control --reload-rules
sudo udevadm trigger || true

echo "[arduino-udev] Checking installed files..."
ls -l "${PY_DIST}/arduinoudev.py"
ls -l "${BIN_DIR}/arduino-udev-name"
ls -l "${UDEV_RULES_DIR}/99-arduino-udev.rules"

echo "[arduino-udev] Testing Python import..."
python3 - <<'PY'
import arduinoudev
print("arduinoudev import OK:", arduinoudev.__file__)
PY

echo
echo "[arduino-udev] Install complete."
echo
echo "Next checks:"
echo "  arduino-udev-name /dev/ttyACM0"
echo "  arduino-udev-name /dev/ttyUSB0"
echo "  ls -l /dev/trig* /dev/arduino 2>/dev/null"
echo
echo "If serial permission fails, run:"
echo "  sudo usermod -aG dialout \$USER"
echo "then log out/in or reboot."