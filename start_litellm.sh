

set -e  

echo "🚀 LiteLLM Offline Setup and Health Check"
echo "=========================================="

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_status "Checking if base image exists..."
if ! docker image inspect litellm-base1:latest >/dev/null 2>&1; then
    print_error "Base image litellm-base1:latest not found!"
    print_status "Loading base image from tar file..."
    if [ -f "litellm-main/litellm-base1.tar" ]; then
        docker load -i litellm-main/litellm-base1.tar
        print_success "Base image loaded successfully"
    else
        print_error "litellm-base1.tar not found in litellm-main directory"
        exit 1
    fi
else
    print_success "Base image found"
fi

print_status "Stopping any existing containers..."
docker-compose down 2>/dev/null || true

print_status "Building final LiteLLM image..."
docker-compose build --no-cache

print_status "Starting LiteLLM proxy container..."
docker-compose up -d

print_status "Waiting for container to start (30 seconds)..."
sleep 30

print_status "Checking container status..."
if docker-compose ps | grep -q "Up"; then
    print_success "Container is running"
else
    print_error "Container failed to start"
    print_status "Container logs:"
    docker-compose logs
    exit 1
fi

print_status "Testing health endpoint..."
max_attempts=10
attempt=1

while [ $attempt -le $max_attempts ]; do
    print_status "Attempt $attempt/$max_attempts"
    
    if curl -f http://localhost:4000/health >/dev/null 2>&1; then
        print_success "Health endpoint is responding!"
        break
    else
        if [ $attempt -eq $max_attempts ]; then
            print_error "Health endpoint not responding after $max_attempts attempts"
            print_status "Container logs:"
            docker-compose logs --tail=20
            exit 1
        fi
        print_warning "Health endpoint not ready yet, waiting 10 seconds..."
        sleep 10
        attempt=$((attempt + 1))
    fi
done

print_status "Running comprehensive health check..."
if command -v python3 >/dev/null 2>&1; then
    python3 test_health.py
else
    print_warning "Python3 not found, using curl for basic health check"
    curl -s http://localhost:4000/health | jq . 2>/dev/null || curl -s http://localhost:4000/health
fi

echo ""
print_success "LiteLLM Proxy is running successfully!"
echo ""
echo "📋 Service Information:"
echo "   URL: http://localhost:4000"
echo "   Health: http://localhost:4000/health"
echo "   Models: http://localhost:4000/models"
echo ""
echo "🔧 Useful Commands:"
echo "   View logs: docker-compose logs -f"
echo "   Stop service: docker-compose down"
echo "   Restart service: docker-compose restart"
echo "   Check status: docker-compose ps"
echo ""
print_success "Setup complete! 🎉" 