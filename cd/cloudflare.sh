#!/bin/bash

# === Cloudflared Installation Script ===
# Made by MahimOp
# YouTube: https://youtube.com/@mahimxyz
# Discord: https://discord.gg/EHBvzYbh57
# Compatible with Debian/Ubuntu-based systems

set -euo pipefail  # Fail on errors, unset variables, and pipeline failures

# Enhanced Colors (Bold + Bright)
BOLD="\033[1m"
GREEN="\033[1;32m"
BRIGHT_GREEN="\033[1;92m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
CYAN="\033[1;36m"
BLUE="\033[1;34m"
MAGENTA="\033[1;35m"
NC="\033[0m" # No Color

# Fancy header
echo -e "${BLUE}${BOLD}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}${BOLD}║          Cloudflared Installation Script                 ║${NC}"
echo -e "${BLUE}${BOLD}║              Made by MahimOp                             ║${NC}"
echo -e "${BLUE}${BOLD}║    YouTube: youtube.com/@mahimxyz                        ║${NC}"
echo -e "${BLUE}${BOLD}║    Discord: discord.gg/EHBvzYbh57                        ║${NC}"
echo -e "${BLUE}${BOLD}╚══════════════════════════════════════════════════════════╝${NC}"
echo -e "${MAGENTA}${BOLD}[*] Starting installation process...${NC}\n"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    SUDO=""
else
    SUDO="sudo"
fi

# Check if already installed
if command -v cloudflared >/dev/null 2>&1; then
    echo -e "${YELLOW}${BOLD}[!] cloudflared is already installed!${NC}"
    echo -e "${CYAN}    Version:${NC} $(cloudflared --version)"
    echo -e "${BRIGHT_GREEN}${BOLD}[✓] Nothing to do – you're good to go!${NC}\n"
    exit 0
fi

# Ensure keyrings directory
echo -e "${CYAN}${BOLD}[+] Ensuring keyrings directory exists...${NC}"
$SUDO mkdir -p --mode=0755 /usr/share/keyrings

# Add specified GPG key (cloudflare-public-v2.gpg as requested)
echo -e "${CYAN}${BOLD}[+] Adding Cloudflare GPG key (cloudflare-public-v2.gpg)...${NC}"
curl -fsSL https://pkg.cloudflare.com/cloudflare-public-v2.gpg | \
    $SUDO tee /usr/share/keyrings/cloudflare-public-v2.gpg >/dev/null

# Add repository (idempotent)
REPO_LINE="deb [signed-by=/usr/share/keyrings/cloudflare-public-v2.gpg] https://pkg.cloudflare.com/cloudflared any main"
REPO_FILE="/etc/apt/sources.list.d/cloudflared.list"

if ! grep -qF "$REPO_LINE" "$REPO_FILE" 2>/dev/null; then
    echo -e "${CYAN}${BOLD}[+] Adding Cloudflare repository to sources...${NC}"
    echo "$REPO_LINE" | $SUDO tee "$REPO_FILE" >/dev/null
else
    echo -e "${YELLOW}${BOLD}[!] Repository already configured.${NC}"
fi

# Update and install
echo -e "${CYAN}${BOLD}[+] Updating package list and installing cloudflared...${NC}"
$SUDO apt-get update -qq
$SUDO apt-get install -y cloudflared

# Verify
if command -v cloudflared >/dev/null 2>&1; then
    echo -e "\n${BRIGHT_GREEN}${BOLD}[✓✓✓] cloudflared installed successfully!${NC}"
    echo -e "${CYAN}    Version:${NC} $(cloudflared --version)"
else
    echo -e "\n${RED}${BOLD}[✗✗✗] Installation failed – please check the output above.${NC}"
    exit 1
fi

echo -e "\n${MAGENTA}${BOLD}[*] All done! Run 'cloudflared' to get started.${NC}"
echo -e "${MAGENTA}${BOLD}    Thanks for using this script by MahimOp!${NC}"
echo -e "${BLUE}${BOLD}════════════════════════════════════════════════════════════${NC}"
