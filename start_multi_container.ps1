

param(
    [switch]$BackendOnly,
    [switch]$FrontendOnly,
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

Write-Host "🚀 Multi-Container LiteLLM Setup" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

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
    docker-compose -f docker-compose-multi.yml down 2>$null
} catch {
}

Write-Status "Building containers..."
if ($BackendOnly) {
    Write-Status "Building backend container only..."
    docker-compose -f docker-compose-multi.yml build litellm-backend
} elseif ($FrontendOnly) {
    Write-Status "Building frontend container only..."
    docker-compose -f docker-compose-multi.yml build litellm-frontend
} else {
    Write-Status "Building all containers..."
    docker-compose -f docker-compose-multi.yml build --no-cache
}

Write-Status "Starting containers..."
if ($BackendOnly) {
    docker-compose -f docker-compose-multi.yml up -d litellm-backend
} elseif ($FrontendOnly) {
    docker-compose -f docker-compose-multi.yml up -d litellm-frontend
} else {
    docker-compose -f docker-compose-multi.yml up -d
}

Write-Status "Waiting for containers to start (30 seconds)..."
Start-Sleep -Seconds 30

Write-Status "Checking container status..."
$containers = docker-compose -f docker-compose-multi.yml ps --format json | ConvertFrom-Json
$allRunning = $true

foreach ($container in $containers) {
    if ($container.State -eq "Up") {
        Write-Success "$($container.Service) is running"
    } else {
        Write-Error "$($container.Service) failed to start"
        $allRunning = $false
    }
}

if (-not $allRunning) {
    Write-Status "Container logs:"
    docker-compose -f docker-compose-multi.yml logs
    exit 1
}

if (-not $SkipHealthCheck) {
    Write-Status "Testing health endpoints..."
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:4000/health" -TimeoutSec 10 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Success "Backend health endpoint is responding!"
        }
    } catch {
        Write-Warning "Backend health endpoint not responding yet"
    }
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000" -TimeoutSec 10 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Success "Frontend is responding!"
        }
    } catch {
        Write-Warning "Frontend not responding yet (may still be starting)"
    }
}

Write-Host ""
Write-Success "Multi-Container LiteLLM is running successfully!"
Write-Host ""
Write-Host "📋 Service Information:" -ForegroundColor Cyan
Write-Host "   Backend API: http://localhost:4000" -ForegroundColor White
Write-Host "   Frontend UI: http://localhost:3000" -ForegroundColor White
Write-Host "   Backend Health: http://localhost:4000/health" -ForegroundColor White
Write-Host "   Models: http://localhost:4000/models" -ForegroundColor White
Write-Host ""
Write-Host "🔧 Useful Commands:" -ForegroundColor Cyan
Write-Host "   View all logs: docker-compose -f docker-compose-multi.yml logs -f" -ForegroundColor White
Write-Host "   View backend logs: docker-compose -f docker-compose-multi.yml logs -f litellm-backend" -ForegroundColor White
Write-Host "   View frontend logs: docker-compose -f docker-compose-multi.yml logs -f litellm-frontend" -ForegroundColor White
Write-Host "   Stop all: docker-compose -f docker-compose-multi.yml down" -ForegroundColor White
Write-Host "   Restart backend: docker-compose -f docker-compose-multi.yml restart litellm-backend" -ForegroundColor White
Write-Host "   Restart frontend: docker-compose -f docker-compose-multi.yml restart litellm-frontend" -ForegroundColor White
Write-Host ""
Write-Host "🔄 Development Workflow:" -ForegroundColor Cyan
Write-Host "   • Modify frontend code in ./frontend/src/ - changes auto-reload" -ForegroundColor White
Write-Host "   • Backend changes require container restart" -ForegroundColor White
Write-Host "   • Use --BackendOnly or --FrontendOnly flags for selective builds" -ForegroundColor White
Write-Host ""
Write-Success "Setup complete! 🎉" 