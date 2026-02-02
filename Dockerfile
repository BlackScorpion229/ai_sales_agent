# Multi-stage build: Frontend + Backend
FROM node:18-alpine AS frontend-build
WORKDIR /app

# Copy all frontend files for build
COPY frontend/ ./
RUN npm install && npm run build

FROM python:3.11-slim
WORKDIR /app

# Install Python dependencies
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend code
COPY backend/ .
COPY --from=frontend-build /app/dist ./static

# Install Node.js and supervisor for process management
RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Copy frontend source
COPY frontend/ ./frontend/
WORKDIR /app/frontend
RUN npm install

# Copy supervisord config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose ports
EXPOSE 8000 3000

# Start both services with supervisor
CMD ["supervisord", "-n"]
