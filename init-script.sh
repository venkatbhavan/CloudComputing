#!/bin/bash

set -e  # Exit on any error

# Log everything
exec > >(tee -a /var/log/init-script.log) 2>&1
echo "Starting init script at $(date)"

# Install system packages
echo "Installing system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y build-essential libssl-dev zlib1g-dev \
    libncurses5-dev libncursesw5-dev libreadline-dev \
    libsqlite3-dev libgdbm-dev libdb5.3-dev libbz2-dev \
    libexpat1-dev liblzma-dev tk-dev libffi-dev wget git curl

# Install Python 3.12.10
echo "Installing Python 3.12.10..."
cd /tmp
sudo wget https://www.python.org/ftp/python/3.12.10/Python-3.12.10.tgz
sudo tar -xvzf Python-3.12.10.tgz
cd Python-3.12.10
sudo ./configure --enable-optimizations
sudo make -j $(nproc)
sudo make altinstall

# Create symbolic links for easier access
sudo ln -sf /usr/local/bin/python3.12 /usr/local/bin/python3
sudo ln -sf /usr/local/bin/pip3.12 /usr/local/bin/pip3

# Verify Python installation
echo "Python version: $(python3 --version)"
echo "Pip version: $(pip3 --version)"

# Clone your GitHub repo
echo "Cloning GitHub repository..."
cd /home/azureuser
sudo -u azureuser git clone https://github.com/venkatbhavan/CloudComputing.git fastapiapp
cd fastapiapp
sudo chown -R azureuser:azureuser /home/azureuser/fastapiapp

# Install dependencies
echo "Installing Python dependencies..."
sudo -u azureuser pip3 install -r requirements.txt
sudo -u azureuser pip3 install gunicorn "uvicorn[standard]" python-dotenv

# Verify environment variables
echo "Checking environment variables..."
echo "CONNECTION_STRING: ${CONNECTION_STRING:-'Not set'}"
echo "CONTAINER_NAME: ${CONTAINER_NAME:-'Not set'}"
echo "BLOB_NAME: ${BLOB_NAME:-'Not set'}"

# Create .env file
echo "Creating .env file..."
sudo -u azureuser cat <<EOF > /home/azureuser/fastapiapp/.env
CONNECTION_STRING=${CONNECTION_STRING}
CONTAINER_NAME=${CONTAINER_NAME}
BLOB_NAME=${BLOB_NAME}
EOF

# Set proper permissions
sudo chown azureuser:azureuser /home/azureuser/fastapiapp/.env
sudo chmod 600 /home/azureuser/fastapiapp/.env

# Create systemd service for the FastAPI app
echo "Creating systemd service..."
sudo tee /etc/systemd/system/fastapiapp.service > /dev/null <<EOF
[Unit]
Description=FastAPI Application
After=network.target

[Service]
User=azureuser
Group=azureuser
WorkingDirectory=/home/azureuser/fastapiapp
Environment=PATH=/home/azureuser/.local/bin:/usr/local/bin:/usr/bin:/bin
EnvironmentFile=/home/azureuser/fastapiapp/.env
ExecStart=/usr/local/bin/gunicorn -w 2 -k uvicorn.workers.UvicornWorker -b 0.0.0.0:5000 main:app
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
echo "Starting FastAPI application service..."
sudo systemctl daemon-reload
sudo systemctl enable fastapiapp.service
sudo systemctl start fastapiapp.service

# Check service status
sleep 5
sudo systemctl status fastapiapp.service || true

echo "Init script completed successfully at $(date)"
echo "FastAPI app should be running on http://<server-ip>:5000"
