# Docker Setup Guide

This project uses a **unified Docker container** that runs both frontend and backend services together.

## Architecture

**Single Container with Supervisor:**
- **Frontend**: React app served by Nginx on port **3000**
- **Backend**: FastAPI application on port **8000**
- **Supervisor**: Manages both Nginx and Uvicorn processes

**External Services (via docker-compose):**
- **PostgreSQL**: Database on port **5432**
- **Redis**: Cache on port **6379**

## Quick Start

### Option 1: Single Container (Standalone)

```bash
# Build the unified image
docker build -t ai-sales-agent:latest .

# Run with both ports exposed
docker run -d \
  -p 3000:3000 \
  -p 8000:8000 \
  --env-file backend/.env \
  --name ai-sales-app \
  ai-sales-agent:latest

# View logs
docker logs -f ai-sales-app

# Stop the container
docker stop ai-sales-app
docker rm ai-sales-app
```

### Option 2: Using Docker Compose (Recommended - includes database)

```bash
# Build and start all services (app + database + redis)
docker-compose up --build

# Start in detached mode (background)
docker-compose up -d

# Stop all services
docker-compose down

# Stop and remove volumes (clean slate)
docker-compose down -v
```

## Accessing the Application

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs

## Useful Commands

```bash
# View logs for all services
docker-compose logs -f

# View logs for specific service
docker-compose logs -f backend
docker-compose logs -f frontend

# Restart a specific service
docker-compose restart backend

# Rebuild a specific service
docker-compose up -d --build backend

# Execute commands in running container
docker-compose exec backend bash
docker-compose exec frontend sh

# Check running containers
docker-compose ps

# Remove all stopped containers
docker-compose rm
```

## Environment Variables

Make sure you have a `.env` file in the `backend/` directory with the required environment variables:

```env
DB_USER=postgres
DB_PASSWORD=postgres
DB_NAME=ai_sales_agent
REDIS_HOST=redis
REDIS_PORT=6379
# Add other required variables
```

## Troubleshooting

### Port Already in Use
```bash
# Check what's using the port
netstat -ano | findstr :3000
netstat -ano | findstr :8000

# Stop the process or change the port in docker-compose.yml
```

### Database Connection Issues
```bash
# Check if PostgreSQL is healthy
docker-compose ps postgres

# View PostgreSQL logs
docker-compose logs postgres
```

### Rebuild from Scratch
```bash
# Remove all containers, networks, and volumes
docker-compose down -v

# Remove all images
docker rmi ai-sales-frontend:latest ai-sales-backend:latest

# Rebuild everything
docker-compose up --build
```
