#!/bin/bash
# ===================================================
# PTERODACTYL PANEL INSTALLER - NEXT GEN EDITION
# Ultra Edition (2025)
# ===================================================
# Original Creator: MahimOp
# YouTube : https://www.youtube.com/@mahimxyz
# Discord : https://discord.gg/zkDNdPpArS
# ===================================================
set -e
# Color Palette - Next Gen Theme
RESET="\e[0m"
BOLD="\e[1m"
DIM="\e[2m"
UNDERLINE="\e[4m"
# Primary Colors
CYAN="\e[96m"
BLUE="\e[94m"
PURPLE="\e[95m"
GREEN="\e[92m"
YELLOW="\e[93m"
RED="\e[91m"
WHITE="\e[97m"
# Accents
NEON_GREEN="\e[38;5;82m"
NEON_PURPLE="\e[38;5;165m"
NEON_BLUE="\e[38;5;75m"
GLOW="\e[38;5;51m"
DANGER="\e[38;5;196m"
clear
# Epic Header Animation
echo -e "${DANGER}"
cat << "EOF"
 ___      ___       __       __    __   __     ___      ___ 
|"  \    /"  |     /""\     /" |  | "\ |" \   |"  \    /"  |
 \   \  //   |    /    \   (:  (__)  :)||  |   \   \  //   |
 /\\  \/.    |   /' /\  \   \/      \/ |:  |   /\\  \/.    |
|: \.        |  //  __'  \  //  __  \\ |.  |  |: \.        |
|.  \    /:  | /   /  \\  \(:  (  )  :)/\  |\ |.  \    /:  |
|___|\__/|___|(___/    \___)\__|  |__/(__\_|_)|___|\__/|___|
                                                            
                                                    
EOF
echo -e "${NEON_PURPLE}${BOLD} NEXT GEN ULTRA EDITION - 2025${RESET}"
echo -e "${DIM} Original Creator: ${BOLD}MahimOp${RESET} ${DIM}| YouTube: @mahimxyz${RESET}"
echo -e "${DIM} Discord: https://discord.gg/zkDNdPpArS${RESET}"
echo -e "${NEON_BLUE}══════════════════════════════════════════════════════════${RESET}\n"
# Domain Input with Style
echo -e "${CYAN}${BOLD}▶ Setup Configuration${RESET}"
read -p $'\e[96m\e[1m Enter your domain (e.g., panel.example.com): \e[0m' DOMAIN
if [[ -z "$DOMAIN" ]]; then
    echo -e "${RED}${BOLD}✘ Error: Domain is required!${RESET}"
    exit 1
fi
echo -e "${GREEN}${BOLD}✓ Domain set to: ${WHITE}${DOMAIN}${RESET}\n"
# Auto Generate Secure Credentials
DB_PASS="yourPassword"
DB_NAME="panel"
DB_USER="pterodactyl"
PHP_VERSION="8.3"
# Progress Banner
progress() {
    echo -e "${NEON_GREEN}${BOLD}➤ $1${RESET}"
}
success() {
    echo -e "${GREEN}${BOLD}✓ $1${RESET}"
}
warning() {
    echo -e "${YELLOW}${BOLD}! $1${RESET}"
}
# Start Installation
progress "Updating system & installing core dependencies..."
apt update -qq && apt upgrade -y -qq
apt install -y curl apt-transport-https ca-certificates gnupg lsb-release unzip git tar sudo software-properties-common -qq
OS=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)
progress "Detected OS: ${BOLD}${OS^} ($CODENAME)${RESET}"
# PHP Repository (from first script - reliable)
if [[ "$OS" == "ubuntu" ]]; then
    progress "Adding PPA for PHP (Ondřej)..."
    LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php
elif [[ "$OS" == "debian" ]]; then
    progress "Adding SURY PHP repo manually..."
    curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /usr/share/keyrings/sury-php.gpg
    echo "deb [signed-by=/usr/share/keyrings/sury-php.gpg] https://packages.sury.org/php/ $CODENAME main" > /etc/apt/sources.list.d/sury-php.list
