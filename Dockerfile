# Multi-stage build: Frontend + Backend
FROM node:18-alpine AS frontend-build
WORKDIR /app

# Copy all frontend files for build
COPY frontend/ ./
RUN npm install && npm run build

FROM python:3.11-slim
WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    supervisor \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend code
COPY backend/ .

# Copy built frontend for static serving
COPY --from=frontend-build /app/dist ./frontend-dist

# Copy frontend source for dev server
COPY frontend/ ./frontend/
WORKDIR /app/frontend
RUN npm install

# Copy supervisord config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Expose ports
EXPOSE 8000 3000

# Start both services with supervisor
CMD ["supervisord", "-n"]
