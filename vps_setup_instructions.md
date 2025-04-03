# VPS Setup Instructions

Follow these steps to install the AI Starter Kit on your VPS (46.202.155.155):

## Method 1: Direct Transfer

1. Connect to your VPS:
   ```bash
   ssh root@46.202.155.155
   ```

2. Create a directory for the installation:
   ```bash
   mkdir -p /root/cloud-local-ngrok
   cd /root/cloud-local-ngrok
   ```

3. Create the necessary configuration files on the VPS:

   **docker-compose.yml**:
   ```bash
   cat > docker-compose.yml << 'EOL'
version: '3.8'

services:
  n8n:
    image: n8nio/n8n:latest
    restart: always
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
    volumes:
      - n8n_data:/home/node/.n8n
    depends_on:
      - postgres
      - ollama
      - qdrant

  postgres:
    image: postgres:15-alpine
    restart: always
    environment:
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=${POSTGRES_DB}
    volumes:
      - postgres_data:/var/lib/postgresql/data

  ollama:
    image: ollama/ollama:latest
    restart: always
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama
    # CPU-specific optimizations
    environment:
      - OLLAMA_HOST=0.0.0.0
      - OLLAMA_ORIGINS=*
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G

  qdrant:
    image: qdrant/qdrant:latest
    restart: always
    ports:
      - "${QDRANT_PORT}:6333"
    volumes:
      - qdrant_data:/qdrant/storage
    # CPU-specific optimizations
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
    ports:
      - "4040:4040"
    volumes:
      - ./ngrok.yml:/etc/ngrok.yml
    environment:
      - NGROK_AUTHTOKEN=${NGROK_AUTHTOKEN}
    depends_on:
      - n8n

volumes:
  n8n_data:
  postgres_data:
  ollama_data:
  qdrant_data:
EOL
   ```

   **ngrok.yml**:
   ```bash
   cat > ngrok.yml << 'EOL'
version: 2
authtoken: ${NGROK_AUTHTOKEN}

tunnels:
  n8n:
    proto: http
    addr: ${N8N_PORT}
    host_header: ${N8N_HOST}
    inspect: true
    hostname: ${NGROK_DOMAIN}
EOL
   ```

   **.env**:
   ```bash
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
   ```

4. Edit the .env file to set your secure passwords and ngrok configuration:
   ```bash
   nano .env
   ```
   
   Important: The .env file has been pre-configured with:
   - Secure passwords for PostgreSQL and n8n
   - Your ngrok auth token
   - Your assigned ngrok domain

5. Install Docker and Docker Compose:
   ```bash
   apt update && apt upgrade -y
   curl -fsSL https://get.docker.com -o get-docker.sh
   sh get-docker.sh
   apt install docker-compose -y
   ```

6. Start the services:
   ```bash
   docker-compose up -d
   ```

7. Check that all services are running:
   ```bash
   docker-compose ps
   ```

8. View logs:
   ```bash
   docker-compose logs -f
   ```

## Method 2: SCP Transfer

Alternatively, you can transfer the files from your local machine:

1. Transfer the files to your VPS:
   ```bash
   cd cloud-local-ngrok
   scp docker-compose.yml ngrok.yml .env install.sh root@46.202.155.155:/root/cloud-local-ngrok/
   ```

2. SSH into your VPS:
   ```bash
   ssh root@46.202.155.155
   ```

3. Navigate to the directory and run the install script:
   ```bash
   cd /root/cloud-local-ngrok
   chmod +x install.sh
   ./install.sh
   ```

## Accessing Your Services

Once installation is complete, you can access:

- n8n: http://46.202.155.155:5678 (or via your ngrok URL)
- ngrok Dashboard: http://46.202.155.155:4040
- Ollama API: http://46.202.155.155:11434
- Qdrant API: http://46.202.155.155:6333

## Troubleshooting

If ngrok service fails with "ERROR: Your configuration file must define at least one tunnel when using --all":
- Ensure the hostname line is uncommented in ngrok.yml
- Make sure NGROK_AUTHTOKEN and NGROK_DOMAIN are properly set in .env 