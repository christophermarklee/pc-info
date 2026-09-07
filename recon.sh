#!/bin/sh
#
# recon.sh - Gather a quick hardware/system report using inxi.
#
# Installs inxi (if it isn't already available) using whatever package
# manager is present on the system, then runs:
#   inxi -m -C -G -D -M -z
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/christophermarklee/pc-info/main/recon.sh | sudo sh
#

set -e

# Installing packages requires root. The script is designed to be invoked as
# `sudo sh recon.sh` (or piped via `curl ... | sudo sh`), so bail out early
# with a clear message if we don't have the privileges we need.
if [ "$(id -u)" -ne 0 ]; then
	echo "This script must be run as root, e.g.: sudo sh $0" >&2
	exit 1
fi

install_inxi() {
	if command -v inxi >/dev/null 2>&1; then
		return 0
	fi

	echo "inxi not found, attempting to install it..."

	if command -v apt-get >/dev/null 2>&1; then
		apt-get update -y
		apt-get install -y inxi
	elif command -v apt >/dev/null 2>&1; then
		apt update -y
		apt install -y inxi
	elif command -v dnf >/dev/null 2>&1; then
		dnf install -y inxi
	elif command -v yum >/dev/null 2>&1; then
		yum install -y inxi
	elif command -v pacman >/dev/null 2>&1; then
		pacman -Sy --noconfirm inxi
	elif command -v zypper >/dev/null 2>&1; then
		zypper --non-interactive install inxi
	elif command -v apk >/dev/null 2>&1; then
		apk add --no-cache inxi
	elif command -v brew >/dev/null 2>&1; then
		brew install inxi
	elif command -v xbps-install >/dev/null 2>&1; then
		xbps-install -y inxi
	elif command -v emerge >/dev/null 2>&1; then
		emerge --ask=n inxi
	else
		echo "Unable to determine package manager to install inxi." >&2
		echo "Please install inxi manually and re-run this script." >&2
		exit 1
	fi

	if ! command -v inxi >/dev/null 2>&1; then
		echo "inxi installation appears to have failed." >&2
		exit 1
	fi
}

install_inxi

inxi -m -C -G -D -M -z
