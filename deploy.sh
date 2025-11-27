#!/bin/bash

echo "Starting deployment..."

echo "Installing Docker..."
sudo yum update -y
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user

echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

echo "Starting services..."
docker-compose up -d --build

echo "Checking container status..."
docker ps

echo "Deployment complete!"
echo "Your API is available at: http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"

