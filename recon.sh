#!/bin/sh
#
# recon.sh - Comprehensive hardware/system audit script using inxi.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/christophermarklee/pc-info/main/recon.sh | sh
#   or: sudo sh recon.sh
#

set -e

# Detect privilege requirements
SUDO_CMD=""
if [ "$(id -u)" -ne 0 ]; then
    if command -v sudo >/dev/null 2>&1; then
        SUDO_CMD="sudo"
    fi
fi

install_package() {
    PKG="$1"
    
    if command -v apt-get >/dev/null 2>&1; then
        $SUDO_CMD apt-get update -y
        $SUDO_CMD apt-get install -y "$PKG" dmidecode pciutils
    elif command -v apt >/dev/null 2>&1; then
        $SUDO_CMD apt update -y
        $SUDO_CMD apt install -y "$PKG" dmidecode pciutils
    elif command -v dnf >/dev/null 2>&1; then
        $SUDO_CMD dnf install -y epel-release >/dev/null 2>&1 || true
        $SUDO_CMD dnf install -y "$PKG" dmidecode pciutils
    elif command -v yum >/dev/null 2>&1; then
        $SUDO_CMD yum install -y epel-release >/dev/null 2>&1 || true
        $SUDO_CMD yum install -y "$PKG" dmidecode pciutils
    elif command -v pacman >/dev/null 2>&1; then
        $SUDO_CMD pacman -Sy --noconfirm "$PKG" dmidecode pciutils
    elif command -v zypper >/dev/null 2>&1; then
        $SUDO_CMD zypper --non-interactive install "$PKG" dmidecode pciutils
    elif command -v apk >/dev/null 2>&1; then
        $SUDO_CMD apk add --no-cache "$PKG" dmidecode pciutils
    elif command -v brew >/dev/null 2>&1; then
        if [ "$(id -u)" -eq 0 ] && [ -n "${SUDO_USER:-}" ]; then
            su - "$SUDO_USER" -c "brew install $PKG"
        else
            brew install "$PKG"
        fi
    elif command -v xbps-install >/dev/null 2>&1; then
        $SUDO_CMD xbps-install -y "$PKG" dmidecode pciutils
    elif command -v emerge >/dev/null 2>&1; then
        $SUDO_CMD emerge --ask=n "$PKG"
    else
        echo "Error: Unable to determine package manager to install dependencies." >&2
        exit 1
    fi
}

check_dependencies() {
    if ! command -v inxi >/dev/null 2>&1; then
        echo "inxi not found. Attempting to install inxi and helper utilities..."
        
        if [ "$(id -u)" -ne 0 ] && [ -z "$SUDO_CMD" ] && ! command -v brew >/dev/null 2>&1; then
            echo "Error: Root or sudo privileges required to install packages." >&2
            exit 1
        fi
        
        install_package inxi
    fi

    if ! command -v inxi >/dev/null 2>&1; then
        echo "Error: inxi installation failed or binary is missing from PATH." >&2
        exit 1
    fi
}

check_dependencies

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
HOSTNAME_STR="$(hostname 2>/dev/null || echo 'localhost')"
LOG_FILE="/tmp/recon_${HOSTNAME_STR}_${TIMESTAMP}.log"

INXI_FLAGS="-Fzm -c 0"

echo "=== Starting System Reconnaissance ==="
echo "Timestamp: $(date)"
echo "Saving log to: ${LOG_FILE}"
echo "----------------------------------------"

# Run report, strip any leftover IRC color control sequences, and log output
if [ "$(id -u)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
    sudo inxi $INXI_FLAGS 2>&1 | sed -E 's/\x03[0-9]{1,2}//g; s/\x0f//g' | tee "$LOG_FILE"
else
    inxi $INXI_FLAGS 2>&1 | sed -E 's/\x03[0-9]{1,2}//g; s/\x0f//g' | tee "$LOG_FILE"
fi

echo "----------------------------------------"
echo "Recon report completed and saved to: ${LOG_FILE}"