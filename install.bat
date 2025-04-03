@echo off
echo =========================================== 
echo    AI Development Stack Installation
echo =========================================== 

:: Check if Docker Desktop is installed
where docker >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Docker Desktop is not installed or not in PATH.
    echo Please install Docker Desktop from: https://www.docker.com/products/docker-desktop/
    echo After installation, please restart this script.
    pause
    exit /b 1
)

:: Check Docker is running
docker info >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Docker Desktop is not running. Please start Docker Desktop and try again.
    pause
    exit /b 1
)

:: Create installation directory
echo Creating installation directory...
set INSTALL_DIR=%CD%\ai-stack
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
cd "%INSTALL_DIR%"

:: Create shared directory for n8n
if not exist "shared" mkdir "shared"
echo Created shared directory for n8n at %INSTALL_DIR%\shared

:: Create n8n backup directory
if not exist "n8n\backup" mkdir "n8n\backup"
echo Created n8n backup directory at %INSTALL_DIR%\n8n\backup

:: Clean up previous installations
echo Cleaning up any previous installations...
docker-compose down >nul 2>&1
docker system prune -af >nul 2>&1
docker volume prune -f >nul 2>&1
docker network prune -f >nul 2>&1

:: Create docker-compose.yml
echo Creating Docker Compose configuration...
(
echo version: '3'
echo.
echo networks:
echo   backend:
echo     driver: bridge
echo.
echo services:
echo   n8n:
echo     image: n8nio/n8n:latest
echo     restart: always
echo     networks:
echo       - backend
echo     ports:
echo       - "${N8N_PORT:-5678}:5678"
echo     environment:
echo       - N8N_SECURE_COOKIE=false
echo       - N8N_HOST=${N8N_HOST:-localhost}
echo       - N8N_PORT=${N8N_PORT:-5678}
echo       - N8N_PROTOCOL=${N8N_PROTOCOL:-http}
echo       - N8N_WEBHOOK_URL=${N8N_WEBHOOK_URL:-https://vertically-concise-stud.ngrok-free.app}
echo       - N8N_WEBHOOK_HOST=${N8N_WEBHOOK_HOST:-vertically-concise-stud.ngrok-free.app}
echo       - DB_TYPE=postgresdb
echo       - DB_POSTGRESDB_HOST=postgres
echo       - DB_POSTGRESDB_PORT=${POSTGRES_PORT:-5432}
echo       - DB_POSTGRESDB_DATABASE=${POSTGRES_DB:-n8n}
echo       - DB_POSTGRESDB_USER=${POSTGRES_USER:-n8n}
echo       - DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD:-n8n_password_123}
echo       - N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY:-your-encryption-key-here}
echo       - N8N_USER_MANAGEMENT_JWT_SECRET=${N8N_USER_MANAGEMENT_JWT_SECRET:-your-jwt-secret-here}
echo       - OLLAMA_HOST=${OLLAMA_HOST:-ollama:11434}
echo     volumes:
echo       - n8n_data:/home/node/.n8n
echo       - ./shared:/data/shared
echo       - ./n8n/backup:/backup
echo     depends_on:
echo       - postgres
echo       - ollama
echo       - qdrant
echo.
echo   postgres:
echo     image: postgres:15-alpine
echo     restart: always
echo     networks:
echo       - backend
echo     environment:
echo       - POSTGRES_USER=${POSTGRES_USER:-n8n}
echo       - POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-n8n_password_123}
echo       - POSTGRES_DB=${POSTGRES_DB:-n8n}
echo     volumes:
echo       - postgres_data:/var/lib/postgresql/data
echo     healthcheck:
echo       test: ["CMD-SHELL", "pg_isready -h localhost -U ${POSTGRES_USER:-n8n} -d ${POSTGRES_DB:-n8n}"]
echo       interval: 5s
echo       timeout: 5s
echo       retries: 10
echo.
echo   # Main Ollama service - CPU version
echo   ollama:
echo     image: ollama/ollama:latest
echo     restart: always
echo     networks:
echo       - backend
echo     ports:
echo       - "11434:11434"
echo     volumes:
echo       - ollama_data:/root/.ollama
echo     environment:
echo       - OLLAMA_HOST=0.0.0.0
echo       - OLLAMA_ORIGINS=*
echo     deploy:
echo       resources:
echo         limits:
echo           cpus: '2'
echo           memory: 4G
echo     # No profile restriction - always enabled
echo.
echo   # NVIDIA GPU-specific Ollama service
echo   ollama-gpu-nvidia:
echo     image: ollama/ollama:latest
echo     restart: always
echo     networks:
echo       - backend
echo     ports:
echo       - "11434:11434"
echo     volumes:
echo       - ollama_data:/root/.ollama
echo     environment:
echo       - OLLAMA_HOST=0.0.0.0
echo       - OLLAMA_ORIGINS=*
echo     deploy:
echo       resources:
echo         reservations:
echo           devices:
echo             - driver: nvidia
echo               count: 1
echo               capabilities: [gpu]
echo     profiles: ["gpu-nvidia"] # Only enabled when gpu-nvidia profile is activated
echo.
echo   openwebui:
echo     image: ghcr.io/open-webui/open-webui:main
echo     restart: always
echo     networks:
echo       - backend
echo     ports:
echo       - "${OPENWEBUI_PORT:-3000}:8080"
echo     environment:
echo       - OLLAMA_API_BASE_URL=http://ollama:11434
echo     volumes:
echo       - openwebui_data:/app/backend/data
echo     depends_on:
echo       - ollama
echo.
echo   qdrant:
echo     image: qdrant/qdrant:latest
echo     restart: always
echo     networks:
echo       - backend
echo     ports:
echo       - "${QDRANT_PORT:-6333}:6333"
echo     volumes:
echo       - qdrant_data:/qdrant/storage
echo     environment:
echo       - QDRANT_ALLOW_RECOVERY=true
echo       - QDRANT_STORAGE_OPTIMIZERS_DEFAULT_SEGMENT_NUMBER=2
echo     deploy:
echo       resources:
echo         limits:
echo           cpus: '1'
echo           memory: 2G
echo.
echo   ngrok:
echo     image: ngrok/ngrok:latest
echo     restart: always
echo     networks:
echo       - backend
echo     ports:
echo       - "4040:4040"
echo     volumes:
echo       - ./ngrok.yml:/etc/ngrok.yml
echo     command: start --all --config /etc/ngrok.yml
echo     depends_on:
echo       - n8n
echo.
echo volumes:
echo   n8n_data:
echo   postgres_data:
echo   ollama_data:
echo   openwebui_data:
echo   qdrant_data:
) > docker-compose.yml

