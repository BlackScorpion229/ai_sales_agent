# ==========================================
# Stage 1: Build Frontend (Node.js)
# ==========================================
FROM node:18-alpine AS frontend-build
WORKDIR /app/frontend
COPY frontend/package.json frontend/package-lock.json* ./
RUN npm install
COPY frontend/ ./
RUN npm run build

# ==========================================
# Stage 2: Unified Server (Python + Nginx + Supervisor)
# ==========================================
FROM python:3.11-slim

WORKDIR /app

# Install System Dependencies: Nginx & Supervisor
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    nginx \
    supervisor \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy Backend Code
COPY backend/ .

# Copy Frontend Assets
COPY --from=frontend-build /app/frontend/dist /app/static

# ==========================================
# Configuration Setup
# ==========================================

# Configure Nginx (Port 3000)
RUN echo 'server { \
    listen 3000; \
    root /app/static; \
    index index.html; \
    \
    location /api/ { \
        proxy_pass http://127.0.0.1:8000; \
        proxy_http_version 1.1; \
        proxy_set_header Upgrade $http_upgrade; \
        proxy_set_header Connection "upgrade"; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; \
        proxy_set_header X-Forwarded-Proto $scheme; \
    } \
    \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/sites-available/default

# Configure Supervisor (Runs both apps)
RUN echo '[supervisord] \n\
nodaemon=true \n\
user=root \n\
\n\
[unix_http_server] \n\
file=/var/run/supervisor.sock \n\
chmod=0700 \n\
\n\
[supervisorctl] \n\
serverurl=unix:///var/run/supervisor.sock \n\
\n\
[rpcinterface:supervisor] \n\
supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface \n\
\n\
[program:backend] \n\
command=uvicorn app.main:app --host 0.0.0.0 --port 8000 \n\
stdout_logfile=/dev/stdout \n\
stdout_logfile_maxbytes=0 \n\
stderr_logfile=/dev/stderr \n\
stderr_logfile_maxbytes=0 \n\
\n\
[program:frontend] \n\
command=nginx -g "daemon off;" \n\
stdout_logfile=/dev/stdout \n\
stdout_logfile_maxbytes=0 \n\
stderr_logfile=/dev/stderr \n\
stderr_logfile_maxbytes=0 \n\
' > /etc/supervisor/conf.d/supervisord.conf

# Set environment variables
ENV PYTHONPATH=/app

# Expose Both Ports
EXPOSE 3000 8000

# Start Supervisor (which starts both Nginx & Uvicorn)
CMD ["/usr/bin/supervisord"]
