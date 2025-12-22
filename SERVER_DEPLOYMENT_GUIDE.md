# SERVER DEPLOYMENT GUIDE
# LearningWeb E-Commerce Application

## Prerequisites

Before deploying to your server, ensure you have:

1. **Docker installed** on your server
   - For Ubuntu/Debian: `sudo apt-get update && sudo apt-get install docker.io docker-compose`
   - For Windows Server: Install Docker Desktop or Docker Engine
   - For CentOS/RHEL: `sudo yum install docker docker-compose`

2. **Server Requirements**
   - Minimum 2GB RAM (4GB recommended)
   - 10GB free disk space
   - Open ports: 80 (HTTP), 443 (HTTPS), 1433 (SQL Server if using external DB)

3. **Database Server**
   - SQL Server instance (local or remote)
   - Database created and connection string ready

## Deployment Methods

### Method 1: Standalone Docker Container (Recommended for existing database)

Use this method if you have an existing SQL Server database.

#### Step 1: Transfer Files to Server

Transfer your entire project directory to your server using SCP, FTP, or Git:

```bash
# Using SCP (from your local machine)
scp -r /path/to/Learning/ user@your-server-ip:/home/user/learningweb/

# Or using Git (on server)
git clone your-repository-url /home/user/learningweb/
```

#### Step 2: Configure Environment Variables

Create a `.env` file on your server:

```bash
cd /home/user/learningweb/
nano .env
```

Add your configuration:

```env
ASPNETCORE_ENVIRONMENT=Production
ConnectionStrings__DefaultConnection=Server=your-sql-server;Database=db_learning3;User Id=sa;Password=YourPassword;TrustServerCertificate=True
Stripe__SecretKey=your_stripe_secret_key
Stripe__PublishableKey=your_stripe_publishable_key
SendGrid__SecretKey=your_sendgrid_key
```

#### Step 3: Build and Deploy

**On Linux/Mac:**
```bash
chmod +x build-and-deploy.sh
./build-and-deploy.sh
```

**On Windows Server (PowerShell):**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\build-and-deploy.ps1
```

**Or manually:**
```bash
# Build the image
docker build -t learningweb:latest .

# Run the container
docker run -d \
    --name learningweb-app \
    -p 80:8080 \
    --env-file .env \
    --restart unless-stopped \
    -v learningweb-images:/app/wwwroot/images/product \
    learningweb:latest
```

### Method 2: Docker Compose (Includes SQL Server)

Use this method if you want Docker to manage both the application and database.

#### Step 1: Configure docker-compose.yml

Edit the existing `docker-compose.yml` file and update the SQL Server password and environment variables.

#### Step 2: Deploy with Docker Compose

```bash
# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

## Post-Deployment Configuration

### 1. Verify Deployment

Check if the container is running:
```bash
docker ps
```

Check application logs:
```bash
docker logs -f learningweb-app
```

### 2. Test the Application

Access your application:
- Local: http://localhost
- Remote: http://your-server-ip

### 3. Configure Reverse Proxy (Nginx) - Recommended

Install Nginx on your server:
```bash
sudo apt-get install nginx
```

Create Nginx configuration:
```bash
sudo nano /etc/nginx/sites-available/learningweb
```

Add this configuration:
```nginx
server {
    listen 80;
    server_name your-domain.com www.your-domain.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection keep-alive;
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        client_max_body_size 10M;
    }
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/learningweb /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

### 4. Setup SSL with Let's Encrypt (HTTPS)

```bash
# Install Certbot
sudo apt-get install certbot python3-certbot-nginx

# Obtain SSL certificate
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Auto-renewal is automatically configured
```

## Database Migration

If you need to run database migrations:

```bash
# Connect to the running container
docker exec -it learningweb-app bash

# Run migrations
dotnet ef database update

# Exit container
exit
```

## Updating the Application

### Option 1: Rolling Update

```bash
# Pull latest code (if using Git)
git pull origin main

# Rebuild and redeploy
docker stop learningweb-app
docker rm learningweb-app
docker build -t learningweb:latest .
docker run -d \
    --name learningweb-app \
    -p 80:8080 \
    --env-file .env \
    --restart unless-stopped \
    -v learningweb-images:/app/wwwroot/images/product \
    learningweb:latest
```

### Option 2: Zero-Downtime Update (Blue-Green Deployment)

```bash
# Build new version
docker build -t learningweb:v2 .

