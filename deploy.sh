#!/bin/bash

# =========================
# DevOps Stage 1 Deployment Script
# =========================

set -e  # Stop script on error

LOG_FILE="deploy_$(date +%Y%m%d).log"
echo "Starting deployment..." | tee -a $LOG_FILE

# 1️⃣ Collect Parameters
read -p "Enter Git repository URL: " GIT_URL
read -p "Enter Personal Access Token (PAT): " PAT
read -p "Enter branch name (default: main): " BRANCH
BRANCH=${BRANCH:-main}
read -p "Enter remote server username: " SSH_USER
read -p "Enter remote server IP address: " SERVER_IP
read -p "Enter SSH key path (e.g. ~/.ssh/id_rsa): " SSH_KEY
read -p "Enter internal container port: " APP_PORT

# Validate inputs
if [[ -z "$GIT_URL" || -z "$PAT" || -z "$SSH_USER" || -z "$SERVER_IP" || -z "$SSH_KEY" ]]; then
    echo "❌ Missing required input. Exiting..." | tee -a $LOG_FILE
    exit 1
fi

# 2️⃣ Clone or Update Repository
REPO_NAME=$(basename "$GIT_URL" .git)
if [ -d "$REPO_NAME" ]; then
    echo "Repository exists. Pulling latest changes..." | tee -a $LOG_FILE
    cd "$REPO_NAME" && git pull origin "$BRANCH"
else
    echo "Cloning repository..." | tee -a $LOG_FILE
    git clone -b "$BRANCH" "https://${PAT}@${GIT_URL#https://}" "$REPO_NAME"
    cd "$REPO_NAME"
fi

# Check for Dockerfile or docker-compose.yml
if [ ! -f "Dockerfile" ] && [ ! -f "docker-compose.yml" ]; then
    echo "❌ No Dockerfile or docker-compose.yml found." | tee -a ../$LOG_FILE
    exit 1
fi
echo "✅ Project ready for deployment." | tee -a ../$LOG_FILE

# 3️⃣ SSH into Remote Server and Prepare Environment
echo "Connecting to remote server..." | tee -a ../$LOG_FILE
ssh -i "$SSH_KEY" "$SSH_USER@$SERVER_IP" bash << EOF
set -e

# Update and install dependencies
sudo apt update -y
sudo apt install -y docker.io docker-compose nginx
sudo systemctl enable docker --now
sudo usermod -aG docker \$USER

echo "✅ Docker and Nginx installed successfully."

# Create app directory
cd /home/\$USER
if [ -d "$REPO_NAME" ]; then
    cd "$REPO_NAME" && git pull origin "$BRANCH"
else
    git clone -b "$BRANCH" "https://${PAT}@${GIT_URL#https://}" "$REPO_NAME"
    cd "$REPO_NAME"
fi

# Stop old containers
if [ -f "docker-compose.yml" ]; then
    sudo docker-compose down || true
    sudo docker-compose up -d --build
else
    sudo docker build -t ${REPO_NAME,,}:latest .
    sudo docker rm -f ${REPO_NAME,,} || true
    sudo docker run -d -p $APP_PORT:$APP_PORT --name ${REPO_NAME,,} ${REPO_NAME,,}:latest
fi

echo "✅ Docker container deployed successfully."

# Configure Nginx reverse proxy
NGINX_CONF="/etc/nginx/sites-available/${REPO_NAME}"
sudo bash -c "cat > \$NGINX_CONF" << NGINX_BLOCK
server {
    listen 80;
    server_name _;
    location / {
        proxy_pass http://localhost:$APP_PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
NGINX_BLOCK

sudo ln -sf \$NGINX_CONF /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
echo "✅ Nginx configured successfully."

EOF

echo "🎉 Deployment completed successfully!" | tee -a ../$LOG_FILE
