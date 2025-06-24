# LiteLLM Offline Setup

This repository contains everything needed to run LiteLLM Proxy completely offline using a pre-built base image.

## 📁 File Structure

```
LiteLLM-DockerTest/
├── Dockerfile                 # Dockerfile for building final image
├── docker-compose.yml         # Docker Compose configuration
├── test_health.py            # Python script to test health endpoints
├── start_litellm.sh          # Automated setup and health check script
├── README.md                 # This file
└── litellm-main/
    └── litellm-base1.tar     # Offline base image (355MB)
```

## 🚀 Quick Start

### Option 1: Automated Setup (Recommended)
```bash
# Make the script executable and run it
chmod +x start_litellm.sh
./start_litellm.sh
```

### Option 2: Manual Setup

#### Step 1: Load the Base Image
```bash
docker load -i litellm-main/litellm-base1.tar
```

#### Step 2: Build and Start the Container
```bash
# Build the final image
docker-compose build

# Start the container
docker-compose up -d
```

#### Step 3: Test the Health Endpoint
```bash
# Wait for container to start (30-60 seconds)
sleep 30

# Test health endpoint
curl http://localhost:4000/health

# Or use the Python script
python3 test_health.py
```

## 🔧 Manual Commands

### Build the Image
```bash
docker-compose build --no-cache
```

### Start the Service
```bash
docker-compose up -d
```

### Check Container Status
```bash
docker-compose ps
```

### View Logs
```bash
# View all logs
docker-compose logs

# Follow logs in real-time
docker-compose logs -f

# View recent logs
docker-compose logs --tail=50
```

### Stop the Service
```bash
docker-compose down
```

### Restart the Service
```bash
docker-compose restart
```

## 🏥 Health Check Endpoints

Once the service is running, you can test these endpoints:

- **Health Check**: `http://localhost:4000/health`
- **Liveliness**: `http://localhost:4000/health/liveliness`
- **Readiness**: `http://localhost:4000/health/readiness`
- **Models**: `http://localhost:4000/models`

### Testing with curl
```bash
# Basic health check
curl http://localhost:4000/health

# Check models
curl http://localhost:4000/models

# Check with pretty JSON output (if jq is installed)
curl -s http://localhost:4000/health | jq .
```

### Testing with Python
```bash
python3 test_health.py
```

## 🔍 Troubleshooting

### Container Won't Start
1. Check if port 4000 is already in use:
   ```bash
   netstat -tulpn | grep :4000
   ```

2. Check Docker logs:
   ```bash
   docker-compose logs
   ```

3. Ensure the base image is loaded:
   ```bash
   docker images | grep litellm-base1
   ```

### Health Endpoint Not Responding
1. Wait longer for the container to fully start (up to 60 seconds)
2. Check if the container is running:
   ```bash
   docker-compose ps
   ```
3. Check container logs for errors:
   ```bash
   docker-compose logs --tail=20
   ```

### Permission Issues (Linux/Mac)
If you get permission errors with the shell script:
```bash
chmod +x start_litellm.sh
```

## 📋 Environment Variables

The following environment variables are set in the Docker Compose file:

- `STORE_MODEL_IN_DB=False` - Disable database storage
- `TELEMETRY=False` - Disable telemetry
- `PORT=4000` - Set the port to 4000

## 🐳 Docker Commands Reference

### Container Management
```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Stop a specific container
docker stop <container_name>

# Remove a container
docker rm <container_name>

# Execute commands in running container
docker exec -it <container_name> sh
```

### Image Management
```bash
# List images
docker images

# Remove an image
docker rmi <image_name>

# Save an image to tar file
docker save <image_name> > image.tar

# Load an image from tar file
docker load < image.tar
```

## 🎯 Expected Output

When everything is working correctly, you should see:

1. **Container Status**: `Up` in `docker-compose ps`
2. **Health Endpoint**: JSON response from `http://localhost:4000/health`
3. **Models Endpoint**: List of available models from `http://localhost:4000/models`

## 📞 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review the container logs: `docker-compose logs`
3. Ensure Docker and Docker Compose are properly installed
4. Verify the base image was loaded correctly

## 🔄 Updates

To update the setup:

1. Stop the current service: `docker-compose down`
2. Remove old images: `docker rmi litellm-base1:latest`
3. Load the new base image: `docker load -i litellm-main/litellm-base1.tar`
4. Rebuild and start: `docker-compose build && docker-compose up -d` 