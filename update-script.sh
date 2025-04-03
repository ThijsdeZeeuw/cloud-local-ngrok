#!/bin/bash
set -e

# Clean up previous installation
echo "Cleaning up previous installation..."

cd /root

# Stop any running containers
docker-compose down 2>/dev/null || true

# Clean up Docker completely
echo "Cleaning up Docker..."
docker system prune -af || true
docker volume prune -f || true
docker network prune -f || true

# Remove old installation folder
echo "Removing old installation files..."
rm -rf /root/cloud-local-ngrok
mkdir -p /root/cloud-local-ngrok
cd /root/cloud-local-ngrok

# Create docker-compose.yml
cat > docker-compose.yml << 'EOL'
version: '3'

networks:
  demo:
    driver: bridge

volumes:
  n8n_data:
  postgres_data:
  ollama_data:
  qdrant_data:

services:
  n8n:
    image: n8nio/n8n:latest
    hostname: n8n
    restart: always
    networks:
      - demo
    ports:
      - "${N8N_PORT}:5678"
    environment:
      - N8N_HOST=${N8N_HOST}
      - N8N_PORT=${N8N_PORT}
      - N8N_PROTOCOL=${N8N_PROTOCOL}
      - N8N_USER_MANAGEMENT_DISABLED=${N8N_USER_MANAGEMENT_DISABLED}
      - N8N_BASIC_AUTH_ACTIVE=${N8N_BASIC_AUTH_ACTIVE}
      - N8N_BASIC_AUTH_USER=${N8N_BASIC_AUTH_USER}
      - N8N_BASIC_AUTH_PASSWORD=${N8N_BASIC_AUTH_PASSWORD}
      - N8N_SECURE_COOKIE=false
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=${POSTGRES_PORT}
      - DB_POSTGRESDB_DATABASE=${POSTGRES_DB}
      - DB_POSTGRESDB_USER=${POSTGRES_USER}
      - DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD}
      - OLLAMA_HOST=ollama:11434
    volumes:
      - n8n_data:/home/node/.n8n
    depends_on:
      - postgres
      - ollama
      - qdrant

  postgres:
    image: postgres:15-alpine
    hostname: postgres
    restart: always
    networks:
      - demo
    environment:
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=${POSTGRES_DB}
    volumes:
      - postgres_data:/var/lib/postgresql/data

  ollama:
    image: ollama/ollama:latest
    hostname: ollama
    restart: always
    networks:
      - demo
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama
    environment:
      - OLLAMA_HOST=0.0.0.0
      - OLLAMA_ORIGINS=*

  qdrant:
    image: qdrant/qdrant:latest
    hostname: qdrant
    restart: always
    networks:
      - demo
    ports:
      - "${QDRANT_PORT}:6333"
    volumes:
      - qdrant_data:/qdrant/storage
    environment:
      - QDRANT_ALLOW_RECOVERY=true
      - QDRANT_STORAGE_OPTIMIZERS_DEFAULT_SEGMENT_NUMBER=2

  ngrok:
    image: ngrok/ngrok:latest
    hostname: ngrok
    restart: always
    networks:
      - demo
    ports:
      - "4040:4040"
    volumes:
      - ./ngrok.yml:/etc/ngrok.yml
    command: start --all --config /etc/ngrok.yml
    depends_on:
      - n8n
EOL

# Create ngrok.yml
cat > ngrok.yml << 'EOL'
version: 2
authtoken: 2rwgXCuTgFVfYLLlp5YwXPVegPH_5kJj3w16iAmEb52aSLnKd
tunnels:
  custom-domain-tunnel:
    proto: http
    addr: n8n:5678
    hostname: dogfish-neutral-sawfish.ngrok-free.app
EOL

# Create .env
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

# ngrok Configuration
NGROK_AUTHTOKEN=2rwgXCuTgFVfYLLlp5YwXPVegPH_5kJj3w16iAmEb52aSLnKd
NGROK_DOMAIN=dogfish-neutral-sawfish.ngrok-free.app

# Qdrant Configuration
QDRANT_HOST=qdrant
QDRANT_PORT=6333
EOL

# Ensure Docker is installed
if ! command -v docker &> /dev/null; then
  echo "Installing Docker..."
  apt update && apt upgrade -y
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  rm get-docker.sh
fi

# Ensure Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
  echo "Installing Docker Compose..."
  apt install docker-compose -y
fi

# Pull images first to ensure they are available
echo "Pulling Docker images..."
docker pull n8nio/n8n:latest
docker pull postgres:15-alpine
docker pull ollama/ollama:latest
docker pull qdrant/qdrant:latest
docker pull ngrok/ngrok:latest

# Start the services
echo "Starting services..."
docker-compose up -d

echo "Installation complete!"
echo "You can access the services at:"
echo "- n8n: http://46.202.155.155:5678"
echo "- ngrok URL: https://dogfish-neutral-sawfish.ngrok-free.app"
echo "- ngrok Dashboard: http://46.202.155.155:4040"
echo "- Ollama API: http://46.202.155.155:11434"
echo "- Qdrant API: http://46.202.155.155:6333" 