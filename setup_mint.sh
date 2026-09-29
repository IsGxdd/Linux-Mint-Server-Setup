#!/bin/bash

# ==============================================================================
# 💻 LINUX MINT MASTER SERVER SETUP SCRIPT 
# Based on Notion Guide & Windows Environment Analysis
# ==============================================================================

set -e # Exit immediately if a command exits with a non-zero status

# Ensure script is run with root privileges for system packages
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run this script with sudo: sudo ./setup_mint.sh"
  exit 1
fi

echo "🚀 Starting Linux Mint XFCE Dev & AI Server Setup..."

# ==============================================================================
# FASE 6: Dependencias Base
# ==============================================================================
echo "📦 Installing base dependencies..."
apt update && apt upgrade -y
apt install -y nodejs npm git python3-pip python3-venv openjdk-17-jdk curl wget unrar vlc yt-dlp apt-transport-https software-properties-common

# Instalar Deno
echo "🦕 Installing Deno..."
curl -fsSL https://deno.land/install.sh | sudo -u $SUDO_USER sh

# ==============================================================================
# FASE 7: Docker & Docker Compose
# ==============================================================================
echo "🐳 Installing Docker & Docker Compose..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    # Añadir usuario al grupo docker
    usermod -aG docker $SUDO_USER
    echo "✅ Docker installed. (Note: You may need to restart your terminal later for permission changes to take effect)"
else
    echo "✅ Docker is already installed."
fi

# ==============================================================================
# FASE 8: n8n Migration Config
# ==============================================================================
echo "⚙️ Setting up n8n Docker environment..."
USER_HOME=$(eval echo ~$SUDO_USER)
N8N_DIR="$USER_HOME/n8n-docker"

mkdir -p "$N8N_DIR/n8n_data"
chown -R 1000:1000 "$N8N_DIR/n8n_data"

cat <<EOF > "$N8N_DIR/docker-compose.yml"
version: '3.8'
services:
  n8n:
    image: docker.n8n.io/n8nio/n8n
    container_name: n8n
    restart: unless-stopped
    ports:
      - "5678:5678"
    environment:
      - N8N_HOST=localhost
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - NODE_ENV=production
    volumes:
      - ./n8n_data:/home/node/.n8n
EOF

chown -R $SUDO_USER:$SUDO_USER "$N8N_DIR"
echo "✅ n8n docker-compose.yml created in $N8N_DIR"

# ==============================================================================
# FASE 9: Entorno IA (Gemini, PySpark) & Antigravity
# ==============================================================================
echo "🧠 Setting up AI Python Environment..."
LAB_DIR="$USER_HOME/laboratorio-ia"
mkdir -p "$LAB_DIR"
sudo -u $SUDO_USER python3 -m venv "$LAB_DIR/entorno-ia"

echo "📦 Installing AI libraries (Google Generative AI, PySpark, Pandas)..."
sudo -u $SUDO_USER bash -c "source $LAB_DIR/entorno-ia/bin/activate && pip install google-generativeai pyspark pandas openpyxl requests"

# Cloning Antigravity (Phase 9 placeholder)
echo "🧬 Cloning Antigravity Repository..."
sudo -u $SUDO_USER bash -c "cd $LAB_DIR && git clone https://github.com/google/antigravity.git || echo 'Antigravity folder might already exist'"
# Note: Replaced "tu-usuario" with "google" assuming the public repo, change if it's a private fork.
sudo -u $SUDO_USER bash -c "cd $LAB_DIR/antigravity && npm install"

# ==============================================================================
# INSTALL ANTIGRAVITY NATIVE APP (DESKTOP UI)
# ==============================================================================
echo "🌌 Downloading and Installing Antigravity Native UI Desktop App..."
DOWNLOAD_DIR="/tmp/antigravity_download"
mkdir -p $DOWNLOAD_DIR
cd $DOWNLOAD_DIR
# Using --content-disposition to save the file with its correct name (e.g., .deb or .AppImage)
wget --content-disposition "http://antigravity.google/download?os=linux"

