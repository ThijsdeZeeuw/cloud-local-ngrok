# Telegram Webhook Setup Script

# Replace these values with your actual bot token from BotFather
$BOT_TOKEN = "7704615156:AAGydr3mul7LFXIg0zSDkDcNW8DhdCQhsLU"

# Your n8n webhook URL (using ngrok)
$WEBHOOK_URL = "https://vertically-concise-stud.ngrok-free.app/webhook/322dce18-f93e-4f86-b9b1-3305519b7834/webhook"

# Local webhook URL (will only work once Docker is running and n8n is accessible)
$LOCAL_WEBHOOK_URL = "http://localhost:5678/webhook/322dce18-f93e-4f86-b9b1-3305519b7834/webhook"

# Function to set up webhook
function Setup-TelegramWebhook {
    param (
        [string]$webhookUrl
    )
    
    Write-Host "Setting up Telegram webhook with URL: $webhookUrl"
    
    # Construct the URL to set the webhook
    $setWebhookUrl = "https://api.telegram.org/bot$BOT_TOKEN/setWebhook?url=$webhookUrl"
    
    try {
        # Make the API call
        $response = Invoke-RestMethod -Uri $setWebhookUrl -Method Get
        
        # Check the response
        if ($response.ok -eq $true) {
            Write-Host "Webhook setup successful: $($response.description)" -ForegroundColor Green
        } else {
            Write-Host "Webhook setup failed: $($response.description)" -ForegroundColor Red
        }
    } catch {
        Write-Host "Error setting up webhook: $_" -ForegroundColor Red
    }
}

# Function to get current webhook info
function Get-WebhookInfo {
    Write-Host "Getting current webhook information..."
    
    # Construct the URL to get webhook info
    $getWebhookInfoUrl = "https://api.telegram.org/bot$BOT_TOKEN/getWebhookInfo"
    
    try {
        # Make the API call
        $response = Invoke-RestMethod -Uri $getWebhookInfoUrl -Method Get
        
        # Display the response
        Write-Host "Current webhook info:" -ForegroundColor Cyan
        $response.result | Format-List
    } catch {
        Write-Host "Error getting webhook info: $_" -ForegroundColor Red
    }
}

# Function to delete webhook
function Remove-Webhook {
    Write-Host "Removing current webhook..."
    
    # Construct the URL to delete the webhook
    $deleteWebhookUrl = "https://api.telegram.org/bot$BOT_TOKEN/deleteWebhook"
    
    try {
        # Make the API call
        $response = Invoke-RestMethod -Uri $deleteWebhookUrl -Method Get
        
        # Check the response
        if ($response.ok -eq $true) {
            Write-Host "Webhook removal successful: $($response.description)" -ForegroundColor Green
        } else {
            Write-Host "Webhook removal failed: $($response.description)" -ForegroundColor Red
        }
    } catch {
        Write-Host "Error removing webhook: $_" -ForegroundColor Red
    }
}

# Main script execution
Write-Host "Telegram Webhook Setup Script" -ForegroundColor Cyan
Write-Host "===========================" -ForegroundColor Cyan

if ($BOT_TOKEN -eq "YOUR_BOT_TOKEN") {
    Write-Host "Please replace 'YOUR_BOT_TOKEN' with your actual Telegram bot token in this script." -ForegroundColor Yellow
    Write-Host "You can get a token by talking to @BotFather on Telegram." -ForegroundColor Yellow
    exit
}

# Display menu
Write-Host "Please select an option:" -ForegroundColor Cyan
Write-Host "1. Set up webhook with ngrok URL ($WEBHOOK_URL)" -ForegroundColor White
Write-Host "2. Set up webhook with local URL ($LOCAL_WEBHOOK_URL)" -ForegroundColor White
Write-Host "3. Get current webhook information" -ForegroundColor White
Write-Host "4. Remove current webhook" -ForegroundColor White
Write-Host "5. Exit" -ForegroundColor White

$option = Read-Host "Enter option (1-5)"

switch ($option) {
    "1" { Setup-TelegramWebhook -webhookUrl $WEBHOOK_URL }
    "2" { Setup-TelegramWebhook -webhookUrl $LOCAL_WEBHOOK_URL }
    "3" { Get-WebhookInfo }
    "4" { Remove-Webhook }
    "5" { Write-Host "Exiting..." -ForegroundColor Cyan }
    default { Write-Host "Invalid option. Exiting..." -ForegroundColor Red }
}

Write-Host "`nScript complete. Next steps:" -ForegroundColor Cyan
Write-Host "1. Make sure Docker Desktop is installed and running" -ForegroundColor White
Write-Host "2. Run the install.bat script to set up the Docker containers" -ForegroundColor White
Write-Host "3. Import the Telegram workflow from examples/telegram-bot-workflow.json into n8n" -ForegroundColor White
Write-Host "4. Configure the Telegram nodes with your bot token" -ForegroundColor White
Write-Host "5. Activate the workflow" -ForegroundColor White 