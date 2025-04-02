#!/bin/bash
set -e

source .env

echo "=== Pushing Docker image ==="
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URL

# Build with explicit platform
docker build --platform linux/amd64 -t $ECR_URL:latest .
docker push $ECR_URL:latest

echo "=== Deploying ECS Service ==="
cd terraform
terraform init
terraform apply -var="ecr_url=$ECR_URL" -var="aws_region=$AWS_REGION" -auto-approve

echo "=== Deployment Complete ==="