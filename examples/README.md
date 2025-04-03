# Example n8n Workflows

This directory contains example n8n workflows that you can import into your n8n instance to get started quickly with integrations.

## Available Examples

1. **Telegram Bot Workflow** (`telegram-bot-workflow.json`)
   - An AI assistant that integrates Telegram with Ollama
   - Responds to messages sent to your Telegram bot
   - Uses the Llama2 model by default

2. **WhatsApp Bot Workflow** (`whatsapp-bot-workflow.json`)
   - An AI assistant that integrates WhatsApp with Ollama
   - Processes incoming WhatsApp messages through Meta's API
   - Uses the Llama2 model by default

## How to Import Workflows

1. Access your n8n instance at http://localhost:5678 (or your custom domain)
2. Click on "Workflows" in the left sidebar
3. Click on the "Import from File" button (or "Import from URL" if you're using the GitHub repository URL)
4. Select the workflow JSON file you want to import
5. Review the workflow and click "Import"

## Configuring the Workflows

### Telegram Bot Workflow

1. Create a Telegram bot using BotFather
2. Copy your bot token
3. In n8n, edit the "Telegram trigger" node
4. Add a new Telegram API credential with your bot token
5. Save and activate the workflow
6. Test by sending a message to your Telegram bot

### WhatsApp Bot Workflow

1. Set up a Meta for Developers account
2. Create a WhatsApp Business API application
3. Configure your webhook URL as: `https://your-ngrok-domain.ngrok-free.app/webhook/whatsapp-webhook`
4. In n8n, edit the "WhatsApp Webhook" node to match your webhook configuration
5. Edit the "Send WhatsApp Response" node to include your API credential (Bearer token)
6. Save and activate the workflow
7. Test by sending a message to your WhatsApp Business number

## Customizing the Workflows

### Changing the Ollama Model

1. Edit the "Generate AI Response" node in either workflow
2. Change the "Model" parameter from `llama2:latest` to another model you have pulled in Ollama
3. Adjust system instructions as needed for the specific model
4. Save the workflow

### Adding More Features

You can extend these workflows by adding:

- Image generation capabilities
- Document processing and analysis
- Database interactions
- External API integrations
- Multi-step conversations
- User preference tracking

## Troubleshooting

If you encounter issues:

1. **Webhook errors**: Check that your ngrok tunnel is running and your webhook URL is correctly configured
2. **Authentication failures**: Verify your API credentials in n8n
3. **Model errors**: Ensure the specified Ollama model is pulled and available
4. **Connection issues**: Check that all services are running in Docker

For more help, check the logs in n8n and Docker. 