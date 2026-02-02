# Quick Docker Commands

## Build the Image
```bash
docker build -t ai-sales-agent:latest .
```

## Run Single Container (Standalone)
```bash
# Run with both frontend (3000) and backend (8000)
docker run -d -p 3000:3000 -p 8000:8000 --env-file backend/.env --name ai-sales-app ai-sales-agent:latest

# View logs
docker logs -f ai-sales-app

# Stop and remove
docker stop ai-sales-app && docker rm ai-sales-app
```

## Run with Docker Compose (Includes Database + Redis)
```bash
# Start everything
docker-compose up -d

# View logs
docker-compose logs -f app

# Stop everything
docker-compose down
```

## Access the Application
- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/docs
