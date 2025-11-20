FROM quay.io/fedora/fedora:latest

# Update system packages and install basic tools
RUN dnf update -y && \
    dnf install -y iputils sudo ncurses

# Create dev user and set password
RUN useradd -m -u 1000 -s /bin/bash dev && \
    echo "dev:1234" | chpasswd && \
    echo "dev ALL=(ALL) ALL" >> /etc/sudoers

# Set working directory
WORKDIR /home/dev/

USER dev
