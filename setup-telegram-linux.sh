#!/bin/bash

# Automatic Telegram Bot Setup Script for Linux
# This script automates the installation and configuration of the Telegram bot

# Text colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Bot token
BOT_TOKEN="7704615156:AAGydr3mul7LFXIg0zSDkDcNW8DhdCQhsLU"

# Webhook URL
WEBHOOK_URL="https://vertically-concise-stud.ngrok-free.app/webhook/322dce18-f93e-4f86-b9b1-3305519b7834/webhook"

# Function to check if Docker is installed
check_docker() {
    echo -e "${CYAN}Checking if Docker is installed...${NC}"
    if command -v docker &> /dev/null; then
        echo -e "${GREEN}Docker is installed!${NC}"
    else
        echo -e "${RED}Docker is not installed. Installing Docker...${NC}"
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        rm get-docker.sh
        echo -e "${GREEN}Docker has been installed!${NC}"
    fi
}

# Function to check if Docker Compose is installed
check_docker_compose() {
    echo -e "${CYAN}Checking if Docker Compose is installed...${NC}"
    if command -v docker-compose &> /dev/null; then
        echo -e "${GREEN}Docker Compose is installed!${NC}"
    else
        echo -e "${RED}Docker Compose is not installed. Installing Docker Compose...${NC}"
        sudo apt-get update
        sudo apt-get install -y docker-compose
        echo -e "${GREEN}Docker Compose has been installed!${NC}"
    fi
}

# Function to set up the Telegram webhook
setup_webhook() {
    echo -e "${CYAN}Setting up Telegram webhook...${NC}"
    
    # Construct the URL to set the webhook
    local set_webhook_url="https://api.telegram.org/bot${BOT_TOKEN}/setWebhook?url=${WEBHOOK_URL}"
    
    # Make the API call
    response=$(curl -s "${set_webhook_url}")
    
    # Check if the response contains "ok":true
    if [[ $response == *'"ok":true'* ]]; then
        echo -e "${GREEN}Webhook setup successful!${NC}"
    else
        echo -e "${RED}Webhook setup failed. Response: ${response}${NC}"
        exit 1
    fi
}

# Function to install or update the AI stack
install_ai_stack() {
    echo -e "${CYAN}Setting up AI stack...${NC}"
    
    # Make sure we're in the right directory
    cd "$(dirname "$0")"
    
    # Check if install.sh exists
    if [ ! -f "install.sh" ]; then
        echo -e "${RED}Error: install.sh file not found in the current directory.${NC}"
        exit 1
    fi
    
    # Make it executable
    chmod +x install.sh
    
    # Run the installation script
    echo -e "${YELLOW}Running installation script. This may take several minutes...${NC}"
    sudo ./install.sh
    
    echo -e "${GREEN}AI stack installation completed!${NC}"
}

# Function to verify the containers are running
verify_containers() {
    echo -e "${CYAN}Verifying containers are running...${NC}"
    
    # Get a list of running containers
    containers=$(docker ps --format "{{.Names}}")
    
    # Check if n8n and ngrok containers are running
    if [[ $containers == *"n8n"* ]] && [[ $containers == *"ngrok"* ]]; then
        echo -e "${GREEN}All required containers are running!${NC}"
    else
        echo -e "${RED}Some containers are not running. Attempting to start them...${NC}"
        docker-compose up -d
        
        # Check again after trying to start them
        containers=$(docker ps --format "{{.Names}}")
        if [[ $containers == *"n8n"* ]] && [[ $containers == *"ngrok"* ]]; then
            echo -e "${GREEN}All required containers are now running!${NC}"
        else
            echo -e "${RED}Failed to start all required containers. Please check Docker logs.${NC}"
            exit 1
        fi
    fi
}

