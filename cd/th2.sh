#!/bin/bash

# ===================================================
#  NEBULA BLUEPRINT INSTALLER - NEXT GEN ULTRA EDITION
#                     2025 Edition
# ===================================================
#  Original Creator: MahimOp
#  YouTube : https://www.youtube.com/@mahimxyz
#  Discord : https://discord.gg/zkDNdPpArS
# ===================================================

set -e

# Next-Gen Color Theme
RESET="\e[0m"
BOLD="\e[1m"
DIM="\e[2m"
UNDERLINE="\e[4m"

CYAN="\e[96m"
BLUE="\e[94m"
PURPLE="\e[95m"
GREEN="\e[92m"
YELLOW="\e[93m"
RED="\e[91m"
WHITE="\e[97m"

NEON_GREEN="\e[38;5;82m"
NEON_PURPLE="\e[38;5;165m"
NEON_BLUE="\e[38;5;75m"
GLOW="\e[38;5;51m"

clear

# Futuristic ASCII Header
echo -e "${NEON_BLUE}"
cat << "EOF"
 ___      ___       __       __    __   __     ___      ___ 
|"  \    /"  |     /""\     /" |  | "\ |" \   |"  \    /"  |
 \   \  //   |    /    \   (:  (__)  :)||  |   \   \  //   |
 /\\  \/.    |   /' /\  \   \/      \/ |:  |   /\\  \/.    |
|: \.        |  //  __'  \  //  __  \\ |.  |  |: \.        |
|.  \    /:  | /   /  \\  \(:  (  )  :)/\  |\ |.  \    /:  |
|___|\__/|___|(___/    \___)\__|  |__/(__\_|_)|___|\__/|___|
                                                            
                                     
EOF
echo -e "${NEON_PURPLE}${BOLD}             NEXT GEN ULTRA EDITION - 2025${RESET}"
echo -e "${GLOW}       Seamless • Fast • Future-Proof Automation${RESET}"
echo -e "${DIM}      Original Creator: ${BOLD}MahimOp${RESET} ${DIM}| YouTube: @mahimxyz${RESET}"
echo -e "${DIM}      Discord: https://discord.gg/zkDNdPpArS${RESET}"
echo -e "${NEON_BLUE}══════════════════════════════════════════════════════════${RESET}\n"

# Status Functions
progress() { echo -e "${NEON_GREEN}${BOLD}➤ $1${RESET}"; }
success() { echo -e "${GREEN}${BOLD}✓ $1${RESET}"; }
warning() { echo -e "${YELLOW}${BOLD}! $1${RESET}"; }
error() { echo -e "${RED}${BOLD}✘ $1${RESET}"; }

# Root Check
if [ "$EUID" -ne 0 ]; then
    error "This script must be run as root (use sudo)"
    exit 1
fi

TARGET_DIR="/var/www/pterodactyl"
TEMP_REPO="/tmp/ak-mahimxyzz-bot"

progress "Preparing environment..."

# Clean old temp
rm -rf "$TEMP_REPO" >/dev/null 2>&1

# Create target
mkdir -p "$TARGET_DIR"

progress "Downloading Nebula Blueprint from repository..."
git clone https://github.com/mahimxyzz/Vps.git "$TEMP_REPO" >/dev/null 2>&1 || {
    error "Failed to clone repository. Check internet or repo URL."
    exit 1
}
success "Repository downloaded!"

SOURCE_FILE="$TEMP_REPO/nebula.blueprint"

if [ ! -f "$SOURCE_FILE" ]; then
    error "nebula.blueprint not found in repository!"
    rm -rf "$TEMP_REPO"
    exit 1
fi

progress "Deploying nebula.blueprint to panel..."
mv "$SOURCE_FILE" "$TARGET_DIR/" && success "Blueprint deployed to $TARGET_DIR"
rm -rf "$TEMP_REPO"
success "Cleanup complete!"

progress "Checking for Blueprint framework..."
if command -v blueprint >/dev/null 2>&1; then
    success "Blueprint tool detected!"
else
    warning "Blueprint tool not found. Installing now..."
    curl -sSL https://blueprint.zip/install.sh | bash
    if command -v blueprint >/dev/null 2>&1; then
        success "Blueprint installed successfully!"
    else
        error "Failed to install Blueprint tool."
        exit 1
    fi
fi

progress "Executing Nebula Blueprint (this may take a moment)..."
cd "$TARGET_DIR"

# Run with output visible for user feedback
blueprint -i nebula.blueprint || {
    error "Blueprint execution failed. Check logs or compatibility."
    exit 1
}

success "Nebula Blueprint executed successfully!"

# Epic Completion Screen
clear
echo -e "${NEON_BLUE}"
cat << "EOF"
 ___      ___       __       __    __   __     ___      ___ 
|"  \    /"  |     /""\     /" |  | "\ |" \   |"  \    /"  |
 \   \  //   |    /    \   (:  (__)  :)||  |   \   \  //   |
 /\\  \/.    |   /' /\  \   \/      \/ |:  |   /\\  \/.    |
|: \.        |  //  __'  \  //  __  \\ |.  |  |: \.        |
|.  \    /:  | /   /  \\  \(:  (  )  :)/\  |\ |.  \    /:  |
|___|\__/|___|(___/    \___)\__|  |__/(__\_|_)|___|\__/|___|
                                                            
EOF
echo -e "${NEON_PURPLE}${BOLD}       ✨ NEBULA INSTALLATION COMPLETE ✨${RESET}\n"

echo -e "${GLOW}${BOLD}╔══════════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}${BOLD}   Blueprint File:${RESET} ${WHITE}${UNDERLINE}${TARGET_DIR}/nebula.blueprint${RESET}"
echo -e "${GLOW}${BOLD}╚══════════════════════════════════════════════════════════╝${RESET}\n"

echo -e "${YELLOW}${BOLD}🚀 Next Steps:${RESET}"
echo -e "   ${NEON_GREEN}•${RESET} Clear cache: ${BOLD}php artisan view:clear && php artisan config:clear${RESET}"
echo -e "   ${NEON_GREEN}•${RESET} Restart queue: ${BOLD}php artisan queue:restart${RESET}"
echo -e "   ${NEON_GREEN}•${RESET} Refresh panel in browser (Ctrl+Shift+R for hard refresh)"
echo -e "   ${NEON_GREEN}•${RESET} Enjoy the stunning Nebula theme!${RESET}\n"

warning "Always backup your panel before installing extensions!"

echo -e "${NEON_GREEN}${BOLD}Original Credits: MahimOp${RESET}"
echo -e "${DIM}YouTube: https://www.youtube.com/@mahimxyz${RESET}"
echo -e "${DIM}Discord: https://discord.gg/zkDNdPpArS${RESET}\n"

echo -e "${GLOW}${BOLD}Your Pterodactyl Panel now shines with Nebula! 🌌✨${RESET}"
echo -e "\n${YELLOW}Press Enter to exit...${RESET}"
read -r
