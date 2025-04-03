# Telegram Integration Troubleshooting Script

Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  Telegram Integration Troubleshooter" -ForegroundColor Cyan  
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""

# Function to check Docker status
function Check-Docker {
    Write-Host "Checking Docker status..." -ForegroundColor Cyan
    
    try {
        $dockerInfo = docker info 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Docker is running properly" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ Docker is not running" -ForegroundColor Red
            Write-Host "Please start Docker Desktop and try again" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "❌ Docker is not installed or not in PATH" -ForegroundColor Red
        Write-Host "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop/" -ForegroundColor Red
        return $false
    }
}

# Function to check containers
function Check-Containers {
    Write-Host "Checking container status..." -ForegroundColor Cyan
    
    try {
        $containers = docker ps -a --format "{{.Names}},{{.Status}}"
        if ($LASTEXITCODE -ne 0) { throw "Failed to get container list" }
        
        $containerArray = $containers -split "`n"
        
        if ($containerArray.Count -eq 0 -or ($containerArray.Count -eq 1 -and $containerArray[0] -eq "")) {
            Write-Host "❌ No containers found" -ForegroundColor Red
            Write-Host "Run the install.bat script to set up the required containers" -ForegroundColor Yellow
            return $false
        }
        
        $n8nFound = $false
        $ngrokFound = $false
        $ollamaFound = $false
        
        foreach ($container in $containerArray) {
            if ($container -eq "") { continue }
            
            $parts = $container -split ","
            $name = $parts[0]
            $status = $parts[1]
            $isRunning = $status -match "Up"
            
            if ($name -match "n8n") { 
                $n8nFound = $true
                if ($isRunning) {
                    Write-Host "✅ n8n container is running" -ForegroundColor Green
                } else {
                    Write-Host "❌ n8n container found but not running" -ForegroundColor Red
                }
            }
            
            if ($name -match "ngrok") {
                $ngrokFound = $true
                if ($isRunning) {
                    Write-Host "✅ ngrok container is running" -ForegroundColor Green
                } else {
                    Write-Host "❌ ngrok container found but not running" -ForegroundColor Red
                }
            }
            
            if ($name -match "ollama") {
                $ollamaFound = $true
                if ($isRunning) {
                    Write-Host "✅ ollama container is running" -ForegroundColor Green
                } else {
                    Write-Host "❌ ollama container found but not running" -ForegroundColor Red
                }
            }
        }
        
        if (-not $n8nFound) {
            Write-Host "❌ n8n container not found" -ForegroundColor Red
        }
        
        if (-not $ngrokFound) {
            Write-Host "❌ ngrok container not found" -ForegroundColor Red
        }
        
        if (-not $ollamaFound) {
            Write-Host "❌ ollama container not found" -ForegroundColor Red
        }
        
        return $n8nFound -and $ngrokFound -and $ollamaFound
    } catch {
        Write-Host "❌ Error checking containers: $_" -ForegroundColor Red
        return $false
    }
}

# Function to check ngrok tunnel
function Check-NgrokTunnel {
    Write-Host "Checking ngrok tunnel..." -ForegroundColor Cyan
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:4040/api/tunnels" -UseBasicParsing -ErrorAction Stop
        $tunnels = ConvertFrom-Json $response.Content
        
        if ($tunnels.tunnels.Length -eq 0) {
            Write-Host "❌ No active ngrok tunnels found" -ForegroundColor Red
            return $false
        }
        
        $foundN8nTunnel = $false
        
        foreach ($tunnel in $tunnels.tunnels) {
            Write-Host "Found tunnel: $($tunnel.name) -> $($tunnel.public_url)" -ForegroundColor Cyan
            
            if ($tunnel.name -match "n8n" -or $tunnel.config.addr -match "n8n" -or $tunnel.name -match "custom-domain") {
                $foundN8nTunnel = $true
                Write-Host "✅ n8n tunnel is active at: $($tunnel.public_url)" -ForegroundColor Green
            }
        }
        
        if (-not $foundN8nTunnel) {
            Write-Host "❌ n8n tunnel not found" -ForegroundColor Red
        }
        
        return $foundN8nTunnel
    } catch {
        if ($_.Exception.Message -match "Unable to connect to the remote server" -or $_.Exception.Message -match "actively refused") {
            Write-Host "❌ Cannot access ngrok dashboard - is ngrok container running?" -ForegroundColor Red
        } else {
            Write-Host "❌ Error checking ngrok tunnels: $_" -ForegroundColor Red
        }
        return $false
    }
}

# Function to check n8n access
function Check-N8nAccess {
    Write-Host "Checking n8n accessibility..." -ForegroundColor Cyan
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:5678/healthz" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ n8n is accessible at http://localhost:5678" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ n8n returned status code $($response.StatusCode)" -ForegroundColor Red
            return $false
        }
    } catch {
        if ($_.Exception.Message -match "Unable to connect to the remote server" -or $_.Exception.Message -match "actively refused") {
            Write-Host "❌ Cannot access n8n - is the n8n container running?" -ForegroundColor Red
        } else {
            Write-Host "❌ Error checking n8n access: $_" -ForegroundColor Red
        }
        return $false
    }
}

