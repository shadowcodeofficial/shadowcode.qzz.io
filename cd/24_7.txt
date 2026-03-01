#!/usr/bin/env bash
set -euo pipefail

# ================================
#  Debian 11 XRDP + XFCE Installer
#  Made by MahimOp
# ================================

# -------- Colors --------
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
RESET='\033[0m'

# -------- Helpers --------
log()  { echo -e "${CYAN}[INFO]${RESET} $1"; }
ok()   { echo -e "${GREEN}[OK]${RESET}   $1"; }
warn() { echo -e "${YELLOW}[WARN]${RESET} $1"; }

# -------- Sudo Detection (IDX safe) --------
if command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
else
    warn "sudo not found, running without sudo"
    SUDO=""
fi

# -------- Header --------
clear
cat << "EOF"
========================================================
$$\      $$\  $$$$$$\  $$\   $$\ $$$$$$\ $$\      $$\ 
$$$\    $$$ |$$  __$$\ $$ |  $$ |\_$$  _|$$$\    $$$ |
$$$$\  $$$$ |$$ /  $$ |$$ |  $$ |  $$ |  $$$$\  $$$$ |
$$\$$\$$ $$ |$$$$$$$$ |$$$$$$$$ |  $$ |  $$\$$\$$ $$ |
$$ \$$$  $$ |$$  __$$ |$$  __$$ |  $$ |  $$ \$$$  $$ |
$$ |\$  /$$ |$$ |  $$ |$$ |  $$ |  $$ |  $$ |\$  /$$ |
$$ | \_/ $$ |$$ |  $$ |$$ |  $$ |$$$$$$\ $$ | \_/ $$ |
\__|     \__|\__|  \__|\__|  \__|\______|\__|     \__|

--------------------------------------------------------
   Debian 11 XRDP + XFCE Setup
   Clean • Fast • Stable • Google IDX Ready
   Made with ❤️  by MahimOp
========================================================
EOF
sleep 1

# -------- Step 1 --------
log "[1/8] Updating system packages..."
$SUDO apt update -y && $SUDO apt upgrade -y
ok "System updated"

# -------- Step 2 --------
log "[2/8] Installing XFCE, XRDP, DBus & Firefox..."
$SUDO apt install -y \
    xfce4 \
    xfce4-goodies \
    xrdp \
    dbus-x11 \
    firefox-esr
ok "Desktop environment installed"

# -------- Step 3 --------
log "[3/8] Configuring XRDP session..."
cat > ~/.xsession <<EOF
export \$(dbus-launch)
xfce4-session
EOF
ok ".xsession configured"

# -------- Step 4 --------
log "[4/8] Fixing .xsession permissions..."
$SUDO chown "$(whoami):$(whoami)" ~/.xsession
chmod 644 ~/.xsession
ok "Permissions fixed"

# -------- Step 5 --------
log "[5/8] Adding XRDP user to ssl-cert group..."
$SUDO adduser xrdp ssl-cert || warn "Already added"
ok "XRDP group ready"

# -------- Step 6 --------
log "[6/8] Enabling & restarting XRDP service..."
$SUDO systemctl enable xrdp
$SUDO systemctl restart xrdp
ok "XRDP service running"

# -------- Step 7 --------
log "[7/8] Applying Firefox XRDP fix..."
$SUDO sed -i \
's|^Exec=firefox-esr.*|Exec=firefox-esr --no-sandbox --disable-seccomp|' \
/usr/share/applications/firefox-esr.desktop
ok "Firefox XRDP fix applied"

# -------- Step 8 --------
log "[8/8] Final service check..."
systemctl is-active xrdp >/dev/null 2>&1 \
    && ok "XRDP is active" \
    || warn "XRDP may not be running"

# -------- Done --------
echo
echo "========================================================"
echo -e " 🎉 ${GREEN}Installation Complete!${RESET}"
echo
echo " ✅ XFCE Desktop Ready"
echo " ✅ XRDP Configured"
echo " ✅ Firefox Works Under XRDP"
echo
echo " 💻 Connect using Windows Remote Desktop"
echo " 🏷️  Credit: MahimOp"
echo "========================================================"
