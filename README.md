# AI Development Stack with ngrok

A comprehensive, production-ready AI development environment with n8n, Ollama, Open WebUI, Qdrant, and ngrok tunneling for VPS deployment.

## Features

- **n8n** - Powerful workflow automation platform
- **Ollama** - Run LLMs locally or on your server
- **Open WebUI** - Chat interface for Ollama models
- **Qdrant** - Vector database for AI applications
- **Postgres** - Relational database for n8n
- **ngrok** - Secure tunneling for external access

## Quick Installation

Run this single command on your VPS:

```bash
curl -s https://raw.githubusercontent.com/ThijsdeZeeuw/cloud-local-ngrok/main/install.sh | bash
```

## Manual Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/ThijsdeZeeuw/cloud-local-ngrok.git
   cd cloud-local-ngrok
   ```

2. **Run the installation script**
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

## Accessing Your Services

After installation, you can access:

- **n8n**: http://YOUR_VPS_IP:5678
- **Open WebUI**: http://YOUR_VPS_IP:3000
- **Ollama API**: http://YOUR_VPS_IP:11434
- **Qdrant API**: http://YOUR_VPS_IP:6333
- **ngrok dashboard**: http://YOUR_VPS_IP:4040
- **ngrok tunnel URLs**: Visit the ngrok dashboard to find your HTTPS URLs

## Hardware Requirements

- 4+ CPU cores recommended
- 8GB+ RAM recommended
- 20GB+ storage space

## Configuration

The setup can be customized through the following files:

1. `.env` - Environment variables for all services
2. `docker-compose.yml` - Container configurations
3. `ngrok.yml` - Tunneling settings

## Troubleshooting

If you encounter issues:

1. Check Docker container status: `docker ps -a`
2. View container logs: `docker logs <container_name>`
3. Check system resources: `htop` or `docker stats`
4. Verify ngrok is running correctly in the dashboard

## Updating

To update all services:

```bash
chmod +x update-script.sh
./update-script.sh
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