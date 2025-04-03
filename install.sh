#!/bin/bash
set -e

echo "===========================================" 
echo "  AI Development Stack Installation"
echo "===========================================" 

# Make sure we're root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

echo "Ensuring Docker is installed..."
if ! command -v docker &> /dev/null; then
  apt update && apt upgrade -y
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  rm get-docker.sh
fi

echo "Ensuring Docker Compose is installed..."
if ! command -v docker-compose &> /dev/null; then
  apt install docker-compose -y
fi

echo "Creating installation directory..."
mkdir -p /root/ai-stack
cd /root/ai-stack

echo "Cleaning up any previous installations..."
docker-compose down 2>/dev/null || true
docker system prune -af || true
docker volume prune -f || true
docker network prune -f || true

echo "Creating Docker Compose configuration..."
cat > docker-compose.yml << 'EOL'
version: '3'

networks:
  backend:
    driver: bridge

services:
  n8n:
    image: n8nio/n8n:latest
    restart: always
    networks:
      - backend
    ports:
      - "5678:5678"
    environment:
      - N8N_SECURE_COOKIE=false
      - N8N_HOST=localhost
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_DATABASE=n8n
      - DB_POSTGRESDB_USER=n8n
      - DB_POSTGRESDB_PASSWORD=n8n_password_123
    volumes:
      - n8n_data:/home/node/.n8n
    depends_on:
      - postgres

  postgres:
    image: postgres:15-alpine
    restart: always
    networks:
      - backend
    environment:
      - POSTGRES_USER=n8n
      - POSTGRES_PASSWORD=n8n_password_123
      - POSTGRES_DB=n8n
    volumes:
      - postgres_data:/var/lib/postgresql/data

  ollama:
    image: ollama/ollama:latest
    restart: always
    networks:
      - backend
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama
    environment:
      - OLLAMA_HOST=0.0.0.0
      - OLLAMA_ORIGINS=*

  openwebui:
    image: ghcr.io/open-webui/open-webui:main
    restart: always
    networks:
      - backend
    ports:
      - "3000:8080"
    environment:
      - OLLAMA_API_BASE_URL=http://ollama:11434
    volumes:
      - openwebui_data:/app/backend/data
    depends_on:
      - ollama

  qdrant:
    image: qdrant/qdrant:latest
    restart: always
    networks:
      - backend
    ports:
      - "6333:6333"
    volumes:
      - qdrant_data:/qdrant/storage
    environment:
      - QDRANT_ALLOW_RECOVERY=true

  ngrok:
    image: ngrok/ngrok:latest
    restart: always
    networks:
      - backend
    ports:
      - "4040:4040"
    volumes:
      - ./ngrok.yml:/etc/ngrok.yml
    command: start --all --config /etc/ngrok.yml

volumes:
  n8n_data:
  postgres_data:
  ollama_data:
  openwebui_data:
  qdrant_data:
EOL

echo "Creating ngrok configuration..."
cat > ngrok.yml << 'EOL'
version: 2
authtoken: 2rwgXCuTgFVfYLLlp5YwXPVegPH_5kJj3w16iAmEb52aSLnKd
tunnels:
  n8n:
    proto: http
    addr: n8n:5678
    inspect: true
  openwebui:
    proto: http
    addr: openwebui:8080
    inspect: true
EOL

echo "Creating .env file..."
cat > .env << 'EOL'
# Database Configuration
POSTGRES_USER=n8n
POSTGRES_PASSWORD=n8n_password_123
POSTGRES_DB=n8n
POSTGRES_PORT=5432

# n8n Configuration
N8N_HOST=localhost
N8N_PORT=5678
N8N_PROTOCOL=http
N8N_USER_MANAGEMENT_DISABLED=false
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=admin_password_123

# Ollama Configuration
OLLAMA_HOST=ollama:11434

# Open WebUI Configuration
OPENWEBUI_PORT=3000

# ngrok Configuration
NGROK_AUTHTOKEN=2rwgXCuTgFVfYLLlp5YwXPVegPH_5kJj3w16iAmEb52aSLnKd

# Qdrant Configuration
QDRANT_HOST=qdrant
QDRANT_PORT=6333
EOL

echo "Pulling Docker images..."
docker pull n8nio/n8n:latest
docker pull postgres:15-alpine
docker pull ollama/ollama:latest
docker pull ghcr.io/open-webui/open-webui:main
docker pull qdrant/qdrant:latest
docker pull ngrok/ngrok:latest

echo "Starting services..."
docker-compose up -d

# Get server's public IP
SERVER_IP=$(curl -s ifconfig.me)

echo "===========================================" 
echo "  Installation complete!"
echo "===========================================" 
echo ""
echo "Access your services at:"
echo "- n8n: http://${SERVER_IP}:5678"
echo "- Open WebUI: http://${SERVER_IP}:3000"
echo "- Ollama API: http://${SERVER_IP}:11434"
echo "- Qdrant API: http://${SERVER_IP}:6333"
echo "- ngrok dashboard: http://${SERVER_IP}:4040"
echo ""
echo "Get your ngrok tunnel URLs from the dashboard."
echo "===========================================" 