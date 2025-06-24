

param(
    [switch]$SkipHealthCheck
)

function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

Write-Host "🚀 LiteLLM Offline Setup and Health Check" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

Write-Status "Checking if base image exists..."
try {
    $null = docker image inspect litellm-base1:latest 2>$null
    Write-Success "Base image found"
} catch {
    Write-Error "Base image litellm-base1:latest not found!"
    Write-Status "Loading base image from tar file..."
    if (Test-Path "litellm-main/litellm-base1.tar") {
        docker load -i litellm-main/litellm-base1.tar
        Write-Success "Base image loaded successfully"
    } else {
        Write-Error "litellm-base1.tar not found in litellm-main directory"
        exit 1
    }
}

Write-Status "Stopping any existing containers..."
try {
    docker-compose down 2>$null
} catch {
    # Ignore errors if no containers were running
}

Write-Status "Building final LiteLLM image..."
docker-compose build --no-cache

Write-Status "Starting LiteLLM proxy container..."
docker-compose up -d

Write-Status "Waiting for container to start (30 seconds)..."
Start-Sleep -Seconds 30

Write-Status "Checking container status..."
$containerStatus = docker-compose ps --format json | ConvertFrom-Json
if ($containerStatus.State -eq "Up") {
    Write-Success "Container is running"
} else {
    Write-Error "Container failed to start"
    Write-Status "Container logs:"
    docker-compose logs
    exit 1
}

if (-not $SkipHealthCheck) {
    Write-Status "Testing health endpoint..."
    $maxAttempts = 10
    $attempt = 1

    while ($attempt -le $maxAttempts) {
        Write-Status "Attempt $attempt/$maxAttempts"
        
        try {
            $response = Invoke-WebRequest -Uri "http://localhost:4000/health" -TimeoutSec 10 -ErrorAction Stop
            if ($response.StatusCode -eq 200) {
                Write-Success "Health endpoint is responding!"
                break
            }
        } catch {
            if ($attempt -eq $maxAttempts) {
                Write-Error "Health endpoint not responding after $maxAttempts attempts"
                Write-Status "Container logs:"
                docker-compose logs --tail=20
                exit 1
            }
            Write-Warning "Health endpoint not ready yet, waiting 10 seconds..."
            Start-Sleep -Seconds 10
            $attempt++
        }
    }

    Write-Status "Running comprehensive health check..."
    try {
        python test_health.py
    } catch {
        Write-Warning "Python not found, using PowerShell for basic health check"
        try {
            $healthResponse = Invoke-WebRequest -Uri "http://localhost:4000/health" -ErrorAction Stop
            Write-Host "Health Response: $($healthResponse.Content)" -ForegroundColor Green
        } catch {
            Write-Error "Failed to get health response"
        }
    }
}

Write-Host ""
Write-Success "LiteLLM Proxy is running successfully!"
Write-Host ""
Write-Host "📋 Service Information:" -ForegroundColor Cyan
Write-Host "   URL: http://localhost:4000" -ForegroundColor White
Write-Host "   Health: http://localhost:4000/health" -ForegroundColor White
Write-Host "   Models: http://localhost:4000/models" -ForegroundColor White
Write-Host ""
Write-Host "🔧 Useful Commands:" -ForegroundColor Cyan
Write-Host "   View logs: docker-compose logs -f" -ForegroundColor White
Write-Host "   Stop service: docker-compose down" -ForegroundColor White
Write-Host "   Restart service: docker-compose restart" -ForegroundColor White
Write-Host "   Check status: docker-compose ps" -ForegroundColor White
Write-Host ""
Write-Success "Setup complete! 🎉" 