:: Create ngrok configuration
echo Creating ngrok configuration...
(
echo version: 2
echo authtoken: 2vCZz1Ccvx74KuM9sJwPt2vqElE_2VoqKTy1SxHcuyFhW2M3t
echo tunnels:
echo   n8n:
echo     proto: http
echo     addr: n8n:5678
echo     inspect: true
echo   custom-domain-tunnel:
echo     proto: http
echo     addr: n8n:5678
echo     hostname: vertically-concise-stud.ngrok-free.app
echo   openwebui:
echo     proto: http
echo     addr: openwebui:8080
echo     inspect: true
) > ngrok.yml

:: Create .env file
echo Creating .env file...
(
echo # Database Configuration
echo POSTGRES_USER=n8n
echo POSTGRES_PASSWORD=n8n_password_123
echo POSTGRES_DB=n8n
echo POSTGRES_PORT=5432
echo.
echo # n8n Configuration
echo N8N_HOST=localhost
echo N8N_PORT=5678
echo N8N_PROTOCOL=http
echo N8N_USER_MANAGEMENT_DISABLED=false
echo N8N_BASIC_AUTH_ACTIVE=true
echo N8N_BASIC_AUTH_USER=admin
echo N8N_BASIC_AUTH_PASSWORD=admin_password_123
echo.
echo # n8n Security (add your own values in production)
echo N8N_ENCRYPTION_KEY=your-encryption-key-here
echo N8N_USER_MANAGEMENT_JWT_SECRET=your-jwt-secret-here
echo.
echo # n8n Webhook Configuration (for use with ngrok)
echo N8N_WEBHOOK_URL=https://vertically-concise-stud.ngrok-free.app
echo N8N_WEBHOOK_HOST=vertically-concise-stud.ngrok-free.app
echo.
echo # Ollama Configuration
echo OLLAMA_HOST=ollama:11434
echo # For Windows local Ollama, you might use: host.docker.internal:11434
echo.
echo # Open WebUI Configuration
echo OPENWEBUI_PORT=3000
echo.
echo # ngrok Configuration
echo NGROK_AUTHTOKEN=2vCZz1Ccvx74KuM9sJwPt2vqElE_2VoqKTy1SxHcuyFhW2M3t
echo # If you have a static domain (available on free plan) set it here
echo NGROK_DOMAIN=vertically-concise-stud.ngrok-free.app
echo.
echo # Qdrant Configuration
echo QDRANT_HOST=qdrant
echo QDRANT_PORT=6333
) > .env

