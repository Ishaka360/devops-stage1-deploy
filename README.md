Automated Deployment Bash Script

Overview

This repository contains a production-grade Bash script (deploy.sh) that automates the setup, deployment, and configuration of a Dockerized application on a remote Linux server. The script is idempotent, includes logging, error handling, and sets up Nginx as a reverse proxy for your application.

The script was built to meet the DevOps Intern Stage 1 Task requirements and mirrors real-world deployment workflows.

### Run Locally
```bash
docker build -t devops-app .
docker run -p 80:5000 devops-app
