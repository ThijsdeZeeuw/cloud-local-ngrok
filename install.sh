#!/bin/bash
set -e

echo "===========================================" 
echo "  AI Development Stack Installation"
echo "===========================================" 

# Check if running on Windows
if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
  echo "Windows detected. Ensuring Docker Desktop is installed..."
  if ! command -v docker &> /dev/null; then
    echo "Please install Docker Desktop for Windows from: https://www.docker.com/products/docker-desktop/"
    echo "After installation, please restart this script."
    exit 1
  fi
else
  # For Linux/macOS systems, we still need to be root
  if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root on Linux/macOS systems" 1>&2
    exit 1
  fi

  # Install Docker if not available (Linux only)
  if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    apt-get update -y || (echo "Package lock detected. Waiting 60 seconds..." && sleep 60 && apt-get update -y)
    apt-get install -y curl
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
  fi

  # Install Docker Compose if not available (Linux only)
  if ! command -v docker-compose &> /dev/null; then
    echo "Installing Docker Compose..."
    apt-get install -y docker-compose
  fi
fi

# Create installation directory
echo "Creating installation directory..."
INSTALL_DIR="$(pwd)/ai-stack"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Create shared directory for n8n
mkdir -p shared
echo "Created shared directory for n8n at $(pwd)/shared"

# Create n8n backup directory
mkdir -p n8n/backup
echo "Created n8n backup directory at $(pwd)/n8n/backup"

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
      - "${N8N_PORT:-5678}:5678"
    environment:
      - N8N_SECURE_COOKIE=false
      - N8N_HOST=${N8N_HOST:-localhost}
      - N8N_PORT=${N8N_PORT:-5678}
      - N8N_PROTOCOL=${N8N_PROTOCOL:-http}
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_HOST=postgres
      - DB_POSTGRESDB_PORT=${POSTGRES_PORT:-5432}
      - DB_POSTGRESDB_DATABASE=${POSTGRES_DB:-n8n}
      - DB_POSTGRESDB_USER=${POSTGRES_USER:-n8n}
      - DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD:-n8n_password_123}
      - N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY:-your-encryption-key-here}
      - N8N_USER_MANAGEMENT_JWT_SECRET=${N8N_USER_MANAGEMENT_JWT_SECRET:-your-jwt-secret-here}
      - OLLAMA_HOST=${OLLAMA_HOST:-ollama:11434}
    volumes:
      - n8n_data:/home/node/.n8n
      - ./shared:/data/shared
      - ./n8n/backup:/backup
    depends_on:
      - postgres
      - ollama
      - qdrant

  postgres:
    image: postgres:15-alpine
    restart: always
    networks:
      - backend
    environment:
      - POSTGRES_USER=${POSTGRES_USER:-n8n}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-n8n_password_123}
      - POSTGRES_DB=${POSTGRES_DB:-n8n}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -h localhost -U ${POSTGRES_USER:-n8n} -d ${POSTGRES_DB:-n8n}"]
      interval: 5s
      timeout: 5s
      retries: 10

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
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
    profiles: ["default", "cpu"]

  ollama-gpu-nvidia:
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
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    profiles: ["gpu-nvidia"]

  ollama-gpu-amd:
    image: ollama/ollama:rocm
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
    devices:
      - "/dev/kfd"
      - "/dev/dri"
    profiles: ["gpu-amd"]

  openwebui:
    image: ghcr.io/open-webui/open-webui:main
    restart: always
    networks:
      - backend
    ports:
      - "${OPENWEBUI_PORT:-3000}:8080"
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
      - "${QDRANT_PORT:-6333}:6333"
    volumes:
      - qdrant_data:/qdrant/storage
    environment:
      - QDRANT_ALLOW_RECOVERY=true
      - QDRANT_STORAGE_OPTIMIZERS_DEFAULT_SEGMENT_NUMBER=2
    deploy:
      resources:
        limits:
          cpus: '1'
          memory: 2G

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
    depends_on:
      - n8n

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
authtoken: ${NGROK_AUTHTOKEN:-2rwgXCuTgFVfYLLlp5YwXPVegPH_5kJj3w16iAmEb52aSLnKd}
tunnels:
  n8n:
    proto: http
    addr: n8n:5678
    inspect: true
  # If you have a custom domain, uncomment and modify this section
  # custom-domain-tunnel:
  #   proto: http
  #   addr: n8n:5678
  #   hostname: ${NGROK_DOMAIN}
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

# n8n Security (add your own values in production)
N8N_ENCRYPTION_KEY=your-encryption-key-here
N8N_USER_MANAGEMENT_JWT_SECRET=your-jwt-secret-here

