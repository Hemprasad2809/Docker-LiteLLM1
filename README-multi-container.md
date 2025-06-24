# LiteLLM Multi-Container Setup

This setup provides a **completely offline** LiteLLM deployment with separate containers for the Python backend and React frontend, allowing independent development and modification of each component.

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   React Frontend│    │  Python Backend │
│   (Port 3000)   │◄──►│  (Port 4000)    │
│                 │    │                 │
│ - Health Monitor│    │ - LiteLLM API   │
│ - Model Manager │    │ - Model Config  │
│ - API Explorer  │    │ - Health Checks │
└─────────────────┘    └─────────────────┘
```

## 📁 File Structure

```
LiteLLM-DockerTest/
├── docker-compose-multi.yml     # Multi-container orchestration
├── Dockerfile.backend           # Python backend container
├── Dockerfile.frontend          # React frontend container
├── config.yaml                  # LiteLLM configuration
├── start_multi_container.ps1    # Windows automation script
├── README-multi-container.md    # This file
├── frontend/                    # React application
│   ├── package.json
│   ├── public/
│   │   └── index.html
│   └── src/
│       ├── App.js
│       ├── App.css
│       ├── index.js
│       └── index.css
└── litellm-main/
    └── litellm-base1.tar        # Offline base image (355MB)
```

## 🚀 Quick Start

### Option 1: Automated Setup (Recommended)
```powershell
# Start both containers
./start_multi_container.ps1

# Start only backend
./start_multi_container.ps1 --BackendOnly

# Start only frontend
./start_multi_container.ps1 --FrontendOnly
```

### Option 2: Manual Setup
```bash
# Load base image
docker load -i litellm-main/litellm-base1.tar

# Build and start all containers
docker-compose -f docker-compose-multi.yml build
docker-compose -f docker-compose-multi.yml up -d

# Or build/start specific containers
docker-compose -f docker-compose-multi.yml build litellm-backend
docker-compose -f docker-compose-multi.yml up -d litellm-backend
```

## 🌐 Access Points

Once running, you can access:

- **Frontend Dashboard**: http://localhost:3000
- **Backend API**: http://localhost:4000
- **Health Check**: http://localhost:4000/health
- **Models List**: http://localhost:4000/models

## 🔧 Development Workflow

### Frontend Development (React)
The frontend container has **hot reload** enabled, so you can:

1. **Modify React code** in `./frontend/src/`
2. **See changes immediately** in the browser
3. **No container restart needed** for frontend changes

```bash
# Edit frontend files
code frontend/src/App.js

# Changes auto-reload in browser at http://localhost:3000
```

### Backend Development (Python)
For backend changes:

1. **Modify config.yaml** or backend code
2. **Rebuild and restart** the backend container

```bash
# Rebuild backend only
docker-compose -f docker-compose-multi.yml build litellm-backend
docker-compose -f docker-compose-multi.yml restart litellm-backend

# Or use the script
./start_multi_container.ps1 --BackendOnly
```

## 📊 Frontend Features

The React frontend provides:

- **Real-time Health Monitoring**: Live status of backend services
- **Model Management**: View and manage available models
- **API Explorer**: Quick access to API endpoints
- **Auto-refresh**: Updates every 30 seconds
- **Responsive Design**: Works on desktop and mobile

## 🔍 Container Management

### View Logs
```bash
# All containers
docker-compose -f docker-compose-multi.yml logs -f

# Specific container
docker-compose -f docker-compose-multi.yml logs -f litellm-backend
docker-compose -f docker-compose-multi.yml logs -f litellm-frontend
```

### Container Status
```bash
docker-compose -f docker-compose-multi.yml ps
```

### Stop/Start Containers
```bash
# Stop all
docker-compose -f docker-compose-multi.yml down

# Start all
docker-compose -f docker-compose-multi.yml up -d

# Restart specific container
docker-compose -f docker-compose-multi.yml restart litellm-backend
docker-compose -f docker-compose-multi.yml restart litellm-frontend
```

## 🛠️ Customization

### Adding New Models
Edit `config.yaml`:
```yaml
model_list:
  - model_name: your-model
    litellm_params:
      model: your-model-name
      api_key: your-api-key
      api_base: your-api-base
```

### Modifying Frontend
Edit files in `frontend/src/`:
- `App.js` - Main application logic
- `App.css` - Styling
- `index.css` - Global styles

### Environment Variables
Modify `docker-compose-multi.yml`:
```yaml
environment:
  - REACT_APP_API_URL=http://localhost:4000
  - STORE_MODEL_IN_DB=False
  - TELEMETRY=False
```

## 🔄 Development Scenarios

### Scenario 1: Frontend UI Changes
```bash
# 1. Edit frontend code
code frontend/src/App.js

# 2. Save file - changes auto-reload in browser
# 3. No container restart needed
```

### Scenario 2: Backend Configuration Changes
```bash
# 1. Edit config.yaml
code config.yaml

# 2. Rebuild and restart backend
./start_multi_container.ps1 --BackendOnly
```

### Scenario 3: Adding New Dependencies
```bash
# Frontend dependencies
cd frontend
npm install new-package
# Container will auto-reload

# Backend dependencies (requires rebuild)
# Edit Dockerfile.backend and rebuild
./start_multi_container.ps1 --BackendOnly
```

## 🐛 Troubleshooting

### Frontend Not Loading
1. Check if container is running: `docker-compose -f docker-compose-multi.yml ps`
2. Check frontend logs: `docker-compose -f docker-compose-multi.yml logs litellm-frontend`
3. Ensure port 3000 is not in use

### Backend Not Responding
1. Check backend logs: `docker-compose -f docker-compose-multi.yml logs litellm-backend`
2. Verify config.yaml is valid
3. Check if base image is loaded: `docker images | grep litellm-base1`

### Network Issues
1. Check if containers can communicate: `docker network ls`
2. Verify network configuration in docker-compose-multi.yml
3. Check if ports are not conflicting

## 📈 Benefits of Multi-Container Setup

1. **Independent Development**: Modify frontend without affecting backend
2. **Faster Iteration**: Frontend changes auto-reload
3. **Resource Isolation**: Each service runs in its own container
4. **Scalability**: Can scale frontend and backend independently
5. **Technology Flexibility**: Can easily swap frontend framework or backend language
6. **Team Development**: Different team members can work on different containers

## 🎯 Next Steps

1. **Customize the frontend** for your specific needs
2. **Add more models** to the config.yaml
3. **Implement authentication** if needed
4. **Add monitoring and logging** solutions
5. **Set up CI/CD** for automated deployments

## 📞 Support

For issues:
1. Check container logs
2. Verify all files are in correct locations
3. Ensure Docker and Docker Compose are properly installed
4. Check if the base image is loaded correctly 