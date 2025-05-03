FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set timezone to UTC
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime

# Update and install basic dependencies
RUN apt-get update && \
    apt-get install -y \
    curl \
    git \
    build-essential \
    gnupg \
    ca-certificates \
    apt-transport-https \
    lsb-release \
    software-properties-common \
    python3 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js v18
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y yarn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Verify installations
RUN node --version && \
    yarn --version && \
    git --version

# Set default command
CMD ["bash"]

# Usage instructions:
# 1. Build the image: docker build -t backstage-dev .
# 2. Run a container: docker run -it -v $(pwd):/app backstage-dev
# 3. Inside the container, you can create and develop your Backstage app