#!/bin/bash

# ===================================================

#  PTERODACTYL UNINSTALLER - NEXT GEN ULTRA EDITION

#                     2025 Edition

# ===================================================

#  Original Creator: MahimOp

#  YouTube : https://www.youtube.com/@mahimxyz

#  Discord : https://discord.gg/zkDNdPpArS

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

DANGER="\e[38;5;196m"

clear

# Epic Warning Header

echo -e "${NEON_BLUE}"

cat << "EOF"

   _____   __  __   _____   _   _   _   _   _____   _   _   _____   _     

  |  __ \ / _|/ _| |  __ \ | \ | | | \ | | |  __ \ | \ | | |  __ \ | |    

  | |__) | |_| |_  | |__) | |  \| | |  \| | | |__) | |  \| | | |__) | | |    

  |  ___/|  _|  _| |  _  /  | . ` | | . ` | |  ___/  | . ` | |  _  /  | |    

  | |    | | | |   | | \ \  | |\  | | |\  | | |      | |\  | | | \ \  | |____

  |_|    |_| |_|   |_|  \_\ |_| \_| |_| \_| |_|      |_| \_| |_|  \_\ |______|

                                                                            

EOF

echo -e "${DANGER}${BOLD}                ⚡ DANGEROUS UNINSTALLER ⚡${RESET}"

echo -e "${NEON_PURPLE}${BOLD}                NEXT GEN ULTRA EDITION - 2025${RESET}"

echo -e "${GLOW}           Irreversible • Fast • Complete Removal${RESET}"

echo -e "${DIM}      Original Creator: ${BOLD}MahimOp${RESET} ${DIM}| YouTube: @mahimxyz${RESET}"

echo -e "${DIM}      Discord: https://discord.gg/zkDNdPpArS${RESET}"

echo -e "${NEON_BLUE}══════════════════════════════════════════════════════════${RESET}\n"

# Status Functions

progress() { echo -e "${NEON_GREEN}${BOLD}➤ $1${RESET}"; }

success() { echo -e "${GREEN}${BOLD}✓ $1${RESET}"; }

warning() { echo -e "${YELLOW}${BOLD}! $1${RESET}"; }

danger() { echo -e "${DANGER}${BOLD}⚠ $1${RESET}"; }

error() { echo -e "${RED}${BOLD}✘ $1${RESET}"; }

# Confirmation with style

confirm_action() {

    local message="$1"

    echo -e "\n${DANGER}${BOLD}DANGER ZONE${RESET}"

    echo -e "${YELLOW}${BOLD}   $message${RESET}\n"

    read -p $'\e[93m\e[1m   Are you ABSOLUTELY sure? Type "YES" to continue: \e[0m' -r REPLY

    echo

    if [[ "$REPLY" == "YES" ]]; then

        return 0

    else

        echo -e "${GREEN}${BOLD}   Operation cancelled safely.${RESET}\n"

        return 1

    fi

}

# Cleanup Nginx

cleanup_nginx() {

    progress "Cleaning Pterodactyl Nginx configurations..."

    rm -f /etc/nginx/sites-enabled/pterodactyl.conf 2>/dev/null && success "Removed sites-enabled config"

    rm -f /etc/nginx/sites-available/pterodactyl.conf 2>/dev/null && success "Removed sites-available config"

    rm -f /etc/nginx/conf.d/pterodactyl.conf 2>/dev/null && success "Removed conf.d config"

    

    if command -v nginx >/dev/null 2>&1; then

        systemctl restart nginx >/dev/null 2>&1 && success "Nginx restarted"

    fi

}

# Uninstall Panel

uninstall_panel() {

    echo -e "${NEON_PURPLE}${BOLD}╔════════════════════════════════════════╗${RESET}"

    echo -e "${NEON_PURPLE}${BOLD}║     UNINSTALLING PTERODACTYL PANEL      ║${RESET}"

    echo -e "${NEON_PURPLE}${BOLD}╚════════════════════════════════════════╝${RESET}\n"

    if ! confirm_action "This will PERMANENTLY delete the Panel, database, and all servers."; then

        return

    fi

    progress "Stopping queue worker..."

    systemctl stop pteroq.service 2>/dev/null || true

    systemctl disable pteroq.service 2>/dev/null || true

    rm -f /etc/systemd/system/pteroq.service

    systemctl daemon-reload

    success "Queue worker removed"

    progress "Removing cron job..."

    (crontab -l 2>/dev/null | grep -v '/var/www/pterodactyl/artisan schedule:run') | crontab - 2>/dev/null || true

    success "Cron job cleared"

    progress "Deleting panel files..."

    rm -rf /var/www/pterodactyl

    success "Panel directory removed"

    progress "Dropping database and user..."

    mysql -e "DROP DATABASE IF EXISTS panel;" 2>/dev/null || true

    mysql -e "DROP USER IF EXISTS 'pterodactyl'@'127.0.0.1';" 2>/dev/null || true

    mysql -e "FLUSH PRIVILEGES;" 2>/dev/null || true

    success "Database cleaned"

    cleanup_nginx

    echo -e "\n${GREEN}${BOLD}✓ Pterodactyl Panel completely uninstalled!${RESET}\n"

}

# Uninstall Wings

uninstall_wings() {

    echo -e "${NEON_PURPLE}${BOLD}╔════════════════════════════════════════╗${RESET}"

    echo -e "${NEON_PURPLE}${BOLD}║      UNINSTALLING PTERODACTYL WINGS     ║${RESET}"

    echo -e "${NEON_PURPLE}${BOLD}╚════════════════════════════════════════╝${RESET}\n"

    if ! confirm_action "This will PERMANENTLY delete Wings and all server data/volumes."; then

        return

    fi

    progress "Stopping Wings service..."

    systemctl stop wings 2>/dev/null || true

    systemctl disable wings 2>/dev/null || true

    rm -f /etc/systemd/system/wings.service

    systemctl daemon-reload

    success "Wings service removed"

    progress "Deleting Wings data..."

    rm -rf /etc/pterodactyl /var/lib/pterodactyl /var/log/pterodactyl

    rm -f /usr/local/bin/wings /usr/local/bin/wing

    success "All Wings files removed"

    echo -e "\n${GREEN}${BOLD}✓ Pterodactyl Wings completely uninstalled!${RESET}\n"

}

# Uninstall Both

uninstall_both() {

    echo -e "${DANGER}${BOLD}╔══════════════════════════════════════════════════╗${RESET}"

    echo -e "${DANGER}${BOLD}║         NUCLEAR OPTION: PANEL + WINGS             ║${RESET}"

    echo -e "${DANGER}${BOLD}╚══════════════════════════════════════════════════╝${RESET}\n"

    if ! confirm_action "This will ERASE EVERYTHING: Panel, Wings, databases, servers."; then

        return

    fi

    uninstall_panel

    uninstall_wings

    echo -e "${GREEN}${BOLD}✓ Full Pterodactyl system has been obliterated.${RESET}\n"

}

# Menu

show_menu() {

    clear

    echo -e "${NEON_BLUE}"

    cat << "EOF"

   __  __                                                  __  

  / /_/ /_  ___  ____  ____  _________  ____  ____  __  __/ /_

 / __/ __ \/ _ \/ __ \/ __ \/ ___/ __ \/ __ \/ __ \/ / / / __/

/ /_/ / / /  __/ / / / /_/ / /  / /_/ / /_/ / /_/ / /_/ / /_  

\__/_/ /_/\___/_/ /_/\____/_/   \____/\____/\____/\__,_/\__/  

                                                              

EOF

    echo -e "${DANGER}${BOLD}                PTERODACTYL UNINSTALLER${RESET}"

    echo -e "${NEON_PURPLE}${BOLD}                  NEXT GEN ULTRA EDITION${RESET}\n"

    echo -e "${GLOW}${BOLD}╔══════════════════════════════════════════════════╗${RESET}"

    echo -e "${CYAN}${BOLD}   Select Removal Option:${RESET}"

    echo -e "${GLOW}${BOLD}╠══════════════════════════════════════════════════╣${RESET}"

    echo -e "${YELLOW}   ${GREEN}${BOLD}1)${RESET} ${WHITE}Uninstall Panel Only${RESET}"

    echo -e "${YELLOW}   ${GREEN}${BOLD}2)${RESET} ${WHITE}Uninstall Wings Only${RESET}"

    echo -e "${YELLOW}   ${GREEN}${BOLD}3)${RESET} ${WHITE}Uninstall Panel + Wings (Nuclear)${RESET}"

    echo -e "${YELLOW}   ${RED}${BOLD}0)${RESET} ${WHITE}Exit Uninstaller${RESET}"

    echo -e "${GLOW}${BOLD}╚══════════════════════════════════════════════════╝${RESET}\n"

    danger "All actions are IRREVERSIBLE. Data will be permanently deleted!"

    echo -e "\n${NEON_GREEN}${BOLD}Original Credits: MahimOp${RESET}"

    echo -e "${DIM}YouTube: https://www.youtube.com/@mahimxyz${RESET}"

    echo -e "${DIM}Discord: https://discord.gg/zkDNdPpArS${RESET}\n"

}

# Main Loop

while true; do

    show_menu

    read -p $'\e[93m\e[1mChoose option [0-3]: \e[0m' choice

    echo

    case $choice in

        1) uninstall_panel ;;

        2) uninstall_wings ;;

        3) uninstall_both ;;

        0) 

            echo -e "${GREEN}${BOLD}Exiting uninstaller safely. Goodbye!${RESET}\n"

            exit 0

            ;;

        *) 

            error "Invalid choice! Please select 0–3."

            sleep 2

            ;;

    esac

    echo -e "${YELLOW}Press Enter to return to menu...${RESET}"

    read -r

done
