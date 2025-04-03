# AI Development Stack with ngrok

A comprehensive, production-ready AI development environment that combines:
- **n8n** - Powerful workflow automation platform
- **Ollama** - Run LLMs locally or on your server
- **Open WebUI** - Chat interface for Ollama models
- **Qdrant** - Vector database for AI applications
- **Postgres** - Relational database for n8n
- **ngrok** - Secure tunneling for external access

This project is a fusion of [cloud-local-ngrok](https://github.com/ThijsdeZeeuw/cloud-local-ngrok) and [self-hosted-ai-starter-kit-with-ngrok](https://github.com/DevilUpperCase/self-hosted-ai-starter-kit-with-ngrok), providing a complete AI development environment with proper external access through ngrok.

## Features

- **n8n** - Powerful workflow automation platform
- **Ollama** - Run LLMs locally or on your server
- **Open WebUI** - Chat interface for Ollama models
- **Qdrant** - Vector database for AI applications
- **Postgres** - Relational database for n8n
- **ngrok** - Secure tunneling for external access

## Requirements

- **Docker** - Docker Desktop (Windows/Mac) or Docker Engine (Linux)
- **Docker Compose** - Usually included with Docker Desktop or can be installed separately
- **4+ CPU cores** recommended
- **8GB+ RAM** recommended
- **20GB+ storage space**

## Quick Installation

### Windows

1. Download this repository as a ZIP file and extract it
2. Navigate to the extracted folder
3. Double-click `install.bat` to run the installation

Alternatively, you can run in PowerShell:

```powershell
git clone https://github.com/ThijsdeZeeuw/cloud-local-ngrok.git
cd cloud-local-ngrok
.\install.bat
```

### Linux/macOS

Run this single command as root:

```bash
curl -s https://raw.githubusercontent.com/ThijsdeZeeuw/cloud-local-ngrok/main/install.sh | bash
```

Or clone the repository and run the installation script:

```bash
git clone https://github.com/ThijsdeZeeuw/cloud-local-ngrok.git
cd cloud-local-ngrok
chmod +x install.sh
sudo ./install.sh
```

### GPU Support (Optional)

If you have an NVIDIA or AMD GPU and want to use it for Ollama:

**NVIDIA GPU**:
```bash
docker compose --profile gpu-nvidia up -d
```

**AMD GPU** (Linux only):
```bash
docker compose --profile gpu-amd up -d
```

## Accessing Your Services

After installation, you can access:

### Local Installation (Windows/macOS)
- **n8n**: http://localhost:5678
- **Open WebUI**: http://localhost:3000
- **Ollama API**: http://localhost:11434
- **Qdrant API**: http://localhost:6333
- **ngrok dashboard**: http://localhost:4040
- **ngrok tunnel URLs**: Visit the ngrok dashboard to find your HTTPS URLs

### VPS/Server Installation (Linux)
- **n8n**: http://YOUR_SERVER_IP:5678
- **Open WebUI**: http://YOUR_SERVER_IP:3000
- **Ollama API**: http://YOUR_SERVER_IP:11434
- **Qdrant API**: http://YOUR_SERVER_IP:6333
- **ngrok dashboard**: http://YOUR_SERVER_IP:4040
- **ngrok tunnel URLs**: Visit the ngrok dashboard to find your HTTPS URLs

## Setting Up ngrok

This stack uses ngrok to make your local services accessible from the internet, which is perfect for:
- Using n8n with external webhooks (Telegram, WhatsApp, etc.)
- Sharing your AI chatbot with others
- Testing integrations without deploying to a server

1. Sign up for a free account at [ngrok.com](https://ngrok.com/)
2. Get your authtoken from [dashboard.ngrok.com/get-started/your-authtoken](https://dashboard.ngrok.com/get-started/your-authtoken)
3. You can get a free static domain at [dashboard.ngrok.com/cloud-edge/domains](https://dashboard.ngrok.com/cloud-edge/domains)
4. Edit your `.env` file to add your authtoken and domain
5. Also update your `ngrok.yml` file with the same information

## Configuration

The setup can be customized through the following files:

1. `.env` - Environment variables for all services
2. `docker-compose.yml` - Container configurations
3. `ngrok.yml` - Tunneling settings

## Shared Folder

The stack creates a `shared` directory that is accessible from n8n. In n8n, this directory is accessible at `/data/shared`. You can use this to:
- Store files that n8n needs to process
- Save outputs from your workflows
- Share data between n8n and your host system

## Troubleshooting

If you encounter issues:

1. Check Docker container status: `docker ps -a`
2. View container logs: `docker logs <container_name>`
3. Check system resources: `htop` or `docker stats`
4. Verify ngrok is running correctly in the dashboard
5. On Windows, make sure Docker Desktop is running and WSL2 is properly configured

## Updating

To update all services:

### Windows
```
cd cloud-local-ngrok
.\install.bat
```

### Linux/macOS
```bash
cd cloud-local-ngrok
chmod +x update-script.sh
sudo ./update-script.sh
```

## License

MIT

## Credits

- [n8n](https://n8n.io/)
- [Ollama](https://ollama.ai/)
- [Open WebUI](https://github.com/open-webui/open-webui)
- [Qdrant](https://qdrant.tech/)
- [ngrok](https://ngrok.com/)
- [Docker](https://www.docker.com/) 