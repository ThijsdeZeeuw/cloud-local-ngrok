#!/bin/bash
set -e

# Update system
echo "Updating system packages..."
apt update && apt upgrade -y

# Install Docker and Docker Compose
echo "Installing Docker and Docker Compose..."
if ! command -v docker &> /dev/null; then
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  rm get-docker.sh
fi

if ! command -v docker-compose &> /dev/null; then
  apt install docker-compose -y
fi

# Create required directories
mkdir -p cloud-local-ngrok
cd cloud-local-ngrok

# Check if files exist and set them up
if [ -f docker-compose.yml ] && [ -f ngrok.yml ] && [ -f .env ]; then
  echo "Configuration files already exist. Using existing configuration."
else
  echo "Setting up configuration files..."
  # If this was transferred as part of a package, these files should exist
  if [ ! -f docker-compose.yml ]; then
    echo "ERROR: docker-compose.yml not found"
    exit 1
  fi
  if [ ! -f ngrok.yml ]; then
    echo "ERROR: ngrok.yml not found"
    exit 1
  fi
  if [ ! -f .env ]; then
    echo "ERROR: .env not found"
    exit 1
  fi
fi

# Start services
echo "Starting services with Docker Compose..."
docker-compose up -d

echo "Installation complete!"
echo "You can access the services at:"
echo "- n8n: http://localhost:5678 (or via ngrok URL)"
echo "- ngrok Dashboard: http://localhost:4040"
echo "- Ollama API: http://localhost:11434"
echo "- Qdrant API: http://localhost:6333"
echo
echo "To view logs: docker-compose logs -f"
echo "To stop services: docker-compose down" 