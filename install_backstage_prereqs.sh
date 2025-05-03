#!/bin/bash
set -e

# Update package lists
echo "Updating package lists..."
sudo apt-get update

# Install curl and other required system packages
echo "Installing system dependencies..."
sudo apt-get install -y curl git build-essential

# Install Node.js v18
echo "Installing Node.js v18..."
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify Node.js installation
echo "Node.js version:"
node --version

# Install Yarn
echo "Installing Yarn package manager..."
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get update
sudo apt-get install -y yarn

# Verify Yarn installation
echo "Yarn version:"
yarn --version

# Install Docker (optional for local development)
echo "Installing Docker..."
sudo apt-get install -y apt-transport-https ca-certificates gnupg software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Verify Docker installation
echo "Docker version:"
docker --version

# Install Docker Compose (useful for Backstage development)
echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/download/v2.19.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify Docker Compose installation
echo "Docker Compose version:"
docker-compose --version

# Add current user to docker group to avoid using sudo with docker
sudo usermod -aG docker $USER
echo "Added current user to the docker group. You may need to log out and back in for this to take effect."

echo "All Backstage prerequisites have been installed successfully!"
echo "Please log out and back in, or restart your system, for all changes to take effect."