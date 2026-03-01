#!/usr/bin/env bash

# ===================================================

#  PTERODACTYL PANEL UPDATER - NEXT GEN ULTRA EDITION

#                     2026 Edition

# ===================================================

#  Original Creator: ShadowOP

#  YouTube : https://www.youtube.com/@ShadowCraftMC_YT

# ===================================================

set -e

# Next-Gen Neon Color Theme

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

# Futuristic Header

echo -e "${NEON_BLUE}"

cat << "EOF"

    ____    _   _      _      ____     ___   __        __
/ ___|  | | | |    / \    |  _ \   / _ \  \ \      / /
\___ \  | |_| |   / _ \   | | | | | | | |  \ \ /\ / / 
 ___) | |  _  |  / ___ \  | |_| | | |_| |   \ V  V /  
|____/  |_| |_| /_/   \_\ |____/   \___/     \_/\_/   

                                                     

        ____    _   _      _      ____     ___   __        __
/ ___|  | | | |    / \    |  _ \   / _ \  \ \      / /
\___ \  | |_| |   / _ \   | | | | | | | |  \ \ /\ / / 
 ___) | |  _  |  / ___ \  | |_| | | |_| |   \ V  V /  
|____/  |_| |_| /_/   \_\ |____/   \___/     \_/\_/   

                                                  

EOF

echo -e "${NEON_PURPLE}${BOLD}             NEXT GEN ULTRA EDITION - 2026${RESET}"

echo -e "${GLOW}           Seamless • Zero-Downtime • Future-Proof${RESET}"

echo -e "${DIM}      Original Creator: ${BOLD}ShadowOP${RESET} ${DIM}| YouTube: @ShadowCraftMC_YT${RESET}"

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

PANEL_DIR="/var/www/pterodactyl"

if [ ! -d "$PANEL_DIR" ]; then

    error "Pterodactyl panel directory not found at $PANEL_DIR"

    exit 1

fi

progress "Navigating to panel directory..."

cd "$PANEL_DIR"

success "Ready in $PANEL_DIR"

progress "Enabling maintenance mode..."

php artisan down >/dev/null 2>&1

success "Panel is now in maintenance mode"

progress "Downloading latest Pterodactyl Panel release..."

curl -L https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz | tar -xzv >/dev/null 2>&1

success "Latest version downloaded & extracted"

progress "Setting storage permissions..."

chmod -R 755 storage/* bootstrap/cache >/dev/null 2>&1

success "Permissions updated"

progress "Installing/updating Composer dependencies..."

composer install --no-dev --optimize-autoloader --quiet

success "Dependencies installed"

progress "Clearing cached views and config..."

php artisan view:clear >/dev/null 2>&1

php artisan config:clear >/dev/null 2>&1

success "Caches cleared"

progress "Running database migrations..."

php artisan migrate --seed --force >/dev/null 2>&1

success "Migrations completed"

progress "Correcting file ownership..."

chown -R www-data:www-data "$PANEL_DIR" >/dev/null 2>&1

success "Ownership set to www-data"

progress "Restarting queue workers..."

php artisan queue:restart >/dev/null 2>&1

success "Queue workers restarted"

progress "Disabling maintenance mode..."

php artisan up >/dev/null 2>&1

success "Panel is back online!"

# Epic Completion Screen

clear

echo -e "${NEON_BLUE}"

cat << "EOF"

    ____    _   _      _      ____     ___   __        __
/ ___|  | | | |    / \    |  _ \   / _ \  \ \      / /
\___ \  | |_| |   / _ \   | | | | | | | |  \ \ /\ / / 
 ___) | |  _  |  / ___ \  | |_| | | |_| |   \ V  V /  
|____/  |_| |_| /_/   \_\ |____/   \___/     \_/\_/   
                                                     

EOF

echo -e "${NEON_PURPLE}${BOLD}       ✨ PANEL UPDATE COMPLETE ✨${RESET}\n"

echo -e "${GLOW}${BOLD}╔══════════════════════════════════════════════════════════╗${RESET}"

echo -e "${CYAN}${BOLD}   Your Pterodactyl Panel is now running the latest version!${RESET}"

echo -e "${GLOW}${BOLD}╚══════════════════════════════════════════════════════════╝${RESET}\n"

echo -e "${YELLOW}${BOLD}📋 Update Summary:${RESET}"

echo -e "   ${NEON_GREEN}•${RESET} Maintenance mode handled automatically"

echo -e "   ${NEON_GREEN}•${RESET} Latest panel files deployed"

echo -e "   ${NEON_GREEN}•${RESET} Permissions & ownership fixed"

echo -e "   ${NEON_GREEN}•${RESET} Composer dependencies updated"

echo -e "   ${NEON_GREEN}•${RESET} Caches cleared"

echo -e "   ${NEON_GREEN}•${RESET} Database migrated safely"

echo -e "   ${NEON_GREEN}•${RESET} Queue workers restarted\n"

echo -e "${YELLOW}${BOLD}🚀 Next Steps:${RESET}"

echo -e "   ${NEON_GREEN}•${RESET} Visit your panel and verify everything works"

echo -e "   ${NEON_GREEN}•${RESET} Check the admin area for new features/changelog"

echo -e "   ${NEON_GREEN}•${RESET} Monitor servers and logs for any issues\n"

echo -e "${NEON_GREEN}${BOLD}Original Credits: ShadowOP${RESET}"

echo -e "${DIM}YouTube: https://www.youtube.com/@ShadowCraftMC_YT${RESET}"

echo -e "${GLOW}${BOLD}Enjoy the upgraded experience! 🦅✨${RESET}"

echo -e "\n${YELLOW}Press Enter to exit...${RESET}"

read -r
