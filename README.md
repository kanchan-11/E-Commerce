# E-Commerce Application

A comprehensive full-stack e-commerce platform built with ASP.NET Core and Entity Framework Core, featuring product management, shopping cart functionality, order processing, and user authentication.

## Table of Contents

- [Overview](#overview)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Building the Application](#building-the-application)
- [Running the Application](#running-the-application)
- [Docker Deployment](#docker-deployment)
- [Database Setup](#database-setup)
- [Key Features](#key-features)
- [Configuration](#configuration)
- [Contributing](#contributing)

## Overview

This e-commerce application provides a complete solution for managing an online store, including:
- Product catalog with categories and images
- Shopping cart management
- Order processing and tracking
- User authentication and authorization
- Company management
- Payment integration with Stripe

## Technology Stack

- **Framework**: ASP.NET Core
- **Database**: Entity Framework Core with SQL Server
- **Authentication**: ASP.NET Core Identity
- **Payments**: Stripe Integration
- **Email**: SMTP-based email sender
- **Containerization**: Docker & Docker Compose
- **Version Control**: Git

## Project Structure

```
├── Learning.DataAccess/          # Database context and repositories
│   ├── Data/                     # Entity Framework configuration
│   ├── Migrations/               # Database migration files
│   └── Repository/               # Data access layer
├── Learning.Models/              # Domain models
│   └── ViewModels/               # View-specific models
├── Learning.Utility/             # Utility classes and helpers
├── LearningWeb/                  # ASP.NET Core web application
│   ├── Areas/                    # Feature areas
│   ├── Views/                    # Razor views
│   ├── wwwroot/                  # Static files
│   └── Program.cs                # Application startup configuration
└── Learning.sln                  # Solution file
```

## Prerequisites

- .NET SDK (version specified in solution)
- SQL Server or LocalDB
- Docker (optional, for containerized deployment)
- Node.js (if using npm for frontend dependencies)

## Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd E-Commerce
```

### 2. Restore NuGet Packages

```bash
dotnet restore
```

### 3. Configure Database Connection

Update `appsettings.json` or `appsettings.Development.json` in the LearningWeb project with your database connection string:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=.;Database=ECommerceDb;Trusted_Connection=true;"
  }
}
```

### 4. Apply Database Migrations

```bash
dotnet ef database update --project Learning.DataAccess --startup-project LearningWeb
```

## Building the Application

### Build using .NET CLI

```bash
dotnet build
```

### Build using provided scripts

Windows (PowerShell):
```powershell
.\build-and-deploy.ps1
```

Linux/macOS:
```bash
bash build-and-deploy.sh
```

## Running the Application

### Local Development

```bash
cd LearningWeb
dotnet run
```

The application will be available at `https://localhost:7000` (or the configured port).

### Using Docker Compose

```bash
docker-compose up -d
```

See [DOCKER_DEPLOYMENT.md](DOCKER_DEPLOYMENT.md) for detailed Docker setup instructions.

## Docker Deployment

The application includes Docker support for containerized deployment. Key files:

- `Dockerfile` - Container image definition
- `docker-compose.yml` - Multi-container orchestration
- `DOCKER_DEPLOYMENT.md` - Detailed deployment guide
- `DOCKER_README.md` - Docker-specific documentation

For deployment instructions, refer to the [Docker Deployment Guide](DOCKER_DEPLOYMENT.md).

## Database Setup

### Migrations

The project uses Entity Framework Core migrations for database versioning. Key migration files include:

- Category model and seeding
- Product catalog with images
- Shopping cart functionality
- Order management (headers and details)
- User identity tables
- Company management

### Database Initialization

The `DbInitializer` class handles initial database seeding and setup. It runs automatically on application startup.

## Key Features

### Product Management
- Categories and subcategories
- Product listing with images
- Image URL support

### Shopping Cart
- Add/remove products
- Quantity management
- Cart persistence

### Order Management
- Order creation and tracking
- Order details with line items
- Phone number capture

### User Management
- ASP.NET Core Identity integration
- User authentication and authorization
- Role-based access control
- Company association

### Payment Processing
- Stripe integration for payments
- Configurable payment settings

### Utilities
- Email notification system (SMTP)
- Centralized configuration (SD class)

## Configuration

### Application Settings

Key configuration settings in `appsettings.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": ""
  },
  "StripeSettings": {
    "SecretKey": "",
    "PublishableKey": ""
  },
  "EmailSettings": {
    "SmtpServer": "",
    "SmtpPort": 587,
    "SenderEmail": "",
    "SenderPassword": ""
  }
}
```

### Environment-Specific Settings

- `appsettings.Development.json` - Development configuration

## Deployment

Refer to the [Server Deployment Guide](SERVER_DEPLOYMENT_GUIDE.md) for production deployment instructions.

## Quick Start

For a quick start guide, see [QUICKSTART.md](QUICKSTART.md).

## Troubleshooting

### Docker File Upload Issues

See [DOCKER_FILE_UPLOAD_FIX.md](DOCKER_FILE_UPLOAD_FIX.md) for solutions to common Docker-related issues.

## Contributing

Contributions are welcome! Please follow these guidelines:

1. Create a feature branch (`git checkout -b feature/AmazingFeature`)
2. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
3. Push to the branch (`git push origin feature/AmazingFeature`)
4. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions, please create an issue in the repository.

---

**Last Updated**: December 2025
