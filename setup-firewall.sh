#!/bin/bash
set -e

echo "===========================================" 
echo "  UFW Firewall Setup for AI Development Stack"
echo "===========================================" 

# Check if we're running on Linux
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
  echo "This script is for Linux systems only. Windows does not use UFW."
  exit 1
fi

# Check if running as root
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root" 1>&2
  echo "Please run: sudo $0"
  exit 1
fi

# Install UFW if not present
if ! command -v ufw &> /dev/null; then
  echo "Installing UFW..."
  apt-get update -y || (echo "Package lock detected. Waiting 60 seconds..." && sleep 60 && apt-get update -y)
  apt-get install -y ufw
fi

echo "Configuring UFW firewall rules..."

# Reset UFW to default state (optional)
echo "Resetting UFW to default state..."
ufw --force reset

# Set default policies
ufw default deny incoming
ufw default allow outgoing

# Allow essential services
echo "Allowing essential services..."
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp

# AI Stack specific ports
echo "Opening ports for AI Development Stack..."
ufw allow 3000/tcp  # Open WebUI
ufw allow 5678/tcp  # n8n workflow
ufw allow 11434/tcp # Ollama API
ufw allow 6333/tcp  # Qdrant
ufw allow 4040/tcp  # ngrok dashboard

# Optional services - commented out by default
echo "# Optional services are commented out by default. Uncomment as needed:"
echo "# ufw allow 8080/tcp  # SearXNG"
echo "# ufw allow 8501/tcp  # Archon Streamlit UI"
echo "# ufw allow 5001/tcp  # DocLing Serve"

# Enable UFW if not already enabled
if ! ufw status | grep -q "Status: active"; then
  echo "Enabling UFW..."
  echo "y" | ufw enable
else
  echo "UFW is already enabled."
fi

# Reload UFW to apply changes
ufw reload

echo "UFW firewall configuration complete!"
echo "Current UFW status:"
ufw status verbose

echo ""
echo "To manually open additional ports, use:"
echo "  sudo ufw allow <port>/tcp"
echo ""
echo "To manually close ports, use:"
echo "  sudo ufw deny <port>/tcp"
echo ""
echo "To apply changes after manual modifications:"
echo "  sudo ufw reload"
echo "===========================================" 