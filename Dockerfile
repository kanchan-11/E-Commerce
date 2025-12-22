# Dockerfile for LearningWeb E-Commerce Application
# Multi-stage build for optimized production deployment

# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy all project files for dependency restoration
COPY ["LearningWeb/LearningWeb.csproj", "LearningWeb/"]
COPY ["Learning.DataAccess/Learning.DataAccess.csproj", "Learning.DataAccess/"]
COPY ["Learning.Models/Learning.Models.csproj", "Learning.Models/"]
COPY ["Learning.Utility/Learning.Utility.csproj", "Learning.Utility/"]

# Restore dependencies
RUN dotnet restore "LearningWeb/LearningWeb.csproj"

# Copy all source code
COPY . .

# Build the application
WORKDIR "/src/LearningWeb"
RUN dotnet build "LearningWeb.csproj" -c Release -o /app/build

# Stage 2: Publish
FROM build AS publish
RUN dotnet publish "LearningWeb.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Stage 3: Runtime (Final stage - smallest image)
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app

# Install necessary tools for troubleshooting (optional - remove for smaller image)
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Create directory for uploaded images and set permissions
RUN mkdir -p /app/wwwroot/images/product && \
    chmod -R 755 /app/wwwroot

# Expose ports (HTTP and HTTPS)
EXPOSE 8080
EXPOSE 8081

# Copy published files from publish stage
COPY --from=publish /app/publish .

# Set environment variables for production
ENV ASPNETCORE_URLS=http://+:8080
ENV ASPNETCORE_ENVIRONMENT=Production

# Create a non-root user for security (optional but recommended)
RUN useradd -m -s /bin/bash appuser && \
    chown -R appuser:appuser /app
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Set the entry point
ENTRYPOINT ["dotnet", "LearningWeb.dll"]
