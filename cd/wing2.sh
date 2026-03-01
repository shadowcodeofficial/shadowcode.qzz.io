#!/bin/bash
set -e

# Bright + Bold Colors
RED='\033[0;91m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
BLUE='\033[0;94m'
PURPLE='\033[0;95m'
CYAN='\033[0;96m'
WHITE='\033[0;97m'
NC='\033[0m'
BOLD='\033[1m'

# Combined for easy use
B_RED="${RED}${BOLD}"
B_GREEN="${GREEN}${BOLD}"
B_YELLOW="${YELLOW}${BOLD}"
B_BLUE="${BLUE}${BOLD}"
B_PURPLE="${PURPLE}${BOLD}"
B_CYAN="${CYAN}${BOLD}"
B_WHITE="${WHITE}${BOLD}"

# Cool borders
TOP="${B_BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
MID="${B_BLUE}╠══════════════════════════════════════════════════════════════╣${NC}"
BOT="${B_BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
LINE="${B_BLUE}║${NC}                                                              ${B_BLUE}║${NC}"

# Fancy header
print_header() {
    echo -e "$TOP"
    echo -e "$LINE"
    printf "${B_BLUE}║${NC}   ${B_PURPLE}${BOLD}%52s${NC}   ${B_BLUE}║${NC}\n" "$1"
    echo -e "$LINE"
    echo -e "$BOT\n"
}

# Status with cool icons
print_status() {
    echo -e "      ${B_YELLOW}⏳ ${BOLD}$1...${NC}"
}
print_success() {
    echo -e "      ${B_GREEN}✅ ${BOLD}$1${NC}"
}
print_error() {
    echo -e "      ${B_RED}❌ ${BOLD}$1${NC}"
}
print_info() {
    echo -e "      ${B_CYAN}ℹ️ ${BOLD}$1${NC}"
}

check_success() {
    if [ $? -eq 0 ]; then
        print_success "$1"
    else
        print_error "$2"
        return 1
    fi
}

# Ultimate welcome banner with full color + bold
clear
echo -e "${B_BLUE}
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║   ${B_PURPLE}██████╗ ████████╗███████╗██████╗  █████╗  ██████╗████████╗   ${B_BLUE}║
║   ${B_PURPLE}██╔══██╗╚══██╔══╝██╔════╝██╔══██╗██╔══██╗██╔════╝╚══██╔══╝   ${B_BLUE}║
║   ${B_PURPLE}██████╔╝   ██║   █████╗  ██████╔╝███████║██║        ██║      ${B_BLUE}║
║   ${B_PURPLE}██╔═══╝    ██║   ██╔══╝  ██╔══██╗██╔══██║██║        ██║      ${B_BLUE}║
║   ${B_PURPLE}██║        ██║   ███████╗██║  ██║██║  ██║╚██████╗   ██║      ${B_BLUE}║
║   ${B_PURPLE}╚═╝        ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝   ╚═╝      ${B_BLUE}║
║                                                              ║
║            ${B_WHITE}${BOLD}PTERODACTYL WINGS SETUP SCRIPT${B_BLUE}            ║
║                   ${B_CYAN}${BOLD}Powered by MahimOp${B_BLUE}                   ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝${NC}
"

echo -e "      ${B_CYAN}${BOLD}✨ Script created & maintained by MahimOp ✨${NC}"
echo -e "      ${B_PURPLE}${BOLD}📩 Discord Support: https://discord.gg/EHBvzYbh57${NC}\n"

if [ "$EUID" -ne 0 ]; then
    print_error "This script must be run as root! Use sudo."
    exit 1
fi

print_header "🚀 STARTING INSTALLATION 🚀"

# 1. Docker
print_header "INSTALLING DOCKER"
print_status "Installing Docker"
curl -sSL https://get.docker.com/ | CHANNEL=stable bash
check_success "Docker installed"

print_status "Starting Docker service"
sudo systemctl enable --now docker > /dev/null 2>&1
check_success "Docker service started"

# 2. GRUB
print_header "⚙️ SYSTEM OPTIMIZATION"
if [ -f "/etc/default/grub" ]; then
    print_status "Applying required GRUB parameters"
    sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=.*/GRUB_CMDLINE_LINUX_DEFAULT="swapaccount=1"/' /etc/default/grub
    sudo update-grub > /dev/null 2>&1
    check_success "GRUB optimized!" "GRUB update failed"
else
    print_info "GRUB config not found - skipping"
fi

# 3. Wings
print_header "🦅 INSTALLING PTERODACTYL WINGS"
print_status "Creating configuration directory"
sudo mkdir -p /etc/pterodactyl
check_success "Directory created" "Failed to create directory"

print_status "Detecting system architecture"
ARCH=$(uname -m)
if [ "$ARCH" == "x86_64" ]; then
    ARCH="amd64"
elif [ "$ARCH" == "aarch64" ]; then
    ARCH="arm64"
else
    print_error "Unsupported architecture: $ARCH"
    exit 1
fi
print_success "Detected: ${B_WHITE}$ARCH${NC}"

print_status "Downloading latest Wings binary"
curl -L -o /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_$ARCH" > /dev/null 2>&1
check_success "Wings downloaded!" "Download failed"

print_status "Setting executable permissions"
sudo chmod u+x /usr/local/bin/wings
check_success "Permissions applied" "Permission error"

# 4. Service
print_header "🔧 CONFIGURING SYSTEMD SERVICE"
print_status "Creating wings.service file"
sudo tee /etc/systemd/system/wings.service > /dev/null <<EOF
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
LimitNOFILE=4096
ExecStart=/usr/local/bin/wings
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF
check_success "Service file created" "Failed to create service"