fi
# Redis Repository
progress "Adding official Redis repository..."
curl -fsSL https://packages.redis.io/gpg | gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $CODENAME main" > /etc/apt/sources.list.d/redis.list
apt update -qq
# Install Packages
progress "Installing PHP $PHP_VERSION, Nginx, MariaDB, Redis & tools..."
apt install -y \
    php${PHP_VERSION} php${PHP_VERSION}-{cli,fpm,common,mysql,mbstring,bcmath,xml,zip,curl,gd,tokenizer,ctype,simplexml,dom} \
    mariadb-server nginx redis cron -qq
success "Core packages installed!"
# Secure MariaDB
progress "Securing MariaDB installation..."
sudo mariadb-secure-installation <<EOF
n
y
y
y
y
EOF
success "MariaDB secured!"
# Database Setup (safe with socket auth)
progress "Creating Pterodactyl database & user..."
sudo mariadb << EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER IF NOT EXISTS '${DB_USER}'@'127.0.0.1' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'127.0.0.1';
FLUSH PRIVILEGES;
EOF
success "Database configured securely!"
# Composer
progress "Installing Composer globally..."
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
success "Composer ready!"
# Panel Download & Setup
progress "Downloading latest Pterodactyl Panel..."
mkdir -p /var/www/pterodactyl && cd /var/www/pterodactyl
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
tar -xzvf panel.tar.gz && rm panel.tar.gz
chmod -R 755 storage/* bootstrap/cache
# Environment Setup (correct URL from first script)
progress "Configuring .env file..."
if [ ! -f ".env.example" ]; then
    curl -Lo .env.example https://raw.githubusercontent.com/pterodactyl/panel/develop/.env.example
fi
cp .env.example .env
sed -i \
    -e "s|APP_URL=.*|APP_URL=https://${DOMAIN}|g" \
    -e "s|DB_HOST=.*|DB_HOST=127.0.0.1|g" \
    -e "s|DB_PORT=.*|DB_PORT=3306|g" \
    -e "s|DB_DATABASE=.*|DB_DATABASE=${DB_NAME}|g" \
    -e "s|DB_USERNAME=.*|DB_USERNAME=${DB_USER}|g" \
    -e "s|DB_PASSWORD=.*|DB_PASSWORD=${DB_PASS}|g" \
    -e "s|APP_ENV=.*|APP_ENV=production|g" \
    -e "s|APP_DEBUG=.*|APP_DEBUG=false|g" \
    .env
if ! grep -q "^APP_ENVIRONMENT_ONLY=" .env; then
    echo "APP_ENVIRONMENT_ONLY=false" >> .env
fi
success ".env configured!"
# Composer Dependencies
progress "Installing Panel dependencies (this may take a moment)..."
COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader --quiet
success "Dependencies installed!"
# Migrations & Key
progress "Generating app key & running migrations..."
php artisan key:generate --force
php artisan migrate --seed --force
success "Database migrated!"
# Permissions & Cron
chown -R www-data:www-data /var/www/pterodactyl
systemctl enable --now cron
(crontab -l 2>/dev/null; echo "* * * * * php /var/www/pterodactyl/artisan schedule:run >> /dev/null 2>&1") | crontab -
success "Permissions & cron job set!"
# SSL Certificate (self-signed)
progress "Generating self-signed SSL certificate..."
mkdir -p /etc/ssl/pterodactyl
openssl req -x509 -nodes -days 3650 -newkey rsa:4096 \
    -keyout /etc/ssl/pterodactyl/privkey.pem \
    -out /etc/ssl/pterodactyl/fullchain.pem \
    -subj "/CN=${DOMAIN}" > /dev/null 2>&1
success "SSL ready (self-signed)"
# Nginx Config (fixed fastcgi_pass)
progress "Configuring Nginx with optimized settings..."
cat > /etc/nginx/sites-available/pterodactyl.conf << EOF
server {
    listen 80;
    server_name ${DOMAIN};
    return 301 https://\$server_name\$request_uri;
}
server {
    listen 443 ssl http2;
    server_name ${DOMAIN};
    root /var/www/pterodactyl/public;
    index index.php;
    ssl_certificate /etc/ssl/pterodactyl/fullchain.pem;
    ssl_certificate_key /etc/ssl/pterodactyl/privkey.pem;
    client_max_body_size 100M;
    client_body_timeout 120s;
    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }
    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)\$;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param PHP_VALUE "upload_max_filesize=100M \n post_max_size=100M";
    }
    location ~ /\.ht { deny all; }
}
EOF
ln -sf /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl restart nginx
success "Nginx configured & restarted!"
# Queue Worker
progress "Deploying Pterodactyl queue worker..."
cat > /etc/systemd/system/pteroq.service << 'EOF'
[Unit]
Description=Pterodactyl Queue Worker
After=redis-server.service
[Service]
User=www-data
Group=www-data
Restart=always
RestartSec=5
ExecStart=/usr/bin/php /var/www/pterodactyl/artisan queue:work --sleep=3 --tries=3
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now redis-server pteroq.service
success "Queue worker activated!"

cd /var/www/pterodactyl
php artisan p:user:make 

sed -i '/^APP_ENVIRONMENT_ONLY=/d' .env
echo "APP_ENVIRONMENT_ONLY=false" >> .env

# Final Epic Screen
clear
echo -e "${DANGER}"
cat << "EOF"
 ___      ___       __       __    __   __     ___      ___ 
|"  \    /"  |     /""\     /" |  | "\ |" \   |"  \    /"  |
 \   \  //   |    /    \   (:  (__)  :)||  |   \   \  //   |
 /\\  \/.    |   /' /\  \   \/      \/ |:  |   /\\  \/.    |
|: \.        |  //  __'  \  //  __  \\ |.  |  |: \.        |
|.  \    /:  | /   /  \\  \(:  (  )  :)/\  |\ |.  \    /:  |
|___|\__/|___|(___/    \___)\__|  |__/(__\_|_)|___|\__/|___|
                                                            
                                          
EOF
echo -e "${NEON_PURPLE}${BOLD} ✨ NEXT GEN INSTALLATION COMPLETE ✨${RESET}\n"
echo -e "${GLOW}${BOLD}╔══════════════════════════════════════════════════════════╗${RESET}"
echo -e "${CYAN}${BOLD} Panel URL:${RESET} ${WHITE}${UNDERLINE}https://${DOMAIN}${RESET}"
echo -e "${CYAN}${BOLD} Panel Path:${RESET} ${WHITE}/var/www/pterodactyl${RESET}"
echo -e "${GLOW}${BOLD}╚══════════════════════════════════════════════════════════╝${RESET}\n"
echo -e "${YELLOW}${BOLD}🚀 Next Steps:${RESET}"
echo -e " ${NEON_GREEN}Create your admin account:${RESET}"
echo -e " ${BOLD}cd /var/www/pterodactyl && php artisan p:user:make${RESET}\n"
echo -e "${PURPLE}${BOLD}🔐 Secure Database Credentials (SAVE THESE!)${RESET}"
echo -e " ${BOLD}Database:${RESET} ${WHITE}${DB_NAME}${RESET}"
echo -e " ${BOLD}Username:${RESET} ${WHITE}${DB_USER}${RESET}"
echo -e " ${BOLD}Password:${RESET} ${WHITE}${DB_PASS}${RESET}\n"
warning "For production: Replace self-signed cert with Let's Encrypt (certbot)"
echo -e "${DIM}Tip: sudo apt install certbot python3-certbot-nginx && sudo certbot --nginx -d ${DOMAIN}${RESET}\n"
echo -e "${NEON_GREEN}${BOLD}Original Credits: MahimOp${RESET}"
echo -e "${DIM}YouTube: https://www.youtube.com/@mahimxyz${RESET}"
echo -e "${DIM}Discord: https://discord.gg/zkDNdPpArS${RESET}\n"
echo -e "${GLOW}${BOLD}Your Next-Gen Pterodactyl Panel is ready to soar! 🦅🚀${RESET}"
