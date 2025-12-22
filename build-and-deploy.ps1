# build-and-deploy.ps1
# PowerShell script to build and deploy the LearningWeb application to your server

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "LearningWeb Deployment Script" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$IMAGE_NAME = "learningweb"
$CONTAINER_NAME = "learningweb-app"
$TAG = "latest"
$PORT = 5000

# Step 1: Stop and remove existing container (if exists)
Write-Host "Step 1: Stopping existing container..." -ForegroundColor Yellow
docker stop $CONTAINER_NAME 2>$null
docker rm $CONTAINER_NAME 2>$null
Write-Host "? Existing container removed" -ForegroundColor Green
Write-Host ""

# Step 2: Build the Docker image
Write-Host "Step 2: Building Docker image..." -ForegroundColor Yellow
docker build -t "${IMAGE_NAME}:${TAG}" .
if ($LASTEXITCODE -ne 0) {
    Write-Host "? Docker build failed!" -ForegroundColor Red
    exit 1
}
Write-Host "? Docker image built successfully" -ForegroundColor Green
Write-Host ""

# Step 3: Load environment variables from .env file if it exists
$envVars = @()
if (Test-Path ".env") {
    Write-Host "Loading environment variables from .env file..." -ForegroundColor Yellow
    Get-Content .env | ForEach-Object {
        if ($_ -match '^([^=]+)=(.*)$') {
            $envVars += "-e"
            $envVars += "$($matches[1])=$($matches[2])"
        }
    }
}

# Step 4: Run the container
Write-Host "Step 3: Starting container..." -ForegroundColor Yellow
$dockerArgs = @(
    "run", "-d",
    "--name", $CONTAINER_NAME,
    "-p", "${PORT}:8080",
    "-e", "ASPNETCORE_ENVIRONMENT=Production",
    "--restart", "unless-stopped",
    "-v", "learningweb-images:/app/wwwroot/images/product"
)

# Add environment variables
$dockerArgs += $envVars

# Add image name
$dockerArgs += "${IMAGE_NAME}:${TAG}"

# Run docker command
& docker $dockerArgs

if ($LASTEXITCODE -ne 0) {
    Write-Host "? Container failed to start!" -ForegroundColor Red
    exit 1
}
Write-Host "? Container started successfully" -ForegroundColor Green
Write-Host ""

# Step 5: Show container status
Write-Host "Step 4: Container status..." -ForegroundColor Yellow
docker ps --filter "name=$CONTAINER_NAME"
Write-Host ""

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Deployment completed successfully!" -ForegroundColor Green
Write-Host "Application is running at: http://localhost:$PORT" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Useful commands:" -ForegroundColor Yellow
Write-Host "  View logs:     docker logs -f $CONTAINER_NAME"
Write-Host "  Stop app:      docker stop $CONTAINER_NAME"
Write-Host "  Restart app:   docker restart $CONTAINER_NAME"
Write-Host "  Remove app:    docker rm -f $CONTAINER_NAME"
