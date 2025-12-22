#!/bin/bash
# build-and-deploy.sh
# Script to build and deploy the LearningWeb application to your server

echo "========================================="
echo "LearningWeb Deployment Script"
echo "========================================="
echo ""

# Configuration
IMAGE_NAME="learningweb"
CONTAINER_NAME="learningweb-app"
TAG="latest"
PORT=5000

# Step 1: Stop and remove existing container (if exists)
echo "Step 1: Stopping existing container..."
docker stop $CONTAINER_NAME 2>/dev/null || true
docker rm $CONTAINER_NAME 2>/dev/null || true
echo "? Existing container removed"
echo ""

# Step 2: Build the Docker image
echo "Step 2: Building Docker image..."
docker build -t $IMAGE_NAME:$TAG .
if [ $? -ne 0 ]; then
    echo "? Docker build failed!"
    exit 1
fi
echo "? Docker image built successfully"
echo ""

# Step 3: Run the container
echo "Step 3: Starting container..."
docker run -d \
    --name $CONTAINER_NAME \
    -p $PORT:8080 \
    -e ASPNETCORE_ENVIRONMENT=Production \
    -e ConnectionStrings__DefaultConnection="$CONNECTION_STRING" \
    -e Stripe__SecretKey="$STRIPE_SECRET_KEY" \
    -e Stripe__PublishableKey="$STRIPE_PUBLISHABLE_KEY" \
    -e SendGrid__SecretKey="$SENDGRID_SECRET_KEY" \
    --restart unless-stopped \
    -v learningweb-images:/app/wwwroot/images/product \
    $IMAGE_NAME:$TAG

if [ $? -ne 0 ]; then
    echo "? Container failed to start!"
    exit 1
fi
echo "? Container started successfully"
echo ""

# Step 4: Show container status
echo "Step 4: Container status..."
docker ps --filter name=$CONTAINER_NAME
echo ""

echo "========================================="
echo "Deployment completed successfully!"
echo "Application is running at: http://localhost:$PORT"
echo "========================================="
echo ""
echo "Useful commands:"
echo "  View logs:     docker logs -f $CONTAINER_NAME"
echo "  Stop app:      docker stop $CONTAINER_NAME"
echo "  Restart app:   docker restart $CONTAINER_NAME"
echo "  Remove app:    docker rm -f $CONTAINER_NAME"
