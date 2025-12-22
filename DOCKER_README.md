# ?? DOCKER DEPLOYMENT FILES

This package contains everything you need to deploy your LearningWeb E-Commerce application to your server using Docker.

## ?? What's Included

### Core Docker Files
- **`Dockerfile`** - Multi-stage production-ready Docker image
- **`docker-compose.yml`** - Orchestration with SQL Server included
- **`.dockerignore`** - Optimized build configuration

### Deployment Scripts
- **`build-and-deploy.sh`** - Linux/Mac deployment script
- **`build-and-deploy.ps1`** - Windows PowerShell deployment script

### Configuration Files
- **`.env.example`** - Template for environment variables
- **`appsettings.Production.json`** - Production configuration template

### Documentation
- **`QUICKSTART.md`** - Get started in 5 minutes
- **`SERVER_DEPLOYMENT_GUIDE.md`** - Comprehensive deployment guide
- **`DOCKER_DEPLOYMENT.md`** - Docker-specific documentation

### CI/CD (Optional)
- **`.github/workflows/deploy.yml`** - GitHub Actions for automated deployment

---

## ?? Choose Your Deployment Method

### Method 1: Standalone Docker (Recommended)
**Best for:** Existing SQL Server database

```bash
# 1. Copy .env.example to .env and configure
cp .env.example .env
nano .env

# 2. Build and run
docker build -t learningweb:latest .
docker run -d --name learningweb-app -p 80:8080 --env-file .env learningweb:latest
```

**OR use the deployment script:**
```bash
./build-and-deploy.sh  # Linux/Mac
.\build-and-deploy.ps1 # Windows
```

### Method 2: Docker Compose
**Best for:** Fresh installation with SQL Server included

```bash
# Configure docker-compose.yml, then:
docker-compose up -d
```

---

## ?? Dockerfile Features

### Multi-Stage Build
? **Build stage** - Compiles the application with .NET SDK  
? **Publish stage** - Creates optimized release build  
? **Runtime stage** - Minimal ASP.NET Core runtime (smaller image)

### Security
? Non-root user execution  
? Minimal attack surface  
? No sensitive data in image

### Production Ready
? Health checks configured  
? Volume support for uploaded images  
? Proper logging and monitoring  
? Auto-restart on failure

### Optimizations
? Layer caching for faster builds  
? .dockerignore to exclude unnecessary files  
? Multi-architecture support  
? Compressed image size (~200MB runtime)

---

## ??? Image Architecture

```
Build Stage (mcr.microsoft.com/dotnet/sdk:8.0)
??? Restore NuGet packages
??? Build all projects
??? Publish release version
    ?
Runtime Stage (mcr.microsoft.com/dotnet/aspnet:8.0)
??? Copy published files
??? Setup directories & permissions
??? Configure health checks
??? Run as non-root user
```

---

## ?? Environment Variables

Configure these in your `.env` file:

```env
# Application
ASPNETCORE_ENVIRONMENT=Production
ASPNETCORE_URLS=http://+:8080

# Database
ConnectionStrings__DefaultConnection=Server=your-server;Database=db_learning3;...

# Stripe
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...

# SendGrid
SENDGRID_SECRET_KEY=SG....
```

---

## ?? Resource Requirements

### Minimum
- **CPU:** 1 core
- **RAM:** 512MB
- **Disk:** 2GB

### Recommended for Production
- **CPU:** 2+ cores
- **RAM:** 2GB+
- **Disk:** 10GB+ (for database and images)

---

## ?? Quick Commands Reference

```bash
# Build image
docker build -t learningweb:latest .

# Run container
docker run -d --name learningweb-app -p 80:8080 --env-file .env learningweb:latest

# View logs
docker logs -f learningweb-app

# Stop container
docker stop learningweb-app

# Start container
docker start learningweb-app

# Restart container
docker restart learningweb-app

# Remove container
docker rm -f learningweb-app

# Execute commands inside container
docker exec -it learningweb-app bash

# View container stats
docker stats learningweb-app

# Inspect container
docker inspect learningweb-app
```

---

## ?? Production Checklist

Before going live:

- [ ] Update all API keys in `.env`
- [ ] Configure production database connection
- [ ] Setup HTTPS with Nginx/reverse proxy
- [ ] Configure domain DNS
- [ ] Enable firewall (ports 80, 443)
- [ ] Setup SSL certificate (Let's Encrypt)
- [ ] Configure automated backups
- [ ] Setup monitoring/logging
- [ ] Test all functionality
- [ ] Configure email service (SendGrid)
- [ ] Setup Stripe production keys
- [ ] Review security settings

---

## ?? Security Best Practices

1. **Never commit `.env` file** to version control
2. **Change default passwords** in production
3. **Use Docker secrets** for sensitive data
4. **Keep base images updated** regularly
5. **Run as non-root user** (already configured)
6. **Enable firewall** on server
7. **Use HTTPS** in production
8. **Regular security audits** of dependencies

---

## ?? Troubleshooting

### Build fails?
```bash
# Check Docker is running
docker --version

# Clean build
docker build --no-cache -t learningweb:latest .
```

### Container won't start?
```bash
# Check logs
docker logs learningweb-app

# Check if port is in use
netstat -tulpn | grep :80
```

### Database connection fails?
```bash
# Test from container
docker exec -it learningweb-app bash
ping your-sql-server
```

### Permission issues?
```bash
# Fix volume permissions
docker exec -it learningweb-app bash
chmod -R 755 /app/wwwroot
```

---

## ?? Documentation Links

- **Quick Start:** `QUICKSTART.md` - Get running in 5 minutes
- **Full Guide:** `SERVER_DEPLOYMENT_GUIDE.md` - Comprehensive deployment
- **Docker Details:** `DOCKER_DEPLOYMENT.md` - Docker-specific info

---

## ?? Getting Help

1. **Check logs first:** `docker logs -f learningweb-app`
2. **Review documentation** in the guides
3. **Test locally** before deploying to server
4. **Check Docker status:** `docker ps -a`

---

## ?? Monitoring

### Check Application Health
```bash
curl http://localhost/health
```

### View Resource Usage
```bash
docker stats learningweb-app
```

### Export Metrics
```bash
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"
```

---

## ?? Updating the Application

```bash
# Pull latest changes
git pull

# Rebuild and redeploy
./build-and-deploy.sh
```

Or manually:
```bash
docker stop learningweb-app
docker rm learningweb-app
docker build -t learningweb:latest .
docker run -d --name learningweb-app -p 80:8080 --env-file .env learningweb:latest
```

---

## ?? Success!

Your LearningWeb E-Commerce application is now ready for Docker deployment!

**Next Steps:**
1. Read `QUICKSTART.md` for immediate deployment
2. Review `SERVER_DEPLOYMENT_GUIDE.md` for production setup
3. Configure your `.env` file with actual credentials
4. Deploy and test!

---

**Built with ?? for .NET 8 and Docker**