print_status "Reloading systemd daemon"
sudo systemctl daemon-reload
check_success "Daemon reloaded" "Reload failed"

print_status "Enabling Wings on boot"
sudo systemctl enable wings
check_success "Wings will start on boot!" "Enable failed"

# 5. SSL
print_header "🔒 GENERATING SSL CERTIFICATE"
print_status "Creating certificate directory"
sudo mkdir -p /etc/certs/wing
cd /etc/certs/wing

print_status "Generating self-signed certificate (10 years)"
sudo openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
  -subj "/CN=localhost" -keyout privkey.pem -out fullchain.pem > /dev/null 2>&1
check_success "SSL certificate ready!" "Certificate generation failed"

# 6. wing helper
print_header "🛠️ INSTALLING 'wing' HELPER COMMAND"
print_status "Deploying quick command helper"
sudo tee /usr/local/bin/wing > /dev/null <<'EOF'
#!/bin/bash
echo -e "\033[0;95m\033[1m
╔════════════════════════════════════════════════════╗
║               ${B_WHITE}WINGS QUICK COMMANDS${PURPLE}                ║
╚════════════════════════════════════════════════════╝
\033[0m"
echo
echo -e "\033[0;96m\033[1m🚀 Start Wings:${NC}       \033[0;92m\033[1msudo systemctl start wings\033[0m"
echo -e "\033[0;96m\033[1m📊 Status:${NC}            \033[0;92m\033[1msudo systemctl status wings\033[0m"
echo -e "\033[0;96m\033[1m📜 Live Logs:${NC}         \033[0;92m\033[1mjournalctl -u wings -f\033[0m"
echo
echo -e "\033[0;93m\033[1m⚠️  Important: Map port 8080 → 443 in node settings!\033[0m"
echo
echo -e "\033[0;94m\033[1m🎧 Support Discord:${NC} https://discord.gg/EHBvzYbh57\033[0m"
echo
EOF
sudo chmod +x /usr/local/bin/wing
check_success "'wing' command installed!" "Helper creation failed"

# Complete message
print_header "🎉 INSTALLATION COMPLETE! 🎉"
echo -e "${B_GREEN}      🦅 Pterodactyl Wings is fully installed and ready to fly!${NC}\n"
echo -e "${B_WHITE}      📋 Next Steps:${NC}"
echo -e " ${B_CYAN}      • Use auto-config below or edit config manually${NC}"
echo -e " ${B_CYAN}      • Start Wings:${B_GREEN} sudo systemctl start wings${NC}"
echo -e " ${B_CYAN}      • Quick help anytime:${B_GREEN} wing${NC}\n"

# Auto-config
echo -e "${B_PURPLE}      🔧 Auto-configure Wings now?${NC}"
read -p "$(echo -e "${B_YELLOW}      [y/N]: ${NC}")" AUTO_CONFIG
if [[ "$AUTO_CONFIG" =~ ^[Yy]$ ]]; then
    print_header "⚡ AUTO CONFIGURATION ⚡"
    echo -e "${B_YELLOW}      🔑 Enter your node details from Panel → Nodes → Configuration:${NC}\n"
    read -p "$(echo -e "${B_CYAN}      UUID:${NC} ")" UUID
    read -p "$(echo -e "${B_CYAN}      Token ID:${NC} ")" TOKEN_ID
    read -p "$(echo -e "${B_CYAN}      Token:${NC} ")" TOKEN
    read -p "$(echo -e "${B_CYAN}      Panel URL[](https://...):${NC} ")" REMOTE

    print_status "Saving configuration"
    sudo tee /etc/pterodactyl/config.yml > /dev/null <<CFG
debug: false
uuid: ${UUID}
token_id: ${TOKEN_ID}
token: ${TOKEN}
api:
  host: 0.0.0.0
  port: 8080
  ssl:
    enabled: true
    cert: /etc/certs/wing/fullchain.pem
    key: /etc/certs/wing/privkey.pem
system:
  data: /var/lib/pterodactyl/volumes
  sftp:
    bind_port: 2022
remote: '${REMOTE}'
CFG
    check_success "Config saved successfully!" "Failed to save config"

    print_status "Launching Wings"
    sudo systemctl start wings
    check_success "Wings is now LIVE! 🦅" "Failed to start Wings"

    echo -e "\n${B_GREEN}      ✅ Auto-configuration completed!${NC}"
    echo -e "${B_YELLOW}      Check status:${NC} ${B_GREEN}systemctl status wings${NC}"
    echo -e "${B_YELLOW}      View logs:${NC} ${B_GREEN}journalctl -u wings -f${NC}\n"
else
    echo -e "\n${B_YELLOW}      ⚠️ Auto-config skipped${NC}"
    echo -e "${B_YELLOW}      Manual steps:${NC}"
    echo -e " ${B_GREEN}      1. Edit /etc/pterodactyl/config.yml with your node info${NC}"
    echo -e " ${B_GREEN}      2. Run: sudo systemctl start wings${NC}\n"
fi

# Final epic footer
echo -e "${B_BLUE}
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║         ${B_WHITE}${BOLD}Thank you for using MahimOp's Wings Script!${B_BLUE}         ║
║                ${B_CYAN}${BOLD}Join the community & get support:${B_BLUE}                ║
║     ${B_PURPLE}${BOLD}https://discord.gg/EHBvzYbh57${B_BLUE}     ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝${NC}"
