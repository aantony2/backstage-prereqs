# Backstage Prereqs

1. Run install_wsl.ps1 script first
2. Once WSL enabled, from the Ubuntu shell, run the install_backstage_prereqs.sh script

Bash Installation Script - This script will:

Update package repositories
Install Git and build dependencies
Install Node.js v18 (required for Backstage)
Install Yarn package manager
Install Docker and Docker Compose (optional but useful for development)
Add your user to the Docker group for easier usage


Dockerfile - This builds an Ubuntu 22.04 container with:

Node.js v18
Yarn package manager
Git
Other build essentials
Sets up a working directory for Backstage development



To use the bash script:
bashchmod +x install_backstage_prerequisites.sh
./install_backstage_prerequisites.sh
To use the Dockerfile:
bashdocker build -t backstage-dev .
docker run -it -v $(pwd):/app backstage-dev
The Docker setup allows you to mount your local directory into the container, making it easy to develop your Backstage application with all prerequisites installed without affecting your host system.