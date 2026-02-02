# Multi-stage build: Frontend + Backend
FROM node:18-alpine AS frontend-build
WORKDIR /app
COPY frontend/package.json frontend/package-lock.json* ./
RUN npm install && npm run build

FROM python:3.11-slim
WORKDIR /app

# Install Python dependencies
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend code
COPY backend/ .
COPY --from=frontend-build /app/dist ./static

# Install Node.js for frontend dev server
RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Copy frontend source
COPY frontend/ ./frontend/
WORKDIR /app/frontend
RUN npm install

# Expose ports
EXPOSE 8000 3000

# Run both services
WORKDIR /app
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port 8000 & cd frontend && npm run dev -- --host 0.0.0.0 --port 3000"]
