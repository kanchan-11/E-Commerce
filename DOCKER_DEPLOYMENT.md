# Docker Deployment for Learning E-Commerce App

This guide explains how to deploy the Learning E-Commerce application using Docker and Docker Compose.

## Prerequisites

- Docker Desktop installed on your machine
- Docker Compose (included with Docker Desktop)

## Quick Start

### 1. Setup Environment Variables

Copy the example environment file and update with your values:

```bash
cp .env.example .env
```

Edit `.env` file with your actual API keys and secrets.

### 2. Build and Run

Build and start all services:

```bash
docker-compose up -d
```

Or to build from scratch:

```bash
docker-compose up -d --build
```

### 3. Access the Application

- **Application**: http://localhost:5000
- **SQL Server**: localhost:1433
  - Username: `sa`
  - Password: `YourStrong@Password123` (or the value you set in docker-compose.yml)

## Docker Commands

### Start Services
```bash
docker-compose up -d
```

### Stop Services
```bash
docker-compose down
```

### Stop and Remove Volumes (WARNING: This deletes database data)
```bash
docker-compose down -v
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f learningweb
docker-compose logs -f sqlserver
```

### Rebuild Application
```bash
docker-compose up -d --build learningweb
```

### Check Service Status
```bash
docker-compose ps
```

## Configuration

### Database Connection

The application connects to SQL Server using:
- **Server**: `sqlserver` (Docker service name)
- **Database**: `db_learning3`
- **Authentication**: SQL Server Authentication
- **User**: `sa`
- **Password**: Set in docker-compose.yml

### Ports

- **Application**: 5000 (maps to container port 8080)
- **SQL Server**: 1433

### Environment Variables

The following environment variables can be configured in `docker-compose.yml`:

- `ConnectionStrings__DefaultConnection`: Database connection string
- `Stripe__SecretKey`: Stripe API secret key
- `Stripe__PublishableKey`: Stripe API publishable key
- `SendGrid__SecretKey`: SendGrid API key

## Volumes

- **sqlserver-data**: Persists SQL Server database files

## Troubleshooting

### SQL Server Not Ready

If the application fails to start, SQL Server might not be ready. Check logs:

```bash
docker-compose logs sqlserver
```

Wait for the message "SQL Server is now ready for client connections."

### Database Migration Issues

If you need to run migrations manually:

```bash
docker-compose exec learningweb dotnet ef database update
```

### Permission Issues (Linux/Mac)

If you encounter permission issues with SQL Server:

```bash
sudo chown -R 10001:0 /var/opt/mssql
```

### Reset Everything

To start fresh:

```bash
docker-compose down -v
docker-compose up -d --build
```

## Production Deployment

For production deployment:

1. **Update SQL Server Password**: Change the SA password in docker-compose.yml
2. **Use Secrets**: Store sensitive data in Docker secrets or environment variables
3. **Configure HTTPS**: Add SSL certificate configuration
4. **Update Connection String**: Point to production database
5. **Set Production Environment**: Ensure `ASPNETCORE_ENVIRONMENT=Production`
6. **Resource Limits**: Add memory and CPU limits to services
7. **Backup Strategy**: Implement database backup solution

### Example Production Configuration

Add to docker-compose.yml services:

```yaml
deploy:
  resources:
    limits:
      cpus: '2'
      memory: 2G
    reservations:
      cpus: '1'
      memory: 1G
```

## Architecture

The Docker setup includes:

1. **Multi-stage Dockerfile**: Optimized image size
   - Build stage: Compiles the application
   - Publish stage: Publishes release version
   - Runtime stage: Minimal runtime image

2. **Docker Compose**: Orchestrates services
   - SQL Server: Database service with health checks
   - LearningWeb: ASP.NET Core application
   - Network: Isolated bridge network for service communication
   - Volumes: Persistent storage for database

## Security Notes

- **Never commit `.env` file** to version control
- Change default passwords in production
- Use Docker secrets for sensitive data in production
- Keep API keys in environment variables
- Regularly update base images for security patches

## Support

For issues or questions, refer to:
- Docker documentation: https://docs.docker.com/
- ASP.NET Core Docker documentation: https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/docker/
