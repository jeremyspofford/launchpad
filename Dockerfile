# Multi-stage Dockerfile for testing dotfiles installation

# Base stage with common dependencies
FROM ubuntu:24.04 AS base

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install basic dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    sudo \
    build-essential \
    software-properties-common \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Create a test user
RUN useradd -m -s /bin/bash -G sudo testuser && \
    echo "testuser:testuser" | chpasswd && \
    echo "testuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to test user
USER testuser
WORKDIR /home/testuser

# Test stage for minimal installation
FROM base AS test-minimal

# Copy dotfiles repository
COPY --chown=testuser:testuser . /home/testuser/dotfiles

# Set working directory
WORKDIR /home/testuser/dotfiles

# Make scripts executable
RUN chmod +x install.sh verify.sh

# Test minimal installation
RUN ./install.sh --minimal --yes --no-backup

# Run verification
RUN ./verify.sh --quick

# Test stage for full installation
FROM base AS test-full

# Copy dotfiles repository
COPY --chown=testuser:testuser . /home/testuser/dotfiles

# Set working directory
WORKDIR /home/testuser/dotfiles

# Make scripts executable
RUN chmod +x install.sh verify.sh

# Test full installation (excluding shell switch to avoid issues in container)
RUN ./install.sh --yes --no-backup

# Run full verification
RUN ./verify.sh

# Development stage for interactive testing
FROM base AS development

# Install additional development tools
RUN sudo apt-get update && sudo apt-get install -y \
    vim \
    nano \
    htop \
    tree \
    && sudo rm -rf /var/lib/apt/lists/*

# Copy dotfiles repository
COPY --chown=testuser:testuser . /home/testuser/dotfiles

# Set working directory
WORKDIR /home/testuser/dotfiles

# Make scripts executable
RUN chmod +x install.sh verify.sh

# Set up shell
ENV SHELL=/bin/bash

# Default command for interactive use
CMD ["/bin/bash"]

# Production stage (minimal size)
FROM ubuntu:24.04 AS production

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install only runtime dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zsh \
    && rm -rf /var/lib/apt/lists/*

# Create user
RUN useradd -m -s /bin/zsh user
USER user
WORKDIR /home/user

# Copy only necessary files
COPY --chown=user:user install.sh .
COPY --chown=user:user ansible/ ansible/
COPY --chown=user:user home/ home/
COPY --chown=user:user .chezmoi.toml .
COPY --chown=user:user .chezmoiroot .

# Run installation
RUN chmod +x install.sh && \
    ./install.sh --minimal --yes --no-backup

# Clean up
RUN rm -f install.log verification.log

# Set default shell
ENV SHELL=/bin/zsh
CMD ["/bin/zsh"]