#!/bin/bash

# Telegram Webhook Setup Script

# Replace these values with your actual bot token from BotFather
BOT_TOKEN="7704615156:AAGydr3mul7LFXIg0zSDkDcNW8DhdCQhsLU"

# Your n8n webhook URL (using ngrok)
WEBHOOK_URL="https://vertically-concise-stud.ngrok-free.app/webhook/322dce18-f93e-4f86-b9b1-3305519b7834/webhook"

# Local webhook URL (will only work once Docker is running and n8n is accessible)
LOCAL_WEBHOOK_URL="http://localhost:5678/webhook/322dce18-f93e-4f86-b9b1-3305519b7834/webhook"

# Text colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to set up webhook
setup_webhook() {
    local webhook_url=$1
    
    echo -e "${CYAN}Setting up Telegram webhook with URL: ${webhook_url}${NC}"
    
    # Construct the URL to set the webhook
    local set_webhook_url="https://api.telegram.org/bot${BOT_TOKEN}/setWebhook?url=${webhook_url}"
    
    # Make the API call
    response=$(curl -s "${set_webhook_url}")
    
    # Check if the response contains "ok":true
    if [[ $response == *'"ok":true'* ]]; then
        echo -e "${GREEN}Webhook setup successful!${NC}"
    else
        echo -e "${RED}Webhook setup failed. Response: ${response}${NC}"
    fi
}

# Function to get current webhook info
get_webhook_info() {
    echo -e "${CYAN}Getting current webhook information...${NC}"
    
    # Construct the URL to get webhook info
    local get_webhook_info_url="https://api.telegram.org/bot${BOT_TOKEN}/getWebhookInfo"
    
    # Make the API call
    response=$(curl -s "${get_webhook_info_url}")
    
    # Display the response
    echo -e "${CYAN}Current webhook info:${NC}"
    echo "${response}" | sed 's/,/,\n/g' | sed 's/{/{\n/g' | sed 's/}/\n}/g'
}

# Function to delete webhook
remove_webhook() {
    echo -e "${CYAN}Removing current webhook...${NC}"
    
    # Construct the URL to delete the webhook
    local delete_webhook_url="https://api.telegram.org/bot${BOT_TOKEN}/deleteWebhook"
    
    # Make the API call
    response=$(curl -s "${delete_webhook_url}")
    
    # Check if the response contains "ok":true
    if [[ $response == *'"ok":true'* ]]; then
        echo -e "${GREEN}Webhook removal successful!${NC}"
    else
        echo -e "${RED}Webhook removal failed. Response: ${response}${NC}"
    fi
}

# Main script
echo -e "${CYAN}Telegram Webhook Setup Script${NC}"
echo -e "${CYAN}===========================${NC}"

if [[ "$BOT_TOKEN" == "YOUR_BOT_TOKEN" ]]; then
    echo -e "${YELLOW}Please replace 'YOUR_BOT_TOKEN' with your actual Telegram bot token in this script.${NC}"
    echo -e "${YELLOW}You can get a token by talking to @BotFather on Telegram.${NC}"
    exit 1
fi

# Display menu
echo -e "${CYAN}Please select an option:${NC}"
echo -e "1. Set up webhook with ngrok URL (${WEBHOOK_URL})"
echo -e "2. Set up webhook with local URL (${LOCAL_WEBHOOK_URL})"
echo -e "3. Get current webhook information"
echo -e "4. Remove current webhook"
echo -e "5. Exit"

read -p "Enter option (1-5): " option

case $option in
    1)
        setup_webhook "${WEBHOOK_URL}"
        ;;
    2)
        setup_webhook "${LOCAL_WEBHOOK_URL}"
        ;;
    3)
        get_webhook_info
        ;;
    4)
        remove_webhook
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

echo -e "\n${CYAN}Script complete. Next steps:${NC}"
echo "1. Make sure Docker Desktop is installed and running"
echo "2. Run the install.bat script to set up the Docker containers"
echo "3. Import the Telegram workflow from examples/telegram-bot-workflow-custom.json into n8n"
echo "4. Configure the Telegram nodes with your bot token"
echo "5. Activate the workflow"

chmod +x "$0" 