# Detect if it's a .deb or AppImage and install accordingly
AG_FILE=$(ls | head -n 1)
if [[ $AG_FILE == *.deb ]]; then
    echo "Installing Antigravity DEB package..."
    dpkg -i "$AG_FILE" || apt-get install -f -y
elif [[ $AG_FILE == *.AppImage ]]; then
    echo "Setting up Antigravity AppImage..."
    chmod +x "$AG_FILE"
    mv "$AG_FILE" /opt/Antigravity.AppImage
    # Creating a desktop shortcut
    cat <<EOF > /usr/share/applications/antigravity.desktop
[Desktop Entry]
Name=Antigravity
Exec=/opt/Antigravity.AppImage
Icon=utilities-terminal
Type=Application
Categories=Development;
EOF
else
    echo "⚠️ Downloaded Antigravity format ($AG_FILE) is not standard. You may need to run it manually."
    mv "$AG_FILE" "$USER_HOME/Desktop/"
fi
cd -

# ==============================================================================
# FASE 10: Visual Studio Code & User Extensions
# ==============================================================================
echo "💻 Installing Visual Studio Code..."
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | tee /etc/apt/sources.list.d/vscode.list > /dev/null
rm -f packages.microsoft.gpg
apt update && apt install code -y

echo "🧩 Installing your VS Code Extensions..."
EXTENSIONS=(
  "be5invis.vscode-icontheme-nomo-dark"
  "christian-kohler.npm-intellisense"
  "eamodio.gitlens"
  "github.github-vscode-theme"
  "google.google-antigravity"
  "miguelsolorio.fluent-icons"
  "ms-python.debugpy"
  "ms-python.python"
  "ms-python.vscode-pylance"
  "ms-python.vscode-python-envs"
  "oderwat.indent-rainbow"
  "openai.chatgpt"
  "openai.codex-audio"
  "ritwickdey.liveserver"
  "wayou.vscode-icons-mac"
)
for ext in "${EXTENSIONS[@]}"; do
  sudo -u $SUDO_USER code --install-extension "$ext" --force || echo "Skipped $ext"
done

# ==============================================================================
# EXTRAS: Brave Browser
# ==============================================================================
echo "🦁 Installing Brave Browser..."
curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list
apt update && apt install brave-browser -y

# ==============================================================================
# FASE 11: Ollama (Local AI)
# ==============================================================================
echo "🦙 Installing Ollama for Local AI..."
curl -fsSL https://ollama.com/install.sh | sh
systemctl enable --now ollama

# ==============================================================================
# FASE 12: Cloudflared
# ==============================================================================
echo "☁️ Installing Cloudflare Tunnel..."
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
dpkg -i cloudflared-linux-amd64.deb || apt-get install -f -y
rm cloudflared-linux-amd64.deb

# ==============================================================================
# FASE 13: OpenSSH & Firewall
# ==============================================================================
echo "🛡️ Configuring SSH and UFW Firewall..."
apt install -y openssh-server
systemctl enable --now ssh
ufw allow ssh
ufw allow 11434/tcp comment "Ollama API local"
# Habilitar ufw forzando 'yes' para evitar bloqueo en scripts automáticos
echo "y" | ufw enable

# ==============================================================================
# WRAP UP
# ==============================================================================
echo "----------------------------------------------------------------"
echo "🎉 Setup Completed Successfully!"
echo "----------------------------------------------------------------"
echo "Next steps for you to do manually:"
echo "0. 🔄 LOG OUT and LOG IN again (or reboot) for Docker permissions to take effect!"
echo "1. Connect your USB and run: cp -r /media/$SUDO_USER/YOUR_USB/n8n_backup/* ~/n8n-docker/n8n_data/"
echo "2. Start n8n: cd ~/n8n-docker && docker compose up -d"
echo "3. Open Antigravity Desktop App (Look in your Mint application menu) and Sign In to link your API/Account."
echo "4. Run 'cloudflared tunnel --url http://localhost:5678' to expose n8n to the web."
echo "----------------------------------------------------------------"