# Function to import the n8n workflow
import_workflow() {
    echo -e "${CYAN}The Telegram workflow needs to be imported manually into n8n.${NC}"
    echo -e "${CYAN}Please follow these steps:${NC}"
    
    # Get the server's IP address
    server_ip=$(curl -s ifconfig.me || echo "localhost")
    
    echo -e "1. Access n8n at ${YELLOW}http://${server_ip}:5678${NC}"
    echo -e "2. Navigate to 'Workflows' in the left sidebar"
    echo -e "3. Click 'Import from File'"
    echo -e "4. Select the file: ${YELLOW}examples/telegram-bot-workflow-custom.json${NC}"
    echo -e "5. Open the imported workflow"
    echo -e "6. Configure the Telegram nodes with your bot token: ${YELLOW}${BOT_TOKEN}${NC}"
    echo -e "7. Verify the webhook path is: ${YELLOW}/webhook/322dce18-f93e-4f86-b9b1-3305519b7834/webhook${NC}"
    echo -e "8. Activate the workflow using the toggle in the top-right corner"
}

# Function to check webhook status
check_webhook_status() {
    echo -e "${CYAN}Checking webhook status...${NC}"
    
    # Construct the URL to get webhook info
    local get_webhook_info_url="https://api.telegram.org/bot${BOT_TOKEN}/getWebhookInfo"
    
    # Make the API call
    response=$(curl -s "${get_webhook_info_url}")
    
    # Extract the current webhook URL
    current_url=$(echo "$response" | grep -o '"url":"[^"]*"' | cut -d'"' -f4)
    
    # Check if the webhook is correctly set
    if [[ "$current_url" == "$WEBHOOK_URL" ]]; then
        echo -e "${GREEN}Webhook is correctly set to: $current_url${NC}"
    else
        echo -e "${YELLOW}Webhook is set to: $current_url${NC}"
        echo -e "${YELLOW}Expected: $WEBHOOK_URL${NC}"
        
        # Ask if the user wants to update the webhook
        read -p "Do you want to update the webhook URL? (y/n): " choice
        if [[ "$choice" == "y" ]]; then
            setup_webhook
        fi
    fi
}

# Function to create systemd service
create_service() {
    echo -e "${CYAN}Creating systemd service for automatic startup...${NC}"
    
    # Get current directory
    current_dir=$(pwd)
    
    # Create service file
    cat > /tmp/ai-stack.service << EOL
[Unit]
Description=AI Stack with Telegram Bot
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=${current_dir}
ExecStart=/usr/bin/docker-compose up -d
ExecStop=/usr/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOL
    
    # Move service file to correct location
    sudo mv /tmp/ai-stack.service /etc/systemd/system/
    
    # Reload systemd
    sudo systemctl daemon-reload
    
    # Enable and start the service
    sudo systemctl enable ai-stack.service
    sudo systemctl start ai-stack.service
    
    echo -e "${GREEN}Service has been created and started!${NC}"
    echo -e "${GREEN}The AI stack will now start automatically on system boot.${NC}"
}

# Main script execution
echo -e "${CYAN}=========================================${NC}"
echo -e "${CYAN}  Telegram Bot Auto-Setup for Linux     ${NC}"
echo -e "${CYAN}=========================================${NC}"
echo ""

# Check requirements
check_docker
check_docker_compose

# Ask what the user wants to do
echo -e "${CYAN}What would you like to do?${NC}"
echo -e "1. Full installation (install AI stack + set up Telegram webhook)"
echo -e "2. Set up Telegram webhook only"
echo -e "3. Check webhook status"
echo -e "4. Create systemd service for automatic startup"
echo -e "5. Exit"

read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        install_ai_stack
        verify_containers
        setup_webhook
        import_workflow
        ;;
    2)
        setup_webhook
        import_workflow
        ;;
    3)
        check_webhook_status
        ;;
    4)
        create_service
        ;;
    5)
        echo -e "${CYAN}Exiting...${NC}"
        exit 0
        ;;
    *)
        echo -e "${RED}Invalid option. Exiting...${NC}"
        exit 1
        ;;
esac

echo -e "\n${GREEN}Setup complete!${NC}"
echo -e "${CYAN}Test your Telegram bot by sending a message to it.${NC}"
echo -e "${CYAN}If you encounter any issues, refer to linux-telegram-setup.md for troubleshooting.${NC}"

# Make this script executable for future use
chmod +x "$0" 