# Start new container on different port
docker run -d \
    --name learningweb-app-v2 \
    -p 8081:8080 \
    --env-file .env \
    --restart unless-stopped \
    -v learningweb-images:/app/wwwroot/images/product \
    learningweb:v2

# Update Nginx to point to new container
# Then remove old container
docker stop learningweb-app
docker rm learningweb-app
```

## Monitoring and Maintenance

### View Application Logs
```bash
docker logs -f learningweb-app
```

### Check Container Stats
```bash
docker stats learningweb-app
```

### Backup Database
```bash
# If using Docker Compose with SQL Server
docker exec learning-sqlserver /opt/mssql-tools/bin/sqlcmd \
    -S localhost -U sa -P 'YourPassword' \
    -Q "BACKUP DATABASE [db_learning3] TO DISK = '/var/opt/mssql/backup/db_learning3.bak'"

# Copy backup to host
docker cp learning-sqlserver:/var/opt/mssql/backup/db_learning3.bak ./backups/
```

### Backup Uploaded Images
```bash
# Create backup of volume
docker run --rm -v learningweb-images:/data -v $(pwd)/backups:/backup \
    alpine tar czf /backup/images-backup-$(date +%Y%m%d).tar.gz -C /data .
```

## Troubleshooting

### Container won't start
```bash
# Check logs
docker logs learningweb-app

# Check if port is already in use
sudo netstat -tulpn | grep :80

# Inspect container
docker inspect learningweb-app
```

### Database connection issues
```bash
# Test SQL Server connection from container
docker exec -it learningweb-app bash
apt-get update && apt-get install -y telnet
telnet your-sql-server 1433
```

### Permission issues with uploaded files
```bash
# Fix volume permissions
docker exec -it learningweb-app bash
chmod -R 755 /app/wwwroot/images/product
```

### Application is slow
```bash
# Check resource usage
docker stats

# Increase container resources (if using Docker Compose)
# Add to docker-compose.yml under service:
#   deploy:
#     resources:
#       limits:
#         cpus: '2'
#         memory: 2G
```

## Security Best Practices

1. **Use secrets management** - Don't commit `.env` file to Git
2. **Enable firewall** - Only open necessary ports
   ```bash
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw enable
   ```
3. **Regular updates** - Keep Docker and base images updated
   ```bash
   docker pull mcr.microsoft.com/dotnet/aspnet:8.0
   ```
4. **Monitor logs** - Set up log aggregation (ELK stack, Grafana, etc.)
5. **Backup regularly** - Automate database and file backups
6. **Use HTTPS** - Always use SSL certificates in production

## Performance Optimization

1. **Enable Response Compression** - Already configured in ASP.NET Core
2. **Use CDN** - For static files (wwwroot/images)
3. **Database Indexing** - Ensure proper indexes on frequently queried tables
4. **Caching** - Redis for distributed caching
5. **Load Balancing** - Use multiple containers behind a load balancer for high traffic

## Scaling Horizontally

To run multiple instances:

```bash
# Start multiple containers
docker run -d --name learningweb-app-1 -p 8081:8080 --env-file .env learningweb:latest
docker run -d --name learningweb-app-2 -p 8082:8080 --env-file .env learningweb:latest
docker run -d --name learningweb-app-3 -p 8083:8080 --env-file .env learningweb:latest

# Configure Nginx as load balancer
upstream learningweb_backend {
    server localhost:8081;
    server localhost:8082;
    server localhost:8083;
}
```

## Support Commands Quick Reference

```bash
# Build
docker build -t learningweb:latest .

# Run
docker run -d --name learningweb-app -p 80:8080 --env-file .env learningweb:latest

# Stop
docker stop learningweb-app

# Start
docker start learningweb-app

# Restart
docker restart learningweb-app

# Remove
docker rm -f learningweb-app

# Logs
docker logs -f learningweb-app

# Execute commands in container
docker exec -it learningweb-app bash

# View all containers
docker ps -a

# View images
docker images

# Clean up unused images
docker image prune -a

# Clean up unused volumes
docker volume prune
```

## Automated Deployment with CI/CD

For automated deployments, consider setting up:
- **GitHub Actions** - Build and push to Docker Hub
- **GitLab CI/CD** - Automated testing and deployment
- **Jenkins** - Traditional CI/CD pipeline

Example GitHub Actions workflow available in `.github/workflows/deploy.yml`

---

**Need Help?** Check Docker logs first, then review this guide for troubleshooting steps.