# Ollama Configuration
OLLAMA_HOST=ollama:11434

# Open WebUI Configuration
OPENWEBUI_PORT=3000

# ngrok Configuration
NGROK_AUTHTOKEN=2rwgXCuTgFVfYLLlp5YwXPVegPH_5kJj3w16iAmEb52aSLnKd
# If you have a static domain (available on free plan) set it here
# NGROK_DOMAIN=your-static-domain.ngrok-free.app

# Qdrant Configuration
QDRANT_HOST=qdrant
QDRANT_PORT=6333
EOL

echo "Creating .env.example file..."
cat > .env.example << 'EOL'
# Database Configuration
POSTGRES_USER=your_db_user
POSTGRES_PASSWORD=your_db_password
POSTGRES_DB=n8n
POSTGRES_PORT=5432

# n8n Configuration
N8N_HOST=localhost
N8N_PORT=5678
N8N_PROTOCOL=http
N8N_USER_MANAGEMENT_DISABLED=false
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=your_admin_password_here

# n8n Security (add your own values in production)
N8N_ENCRYPTION_KEY=your-encryption-key-here
N8N_USER_MANAGEMENT_JWT_SECRET=your-jwt-secret-here

# n8n Webhook Configuration (for use with ngrok)
# After getting your ngrok domain, update these values
N8N_WEBHOOK_URL=https://your-ngrok-domain.ngrok-free.app
N8N_WEBHOOK_HOST=your-ngrok-domain.ngrok-free.app

# Ollama Configuration
OLLAMA_HOST=ollama:11434
# For Windows local Ollama, you might need: host.docker.internal:11434
# Windows Ollama volume path (uncomment and change username)
# OLLAMA_VOLUME=C:/Users/USERNAME/.ollama

# Open WebUI Configuration
OPENWEBUI_PORT=3000

# ngrok Configuration (get your token from https://dashboard.ngrok.com/)
NGROK_AUTHTOKEN=your_ngrok_authtoken_here
# If you have a static domain (available on free plan) set it here
# NGROK_DOMAIN=your-static-domain.ngrok-free.app

# Qdrant Configuration
QDRANT_HOST=qdrant
QDRANT_PORT=6333
EOL

echo "Creating ngrok.yml.example file..."
cat > ngrok.yml.example << 'EOL'
version: 2
authtoken: your-ngrok-authtoken # Get this from https://dashboard.ngrok.com/get-started/your-authtoken
tunnels:
  n8n:
    proto: http
    addr: n8n:5678
    inspect: true
  # If you have a custom domain, uncomment and modify this section
  # custom-domain-tunnel:
  #   proto: http
  #   addr: n8n:5678
  #   hostname: your-ngrok-domain.ngrok-free.app
  openwebui:
    proto: http
    addr: openwebui:8080
    inspect: true
EOL

echo "Creating .gitignore file..."
cat > .gitignore << 'EOL'
# Environment files
.env
*.env
.env.*
!.env.example

# n8n backup data
shared/
n8n/backup/*
!n8n/backup/.gitkeep

# Other common files to ignore
.DS_Store
node_modules/ 

# Key files to ignore
**/ssl/
ngrok.yml
!ngrok.yml.example
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

# Try to get server's IP - works differently on Windows vs Linux
echo "===========================================" 
echo "  Installation complete!"
echo "===========================================" 
echo ""
echo "Access your services at:"

if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
  echo "- n8n: http://localhost:5678"
  echo "- Open WebUI: http://localhost:3000"
  echo "- Ollama API: http://localhost:11434"
  echo "- Qdrant API: http://localhost:6333"
  echo "- ngrok dashboard: http://localhost:4040"
else
  # Try to get server's public IP for Linux
  SERVER_IP=$(curl -s ifconfig.me 2>/dev/null || echo "localhost")
  echo "- n8n: http://${SERVER_IP}:5678"
  echo "- Open WebUI: http://${SERVER_IP}:3000"
  echo "- Ollama API: http://${SERVER_IP}:11434"
  echo "- Qdrant API: http://${SERVER_IP}:6333"
  echo "- ngrok dashboard: http://${SERVER_IP}:4040"
fi

echo ""
echo "Get your ngrok tunnel URLs from the dashboard: http://localhost:4040"
echo ""
echo "To use with external services like Telegram, WhatsApp, etc.:"
echo "1. Get a free ngrok account at https://ngrok.com/"
echo "2. Get your authtoken from https://dashboard.ngrok.com/get-started/your-authtoken"
echo "3. Update your .env and ngrok.yml files with your token"
echo "4. Restart the services with: docker-compose restart ngrok"
echo "===========================================" 