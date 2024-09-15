#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Set variables
AWS_REGION="ap-southeast-2"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REPOSITORY_NAME="computervision-basic"
IMAGE_NAME="image-processor"

#get files for dockerbuild

aws s3 cp s3://video-processing-484673417484/docker/yolov8n.pt .
aws s3 cp s3://video-processing-484673417484/docker/processvideo.py .
aws s3 cp s3://video-processing-484673417484/docker/Dockerfile .

# Authenticate Docker with ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build Docker image
docker build -t $IMAGE_NAME .

# Tag Docker image
docker tag $IMAGE_NAME:latest $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPOSITORY_NAME:latest

# Push Docker image to ECR
docker push $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPOSITORY_NAME:latest

echo "Docker image successfully pushed to ECR $ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPOSITORY_NAME:latest"