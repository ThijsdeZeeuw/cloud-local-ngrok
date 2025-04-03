# AI Development Stack with ngrok

A comprehensive, production-ready AI development environment with n8n, Ollama, Open WebUI, Qdrant, and ngrok tunneling for both local development and VPS deployment.

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

## Configuration

The setup can be customized through the following files:

1. `.env` - Environment variables for all services
2. `docker-compose.yml` - Container configurations
3. `ngrok.yml` - Tunneling settings (add your own ngrok authtoken for production use)

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