:: Create .env.example file
echo Creating .env.example file...
(
echo # Database Configuration
echo POSTGRES_USER=your_db_user
echo POSTGRES_PASSWORD=your_db_password
echo POSTGRES_DB=n8n
echo POSTGRES_PORT=5432
echo.
echo # n8n Configuration
echo N8N_HOST=localhost
echo N8N_PORT=5678
echo N8N_PROTOCOL=http
echo N8N_USER_MANAGEMENT_DISABLED=false
echo N8N_BASIC_AUTH_ACTIVE=true
echo N8N_BASIC_AUTH_USER=admin
echo N8N_BASIC_AUTH_PASSWORD=your_admin_password_here
echo.
echo # n8n Security (add your own values in production)
echo N8N_ENCRYPTION_KEY=your-encryption-key-here
echo N8N_USER_MANAGEMENT_JWT_SECRET=your-jwt-secret-here
echo.
echo # n8n Webhook Configuration (for use with ngrok)
echo # After getting your ngrok domain, update these values
echo N8N_WEBHOOK_URL=https://vertically-concise-stud.ngrok-free.app
echo N8N_WEBHOOK_HOST=vertically-concise-stud.ngrok-free.app
echo.
echo # Ollama Configuration
echo OLLAMA_HOST=ollama:11434
echo # For Windows local Ollama, you might need: host.docker.internal:11434
echo # Windows Ollama volume path (uncomment and change username)
echo # OLLAMA_VOLUME=C:/Users/USERNAME/.ollama
echo.
echo # Open WebUI Configuration
echo OPENWEBUI_PORT=3000
echo.
echo # ngrok Configuration (get your token from https://dashboard.ngrok.com/)
echo NGROK_AUTHTOKEN=2vCZz1Ccvx74KuM9sJwPt2vqElE_2VoqKTy1SxHcuyFhW2M3t
echo # If you have a static domain (available on free plan) set it here
echo NGROK_DOMAIN=vertically-concise-stud.ngrok-free.app
echo.
echo # Qdrant Configuration
echo QDRANT_HOST=qdrant
echo QDRANT_PORT=6333
) > .env.example

:: Create ngrok.yml.example file
echo Creating ngrok.yml.example file...
(
echo version: 2
echo authtoken: 2vCZz1Ccvx74KuM9sJwPt2vqElE_2VoqKTy1SxHcuyFhW2M3t
echo tunnels:
echo   n8n:
echo     proto: http
echo     addr: n8n:5678
echo     inspect: true
echo   custom-domain-tunnel:
echo     proto: http
echo     addr: n8n:5678
echo     hostname: vertically-concise-stud.ngrok-free.app
echo   openwebui:
echo     proto: http
echo     addr: openwebui:8080
echo     inspect: true
) > ngrok.yml.example

:: Create .gitignore file
echo Creating .gitignore file...
(
echo # Environment files
echo .env
echo *.env
echo .env.*
echo !.env.example
echo.
echo # n8n backup data
echo shared/
echo n8n/backup/*
echo !n8n/backup/.gitkeep
echo.
echo # Other common files to ignore
echo .DS_Store
echo node_modules/ 
echo.
echo # Key files to ignore
echo **/ssl/
echo ngrok.yml
echo !ngrok.yml.example
) > .gitignore

:: Pull Docker images
echo Pulling Docker images...
docker pull n8nio/n8n:latest
docker pull postgres:15-alpine
docker pull ollama/ollama:latest
docker pull ghcr.io/open-webui/open-webui:main
docker pull qdrant/qdrant:latest
docker pull ngrok/ngrok:latest

:: Start services
echo Starting services...
docker-compose up -d

echo =========================================== 
echo   Installation complete!
echo =========================================== 
echo.
echo Access your services at:
echo - n8n: http://localhost:5678
echo - Open WebUI: http://localhost:3000
echo - Ollama API: http://localhost:11434
echo - Qdrant API: http://localhost:6333
echo - ngrok dashboard: http://localhost:4040
echo.
echo Get your ngrok tunnel URLs from the dashboard: http://localhost:4040
echo.
echo n8n is also available via ngrok at: https://vertically-concise-stud.ngrok-free.app
echo.
echo To use with external services like Telegram, WhatsApp, etc.:
echo 1. In your n8n workflows, use the following URL for webhooks:
echo    https://vertically-concise-stud.ngrok-free.app
echo 2. For Telegram bots, set the webhook URL to:
echo    https://vertically-concise-stud.ngrok-free.app/webhook-test
echo    (replace 'webhook-test' with your actual webhook path)
echo =========================================== 

pause 