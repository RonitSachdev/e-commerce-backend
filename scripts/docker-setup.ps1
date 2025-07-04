# Docker Setup Script for E-commerce API
# This script helps set up the Docker environment

Write-Host "🚀 Setting up Docker environment for E-commerce API..." -ForegroundColor Green

# Check if Docker is installed
try {
    docker --version | Out-Null
    Write-Host "✅ Docker is installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not installed. Please install Docker Desktop first." -ForegroundColor Red
    exit 1
}

# Check if Docker is running
try {
    docker info | Out-Null
    Write-Host "✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not running. Please start Docker Desktop." -ForegroundColor Red
    exit 1
}

# Generate JWT secret if not exists
if (-not (Test-Path ".env")) {
    Write-Host "📝 Creating .env file..." -ForegroundColor Yellow
    
    # Generate a secure JWT secret
    $jwtSecret = -join ((33..126) | Get-Random -Count 64 | ForEach-Object {[char]$_})
    
    @"
# MongoDB Configuration
MONGO_ROOT_USERNAME=admin
MONGO_ROOT_PASSWORD=changeme
MONGODB_URI=mongodb://admin:changeme@mongodb:27017/ecommerce?authSource=admin
DB_NAME=ecommerce

# JWT Configuration
JWT_SECRET=$jwtSecret

# Server Configuration
PORT=8080
GIN_MODE=release
"@ | Out-File -FilePath ".env" -Encoding ASCII
    
    Write-Host "✅ .env file created with secure JWT secret" -ForegroundColor Green
} else {
    Write-Host "✅ .env file already exists" -ForegroundColor Green
}

# Create SSL certificates for nginx (self-signed for development)
if (-not (Test-Path "nginx/ssl")) {
    Write-Host "📝 Creating SSL certificates for nginx..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path "nginx/ssl" -Force | Out-Null
    
    # Generate self-signed certificate
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 `
        -keyout nginx/ssl/key.pem `
        -out nginx/ssl/cert.pem `
        -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost" 2>$null
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ SSL certificates created" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Could not create SSL certificates. Nginx will not work with HTTPS." -ForegroundColor Yellow
    }
} else {
    Write-Host "✅ SSL certificates already exist" -ForegroundColor Green
}

Write-Host ""
Write-Host "🎉 Docker environment setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Run: docker-compose up -d" -ForegroundColor White
Write-Host "2. Check logs: docker-compose logs -f" -ForegroundColor White
Write-Host "3. Stop services: docker-compose down" -ForegroundColor White
Write-Host ""
Write-Host "For production deployment:" -ForegroundColor Cyan
Write-Host "1. Copy env.example to .env and update values" -ForegroundColor White
Write-Host "2. Run: docker-compose -f docker-compose.prod.yml up -d" -ForegroundColor White 