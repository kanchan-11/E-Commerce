# QUICK START GUIDE - Server Deployment

## ?? Deploy in 5 Minutes

### Prerequisites
- Docker installed on your server
- SQL Server database accessible from server
- Your connection string, Stripe keys, and SendGrid key ready

### Step 1: Transfer Files
Transfer your project to the server:
```bash
# Option A: Using Git (recommended)
git clone <your-repo-url> /home/user/learningweb
cd /home/user/learningweb

# Option B: Using SCP
scp -r ./Learning user@server-ip:/home/user/learningweb
```

### Step 2: Configure Environment
Create `.env` file:
```bash
nano .env
```

Add your configuration (copy from `.env.example` and update):
```env
ASPNETCORE_ENVIRONMENT=Production
ConnectionStrings__DefaultConnection=Server=your-sql-server;Database=db_learning3;User Id=sa;Password=YourPassword;TrustServerCertificate=True
STRIPE_SECRET_KEY=your_stripe_secret_key
STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key
SENDGRID_SECRET_KEY=your_sendgrid_key
```

### Step 3: Deploy

**Option A: Using the deployment script (Recommended)**
```bash
# Linux/Mac
chmod +x build-and-deploy.sh
./build-and-deploy.sh

# Windows PowerShell
.\build-and-deploy.ps1
```

**Option B: Manual Docker commands**
```bash
# Build
docker build -t learningweb:latest .

# Run
docker run -d \
    --name learningweb-app \
    -p 80:8080 \
    --env-file .env \
    --restart unless-stopped \
    -v learningweb-images:/app/wwwroot/images/product \
    learningweb:latest
```

**Option C: Using Docker Compose (includes SQL Server)**
```bash
docker-compose up -d
```

### Step 4: Verify
Check if it's running:
```bash
docker ps
curl http://localhost
```

View logs:
```bash
docker logs -f learningweb-app
```

### Step 5: Access Your Application
- Local: http://localhost
- Remote: http://your-server-ip
- With domain: http://your-domain.com (after DNS setup)

---

## ?? Common Issues

**Container won't start?**
```bash
docker logs learningweb-app
```

**Database connection failed?**
- Check your connection string in `.env`
- Ensure SQL Server is accessible from the server
- Test connection: `telnet your-sql-server 1433`

**Port already in use?**
```bash
# Check what's using port 80
sudo netstat -tulpn | grep :80

# Use different port
docker run -d --name learningweb-app -p 8080:8080 --env-file .env learningweb:latest
```

---

## ?? Essential Commands

```bash
# View logs
docker logs -f learningweb-app

# Restart
docker restart learningweb-app

# Stop
docker stop learningweb-app

# Remove
docker rm -f learningweb-app

# Update application
docker stop learningweb-app
docker rm learningweb-app
docker build -t learningweb:latest .
docker run -d --name learningweb-app -p 80:8080 --env-file .env learningweb:latest
```

---

## ?? Production Setup (Recommended)

### Enable HTTPS with Nginx
```bash
# Install Nginx
sudo apt-get install nginx certbot python3-certbot-nginx

# Configure Nginx (create /etc/nginx/sites-available/learningweb)
server {
    listen 80;
    server_name your-domain.com;
    location / {
        proxy_pass http://localhost:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}

# Enable site
sudo ln -s /etc/nginx/sites-available/learningweb /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Get SSL certificate
sudo certbot --nginx -d your-domain.com
```

### Setup Firewall
```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

---

## ?? Need More Help?
- Full deployment guide: `SERVER_DEPLOYMENT_GUIDE.md`
- Docker reference: `DOCKER_DEPLOYMENT.md`
- Troubleshooting: Check logs first with `docker logs -f learningweb-app`

---

**That's it! Your application should now be running on your server. ??**
