# 💻 Linux Mint Master Server Setup

![Linux Mint](https://img.shields.io/badge/Linux%20Mint-87C540?style=for-the-badge&logo=linux-mint&logoColor=white)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)

An automated setup script to transform a fresh Linux Mint (XFCE recommended) installation into a fully featured Development and AI Server. This script handles the installation and configuration of essential development tools, AI environments, Docker, and automation workflows.

## ✨ Features

- **Base Utilities:** git, 
odejs, 
pm, deno, java 17, curl, wget, python3, yt-dlp, and more.
- **Containerization:** Automates Docker and Docker Compose installation.
- **Workflow Automation:** Sets up an **n8n** instance via Docker with isolated volumes.
- **AI Environment:** 
  - Python virtual environment with google-generativeai, pyspark, and pandas.
  - Local AI integration with **Ollama** installed and configured as a service.
  - Setup for the Antigravity repository and Native UI desktop app.
- **IDE Setup:** Installs Visual Studio Code along with a curated list of development and AI-focused extensions.
- **Networking & Security:** 
  - Installs **Brave Browser**.
  - Sets up **Cloudflare Tunnel** (cloudflared) for secure web exposure.
  - Configures **OpenSSH** and secures the system using **UFW** (Uncomplicated Firewall).

## 📋 Prerequisites

- A fresh or existing **Linux Mint** installation (XFCE edition is optimal for performance).
- **Sudo** privileges for the user running the script.
- An active internet connection.

## 🚀 Usage

1. **Clone the repository** (or download the script):
   `ash
   git clone https://github.com/yourusername/linux-mint-server-setup.git
   cd linux-mint-server-setup
   `

2. **Make the script executable**:
   `ash
   chmod +x setup_mint.sh
   `

3. **Run the script as root**:
   `ash
   sudo ./setup_mint.sh
   `

> [!WARNING]
> Do not run the script using sh setup_mint.sh as it relies on bash-specific features. Always use ./setup_mint.sh or ash setup_mint.sh.

## 🛠️ Post-Installation Steps

Once the script completes successfully, follow these manual steps to finalize your setup:

1. **Reboot or Log Out:**
   To ensure your user group changes (like being added to the docker group) take effect, log out and log back in, or restart your terminal before proceeding.

2. **Restore n8n Data (Optional):**
   If you have a backup on a USB drive, copy it to the newly created n8n directory:
   `ash
   cp -r /media/$USER/YOUR_USB/n8n_backup/* ~/n8n-docker/n8n_data/
   `

3. **Start n8n Workflow Automation:**
   `ash
   cd ~/n8n-docker
   docker compose up -d
   `

4. **Link Antigravity:**
   Open the Antigravity Desktop App from your Mint application menu and sign in to link your API/Account.

5. **Expose n8n to the Web (Optional):**
   Use Cloudflare Tunnel to expose your local n8n instance securely:
   `ash
   cloudflared tunnel --url http://localhost:5678
   `

## 📂 Project Structure

- setup_mint.sh: The core bash script that performs the automated installation and configuration.

## 🤝 Contributing

Feel free to fork this repository and submit pull requests if you want to add more tools, optimize the installation steps, or fix potential bugs!

## 📝 License

This project is open-source and available under the [MIT License](LICENSE).
