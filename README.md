# 🚀 Automated Flask App Deployment with Docker and Nginx on AWS EC2

This project demonstrates a fully automated deployment pipeline for a Flask web application using Docker, Nginx, and Bash scripting on an AWS EC2 instance. The setup ensures a smooth and repeatable deployment process that integrates containerization, reverse proxy configuration, and server management.

## Overview

The deployment script automatically builds the Docker image, runs the container, configures Nginx as a reverse proxy, and verifies that the Flask app is running successfully. It reduces manual server setup and provides an efficient way to deploy updates or new versions of the application.

## Tech Stack

The key technologies implemented in this project include:
- Docker for containerization
- Nginx as a reverse proxy and load balancer
- AWS EC2 for hosting the application
- Bash scripting for automation
- Python and Flask for the backend application

## Workflow Description

When the deployment script runs, it performs several automated tasks. It starts by cloning the Git repository that contains the application and Dockerfile. It then builds a Docker image, exposes the necessary ports, and launches a container on port 5000. Once the container is running, Nginx is configured to forward incoming HTTP requests on port 80 to the application running inside the Docker container.

The script also validates Nginx configuration syntax, restarts the Nginx service, and confirms that the Flask app is active and accessible via the public IP of the EC2 instance. This ensures a stable and production-ready environment for the web application.

## Achievements

This project highlights the integration of DevOps tools and cloud technologies to automate real-world deployment workflows. It showcases:
- Streamlined deployment processes with minimal human intervention
- Scalable and portable web app deployment using Docker containers
- Secure and efficient traffic handling through Nginx reverse proxy
- End-to-end automation using shell scripting

## How to Use

Clone this repository to your local environment and edit the `deploy.sh` file with your preferred configuration details such as Git repository URL, branch name, server username, IP address, and SSH key path. After setup, run the script to trigger the entire automated deployment process.

Example:
```bash
./deploy.sh
