# Test API endpoints
Write-Host "=== Testing E-commerce API ===" -ForegroundColor Green

# Generate unique email using timestamp
$timestamp = Get-Date -Format "yyyyMMddHHmmss"
$uniqueEmail = "testuser$timestamp@example.com"

# 1. Register a new user
Write-Host "`n1. Registering new user..." -ForegroundColor Yellow
$registerBody = @{
    email = $uniqueEmail
    password = "testpass123"
    name = "API Test User"
    address = "789 API St"
} | ConvertTo-Json

try {
    $registerResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/register" -Method Post -ContentType "application/json" -Body $registerBody
    Write-Host "✅ User registered successfully: $($registerResponse.email)" -ForegroundColor Green
} catch {
    Write-Host "❌ Registration failed: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

# 2. Login to get token
Write-Host "`n2. Logging in..." -ForegroundColor Yellow
$loginBody = @{
    email = $uniqueEmail
    password = "testpass123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/auth/login" -Method Post -ContentType "application/json" -Body $loginBody
    $token = $loginResponse.token
    Write-Host "✅ Login successful, token received" -ForegroundColor Green
} catch {
    Write-Host "❌ Login failed: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

# 3. Create a product (protected)
Write-Host "`n3. Creating product..." -ForegroundColor Yellow
$headers = @{
    "Content-Type" = "application/json"
    "Authorization" = "Bearer $token"
}
$productBody = @{
    name = "Test Product"
    description = "A test product description"
    price = 29.99
    stock = 100
    category = "Electronics"
} | ConvertTo-Json

try {
    $productResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/products" -Method Post -Headers $headers -Body $productBody
    $productId = $productResponse.id
    Write-Host "✅ Product created successfully: $($productResponse.name)" -ForegroundColor Green
} catch {
    Write-Host "❌ Product creation failed: $($_.Exception.Message)" -ForegroundColor Red
    exit
}

# 4. Get all products (public)
Write-Host "`n4. Getting all products..." -ForegroundColor Yellow
try {
    $productsResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/products" -Method Get -ContentType "application/json"
    Write-Host "✅ Retrieved $($productsResponse.Count) products" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to get products: $($_.Exception.Message)" -ForegroundColor Red
}

# 5. Create an order (protected)
Write-Host "`n5. Creating order..." -ForegroundColor Yellow
$orderBody = @{
    items = @(
        @{
            product_id = $productId
            quantity = 2
            price = 29.99
        }
    )
} | ConvertTo-Json

try {
    $orderResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/orders" -Method Post -Headers $headers -Body $orderBody
    Write-Host "✅ Order created successfully: $($orderResponse.id)" -ForegroundColor Green
} catch {
    Write-Host "❌ Order creation failed: $($_.Exception.Message)" -ForegroundColor Red
}

# 6. Get user orders (protected)
Write-Host "`n6. Getting user orders..." -ForegroundColor Yellow
try {
    $ordersResponse = Invoke-RestMethod -Uri "http://localhost:8080/api/orders" -Method Get -Headers $headers
    Write-Host "✅ Retrieved $($ordersResponse.Count) orders" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to get orders: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n=== API Testing Complete ===" -ForegroundColor Green 