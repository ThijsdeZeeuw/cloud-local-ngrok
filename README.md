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

The stack uses CPU by default for Ollama, but if you have a compatible GPU, you can enable it:

**NVIDIA GPU**:
```bash
docker compose --profile gpu-nvidia up -d
```

**AMD GPU** (Linux only):
```bash
docker compose --profile gpu-amd up -d
```

Note: When using GPU profiles, the default CPU-based Ollama service remains enabled to ensure compatibility with all dependent services. This prevents dependency conflicts.

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

## Using with Telegram

To set up a Telegram bot with this stack:

1. Talk to [@BotFather](https://t.me/BotFather) on Telegram to create a new bot and get a token
2. In n8n, create a new workflow with a Telegram trigger node
3. Configure the Telegram node with your bot token
4. Use the following webhook URL in your Telegram settings:
   `https://vertically-concise-stud.ngrok-free.app/webhook/{n8n-path}`
   (Where `{n8n-path}` is the path defined in your n8n Telegram trigger node)
5. Test your bot by sending it a message

Example Telegram bot workflow setup in n8n:
1. Add a "Telegram Trigger" node
2. Configure it with your bot token
3. Set the Resource to "Message" and Event to "Received"
4. Connect it to an "Ollama" node to generate AI responses
5. Add a "Telegram" node to send the response back to the user
6. Activate the workflow

Advanced Telegram bot features you can add:
- Image generation with Stable Diffusion
- Document analysis with Ollama and Qdrant
- Calendar integration for scheduling appointments
- Weather information using external APIs
- News summarization from RSS feeds

### Linux-Specific Telegram Setup

For Linux users, we've created dedicated tools to simplify the Telegram bot setup:

1. **Automatic Setup Script**:
   ```bash
   chmod +x setup-telegram-linux.sh
   ./setup-telegram-linux.sh
   ```
   This script handles everything - checking requirements, installing Docker if needed, setting up the webhook, and creating a systemd service for auto-start.

2. **Detailed Linux Guide**:
   
   The `linux-telegram-setup.md` file contains comprehensive instructions for Linux-specific setup, including:
   - Complete step-by-step instructions
   - Troubleshooting Linux-specific issues
   - Firewall configuration
   - Creating a systemd service for automatic startup

These tools ensure that your Telegram bot works perfectly on Linux systems, whether a local installation or a remote VPS.

## Using with WhatsApp

To set up WhatsApp integration with this stack:

1. Create a Meta for Developers account at [developers.facebook.com](https://developers.facebook.com/)
2. Set up a WhatsApp Business API application in the Meta Developer Portal
3. Configure a webhook with the ngrok URL:
   `https://vertically-concise-stud.ngrok-free.app/webhook/{n8n-path}`
4. In n8n, create a new workflow with a Webhook node to receive WhatsApp messages
5. Use the WhatsApp node to send responses back to users

Example WhatsApp workflow setup in n8n:
1. Add a "Webhook" node configured to receive POST requests
2. Add a JavaScript node to parse the WhatsApp message format
3. Connect to an "Ollama" node for AI-generated responses
4. Use HTTP Request nodes to send messages back via the WhatsApp API
5. Activate the workflow

WhatsApp integration use cases:
- Customer support automation
- Appointment scheduling and reminders
- Product information and recommendations
- Order status updates
- Educational content delivery

## Example Workflows

We've included sample workflows in the `examples` directory to help you get started quickly:

- [Telegram Bot Workflow](examples/telegram-bot-workflow.json) - Ready-to-import n8n workflow for a Telegram AI assistant
- [WhatsApp Bot Workflow](examples/whatsapp-bot-workflow.json) - Ready-to-import n8n workflow for a WhatsApp AI assistant

See the [examples README](examples/README.md) for detailed instructions on how to import and configure these workflows.

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

### Common Issues

- **"Service was pulled in as a dependency but is not enabled by the active profiles"**: This error has been fixed in the latest version. The default Ollama service is now always enabled regardless of profile.
- **Cannot access Ollama when using GPU**: Make sure you have the proper GPU drivers installed and Docker has access to your GPU.
- **Telegram bot not receiving messages**: Check that your webhook URL is correct and the n8n workflow is activated.

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