# Function to check webhook URL
function Check-WebhookURL {
    param(
        [string]$webhookURL,
        [string]$botToken
    )
    
    Write-Host "Checking webhook URL: $webhookURL" -ForegroundColor Cyan
    
    if (-not $botToken -or $botToken -eq "YOUR_BOT_TOKEN") {
        Write-Host "❌ Bot token not provided - skipping webhook check" -ForegroundColor Red
        Write-Host "Please set your bot token in the setup-telegram-integration.ps1 script" -ForegroundColor Yellow
        return $false
    }
    
    try {
        $getWebhookInfoUrl = "https://api.telegram.org/bot$botToken/getWebhookInfo"
        $response = Invoke-RestMethod -Uri $getWebhookInfoUrl -Method Get -ErrorAction Stop
        
        # Check if URL matches our webhook
        if ($response.result.url -eq $webhookURL) {
            Write-Host "✅ Telegram webhook is correctly set to $webhookURL" -ForegroundColor Green
            return $true
        } elseif ($response.result.url) {
            Write-Host "❓ Telegram webhook is set to $($response.result.url)" -ForegroundColor Yellow
            Write-Host "This doesn't match the expected URL: $webhookURL" -ForegroundColor Yellow
            
            # Ask if user wants to update webhook
            $updateWebhook = Read-Host "Do you want to update the webhook to the correct URL? (y/n)"
            if ($updateWebhook -eq "y") {
                $setWebhookUrl = "https://api.telegram.org/bot$botToken/setWebhook?url=$webhookURL"
                $updateResponse = Invoke-RestMethod -Uri $setWebhookUrl -Method Get -ErrorAction Stop
                
                if ($updateResponse.ok -eq $true) {
                    Write-Host "✅ Webhook updated successfully" -ForegroundColor Green
                    return $true
                } else {
                    Write-Host "❌ Failed to update webhook: $($updateResponse.description)" -ForegroundColor Red
                    return $false
                }
            }
            
            return $false
        } else {
            Write-Host "❌ No webhook URL is currently set" -ForegroundColor Red
            
            # Ask if user wants to set webhook
            $setWebhook = Read-Host "Do you want to set the webhook URL? (y/n)"
            if ($setWebhook -eq "y") {
                $setWebhookUrl = "https://api.telegram.org/bot$botToken/setWebhook?url=$webhookURL"
                $updateResponse = Invoke-RestMethod -Uri $setWebhookUrl -Method Get -ErrorAction Stop
                
                if ($updateResponse.ok -eq $true) {
                    Write-Host "✅ Webhook set successfully" -ForegroundColor Green
                    return $true
                } else {
                    Write-Host "❌ Failed to set webhook: $($updateResponse.description)" -ForegroundColor Red
                    return $false
                }
            }
            
            return $false
        }
    } catch {
        Write-Host "❌ Error checking webhook: $_" -ForegroundColor Red
        return $false
    }
}

# Main script logic
$dockerRunning = Check-Docker

if ($dockerRunning) {
    $containersRunning = Check-Containers
    
    if ($containersRunning) {
        $n8nAccessible = Check-N8nAccess
        $ngrokTunnelActive = Check-NgrokTunnel
        
        if ($n8nAccessible -and $ngrokTunnelActive) {
            # Get bot token
            Write-Host ""
            Write-Host "To check your Telegram webhook setup, I need your bot token." -ForegroundColor Cyan
            $botToken = Read-Host "Enter your Telegram bot token (or press Enter to skip)"
            
            $webhookId = "322dce18-f93e-4f86-b9b1-3305519b7834"
            $localWebhookURL = "http://localhost:5678/webhook/$webhookId/webhook"
            $ngrokWebhookURL = "https://vertically-concise-stud.ngrok-free.app/webhook/$webhookId/webhook"
            
            if ($botToken -and $botToken -ne "") {
                Check-WebhookURL -webhookURL $ngrokWebhookURL -botToken $botToken
            }
        }
    }
}

# Summary and recommendations
Write-Host ""
Write-Host "Troubleshooting Summary:" -ForegroundColor Cyan
Write-Host "--------------------------------" -ForegroundColor Cyan

if (-not $dockerRunning) {
    Write-Host "1. Install and start Docker Desktop" -ForegroundColor Yellow
    Write-Host "2. Run the install.bat script to set up the containers" -ForegroundColor Yellow
} elseif (-not $containersRunning) {
    Write-Host "1. Run the install.bat script to set up the missing containers" -ForegroundColor Yellow
} elseif (-not $n8nAccessible) {
    Write-Host "1. Restart the n8n container using Docker Desktop" -ForegroundColor Yellow
    Write-Host "2. Check Docker logs for any errors: docker logs <n8n_container_name>" -ForegroundColor Yellow
} elseif (-not $ngrokTunnelActive) {
    Write-Host "1. Restart the ngrok container using Docker Desktop" -ForegroundColor Yellow
    Write-Host "2. Check Docker logs for any errors: docker logs <ngrok_container_name>" -ForegroundColor Yellow
    Write-Host "3. Verify ngrok.yml configuration contains the correct tunnels configuration" -ForegroundColor Yellow
} else {
    Write-Host "Your stack appears to be running correctly!" -ForegroundColor Green
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "1. Import the Telegram workflow from examples/telegram-bot-workflow-custom.json into n8n" -ForegroundColor White
    Write-Host "2. Configure the Telegram nodes with your bot token" -ForegroundColor White
    Write-Host "3. Activate the workflow and test your Telegram bot" -ForegroundColor White
}

Write-Host ""
Write-Host "Need more help?" -ForegroundColor Cyan
Write-Host "- Check the telegram-integration-guide.md file for detailed setup instructions" -ForegroundColor White
Write-Host "- Use the setup-telegram-integration.ps1 script to configure your webhook" -ForegroundColor White
Write-Host "- Visit the n8n documentation at https://docs.n8n.io/integrations/builtin/credentials/telegram/" -ForegroundColor White 