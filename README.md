# E-commerce Backend API

A complete RESTful API for an e-commerce platform built with Go, Gin, and MongoDB. This API provides user authentication, product management, and order processing capabilities.

## 🚀 Features

- **User Authentication**: Registration, login with JWT tokens
- **Product Management**: Full CRUD operations for products
- **Order Management**: Create and manage orders with product validation
- **Security**: Password hashing, JWT authentication, input validation
- **Database**: MongoDB integration with proper data models
- **Error Handling**: Comprehensive error messages and validation

## 📋 Prerequisites

- Go 1.21 or higher
- MongoDB (local or Atlas)
- Git
- A REST API client (Postman, Insomnia, or cURL)

## 🛠️ Setup Instructions

### Option 1: Docker Setup (Recommended)

#### Prerequisites
- Docker Desktop installed and running
- Git

#### Quick Start with Docker

1. **Clone and setup:**
   ```bash
   git clone <repository-url>
   cd EcomBackend
   ```

2. **Run the Docker setup script:**
   ```powershell
   .\scripts\docker-setup.ps1
   ```

3. **Start the application:**
   ```bash
   docker-compose up -d
   ```

4. **Check the services:**
   ```bash
   docker-compose ps
   ```

5. **View logs:**
   ```bash
   docker-compose logs -f
   ```

#### Docker Services Available:
- **API**: `http://localhost:8080` - Main e-commerce API
- **MongoDB**: `localhost:27017` - Database
- **Mongo Express**: `http://localhost:8081` - MongoDB admin interface (admin/password123)

#### Docker Commands:
```bash
# Start services
docker-compose up -d

# Stop services
docker-compose down

# Rebuild and start
docker-compose up -d --build

# View logs
docker-compose logs -f api

# Access container shell
docker-compose exec api sh

# Production deployment
docker-compose -f docker-compose.prod.yml up -d
```

### Option 2: Local Development Setup

#### Prerequisites
- Go 1.21 or higher
- MongoDB (local or Atlas)
- Git

#### 1. Install Go (if not installed)
- Visit [Go's official download page](https://golang.org/dl/)
- Download and install the appropriate version for your OS
- Verify installation:
  ```bash
  go version
  ```

#### 2. Install MongoDB (if not installed)
1. Download [MongoDB Community Server](https://www.mongodb.com/try/download/community)
2. Run the installer with these specific settings:
   - Choose "Complete" installation type
   - In "Service Configuration":
     - Check "Install MongoDB as a Service"
     - Select "Run service as Network Service user" (recommended)
     - Keep "Service Name" as "MongoDB"
   - Check "Install MongoDB Compass" if you want a GUI tool
3. After installation:
   ```bash
   # Windows (PowerShell) - Verify service is running
   Get-Service MongoDB
   
   # If service is not running, start it
   Start-Service MongoDB
   
   # To ensure service starts automatically on boot
   Set-Service MongoDB -StartupType Automatic
   ```

Note: If you accidentally installed MongoDB with Local System account, you can change it:
1. Open Services (services.msc)
2. Find MongoDB service
3. Right-click → Properties
4. In "Log On" tab, select "Network Service"
5. Click Apply and restart the service

#### 3. Project Setup

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd EcomBackend
   ```

2. Create `.env` file:
   ```
   MONGODB_URI=mongodb://localhost:27017
   DB_NAME=ecommerce
   JWT_SECRET=<your-generated-secret>
   PORT=8080
   ```
   
   **Generate JWT Secret (PowerShell):**
   ```powershell
   $jwtSecret = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | ForEach-Object {[char]$_})
   echo $jwtSecret
   ```

3. Install dependencies:
   ```bash
   go mod tidy
   ```

4. Run the application:
   ```bash
   go run .
   ```

## 🧪 Testing the API

### Using the Test Script

The project includes a PowerShell test script that tests all endpoints:

```powershell
.\test_api.ps1
```

This script will:
1. Register a new user
2. Login and get JWT token
3. Create a product
4. Get all products
5. Create an order
6. Get user orders

### Manual Testing with cURL

1. **Register User:**
   ```bash
   curl -X POST http://localhost:8080/api/auth/register \
   -H "Content-Type: application/json" \
   -d '{"email":"test@example.com","password":"test123","name":"Test User","address":"123 Test St"}'
   ```

2. **Login:**
   ```bash
   curl -X POST http://localhost:8080/api/auth/login \
   -H "Content-Type: application/json" \
   -d '{"email":"test@example.com","password":"test123"}'
   ```

3. **Create Product (with JWT token):**
   ```bash
   curl -X POST http://localhost:8080/api/products \
   -H "Authorization: Bearer <your-jwt-token>" \
   -H "Content-Type: application/json" \
   -d '{"name":"Test Product","description":"A test product","price":29.99,"stock":100,"category":"Electronics"}'
   ```

4. **Get Products (public):**
   ```bash
   curl http://localhost:8080/api/products
   ```

5. **Create Order (with JWT token):**
   ```bash
   curl -X POST http://localhost:8080/api/orders \
   -H "Authorization: Bearer <your-jwt-token>" \
   -H "Content-Type: application/json" \
   -d '{"items":[{"product_id":"<product-id>","quantity":2,"price":29.99}]}'
   ```

## 📚 API Documentation

### Authentication Endpoints

#### Register User
- **POST** `/api/auth/register`
- **Body:**
  ```json
  {
    "email": "user@example.com",
    "password": "password123",
    "name": "John Doe",
    "address": "123 Street, City"
  }
  ```
- **Response:** User object (without password)
- **Validation:**
  - Email must be valid format
  - Password minimum 6 characters
  - Name is required
  - Email must be unique

#### Login
- **POST** `/api/auth/login`
- **Body:**
  ```json
  {
    "email": "user@example.com",
    "password": "password123"
  }
  ```
- **Response:** JWT token
- **Validation:** Valid email/password combination

### Products Endpoints

#### Get All Products (Public)
- **GET** `/api/products`
- **Response:** Array of product objects
- **Authentication:** Not required

#### Get Single Product (Public)
- **GET** `/api/products/:id`
- **Response:** Single product object
- **Authentication:** Not required

#### Create Product (Protected)
- **POST** `/api/products`
- **Headers:** `Authorization: Bearer <jwt-token>`
- **Body:**
  ```json
  {
    "name": "Product Name",
    "description": "Product Description",
    "price": 99.99,
    "stock": 100,
    "category": "Electronics"
  }
  ```
- **Validation:**
  - Name is required
  - Price must be > 0
  - Stock must be >= 0

#### Update Product (Protected)
- **PUT** `/api/products/:id`
- **Headers:** `Authorization: Bearer <jwt-token>`
- **Body:** Same as Create Product
- **Validation:** Same as Create Product

#### Delete Product (Protected)
- **DELETE** `/api/products/:id`
- **Headers:** `Authorization: Bearer <jwt-token>`
- **Response:** Success message

### Orders Endpoints

#### Create Order (Protected)
- **POST** `/api/orders`
- **Headers:** `Authorization: Bearer <jwt-token>`
- **Body:**
  ```json
  {
    "items": [
      {
        "product_id": "product_id_here",
        "quantity": 2,
        "price": 99.99
      }
    ]
  }
  ```
- **Validation:**
  - Product ID must be valid ObjectID
  - Product must exist in database
  - Quantity must be > 0
  - Price must be > 0

#### Get User Orders (Protected)
- **GET** `/api/orders`
- **Headers:** `Authorization: Bearer <jwt-token>`
- **Response:** Array of user's orders

#### Get Single Order (Protected)
- **GET** `/api/orders/:id`
- **Headers:** `Authorization: Bearer <jwt-token>`
- **Response:** Single order object
- **Validation:** Order must belong to authenticated user

#### Update Order Status (Protected)
- **PUT** `/api/orders/:id/status`
- **Headers:** `Authorization: Bearer <jwt-token>`
- **Body:**
  ```json
  {
    "status": "processing"
  }
  ```
- **Response:** Success message

## 🔧 Server Management Scripts

The project includes PowerShell scripts for easy server management:

### Kill Process on Port
```powershell
# Kill any process using port 8080
.\scripts\kill_port.ps1 -Port 8080
```

### Stop Server
```powershell
# Stop the server and clean up processes
.\scripts\stop_server.ps1
```

These scripts are useful when:
- The server didn't shut down properly
- Port conflicts occur
- You need to quickly restart the server
- Multiple instances are running

To use these scripts:
1. Open PowerShell
2. Navigate to the project directory
3. Run the desired script

Note: You might need to set PowerShell execution policy to run scripts:
```powershell
# Run as administrator
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 🚨 Troubleshooting

### 500 Error on Order Creation (Schema Mismatch)

If you get a 500 error when creating an order, and the logs show a message like:

```
Database error: write exception: write errors: [Document failed validation: ... missingProperties: ["products","total_amount"]
```

This means your MongoDB validation schema is out of sync with your Go code. The Go code uses `items` and `total` fields for orders, but the old schema may expect `products` and `total_amount`.

**How to fix:**
1. Stop all containers:
   ```bash
   docker-compose down
   ```
2. Remove the MongoDB data volume (this will delete all data!):
   ```bash
   docker-compose down -v
   ```
3. Start the containers again:
   ```bash
   docker-compose up -d
   ```
4. The database will be re-initialized with the correct schema from `scripts/init-mongo.js`.

**Note:** If you change the schema in `scripts/init-mongo.js`, you must remove the volume and restart as above for changes to take effect.

### MongoDB Connection Issues

If you see an error like:
```
server selection error: context deadline exceeded, current topology: { Type: Unknown, Servers: [{ Addr: localhost:27017, Type: Unknown, Last error: dial tcp [::1]:27017: connectex: No connection could be made because the target machine actively refused it. }
```

Follow these steps:
1. Verify MongoDB is installed and running:
   ```bash
   # Windows (PowerShell)
   Get-Service MongoDB
   # Start MongoDB if it's not running
   Start-Service MongoDB
   ```

2. If MongoDB is not installed as a service:
   - Navigate to MongoDB installation directory (typically `C:\Program Files\MongoDB\Server\[version]\bin`)
   - Run `mongod.exe` to start the MongoDB server
   - Keep this window open while running the application

3. Alternative: Use MongoDB Atlas (Cloud hosted):
   - Create a free account at [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
   - Create a new cluster
   - Get your connection string and update MONGODB_URI in .env file
   ```
   MONGODB_URI=mongodb+srv://<username>:<password>@<cluster-url>/<dbname>
   ```

### Environment File Issues

If you see errors related to the .env file:

1. Make sure to create the .env file without BOM (Byte Order Mark):
   ```powershell
   # PowerShell (correct way to create .env)
   @'
   MONGODB_URI=mongodb://localhost:27017
   DB_NAME=ecommerce
   JWT_SECRET=your_generated_secret
   PORT=8080
   '@ | Out-File -Encoding ASCII .env
   ```

2. Verify file content:
   - Use a text editor that shows hidden characters
   - Ensure there are no extra spaces or special characters
   - Each line should end with a regular line break
   - File should be in ASCII or UTF-8 without BOM

3. Common .env mistakes to avoid:
   - Don't use quotes around values
   - Don't add spaces around the = sign
   - Don't add trailing spaces
   - Don't use Windows-style paths with backslashes

### Other Common Issues

1. Port already in use:
   ```
   listen tcp :8080: bind: address already in use
   ```
   - Change the PORT in .env file
   - Or find and stop the process using port 8080

2. Go module issues:
   ```bash
   # Clean go module cache
   go clean -modcache
   # Regenerate go.sum
   go mod tidy
   ```

3. Permission issues:
   - Run your terminal/IDE as administrator
   - Check file and directory permissions
   - Ensure write access to the project directory

## 📊 Data Models

### User
```go
type User struct {
    ID        primitive.ObjectID `json:"id" bson:"_id,omitempty"`
    Email     string            `json:"email" bson:"email"`
    Password  string            `json:"-" bson:"password"`
    Name      string            `json:"name" bson:"name"`
    Address   string            `json:"address" bson:"address"`
    CreatedAt time.Time         `json:"created_at" bson:"created_at"`
    UpdatedAt time.Time         `json:"updated_at" bson:"updated_at"`
}
```

### Product
```go
type Product struct {
    ID          primitive.ObjectID `json:"id" bson:"_id,omitempty"`
    Name        string            `json:"name" bson:"name"`
    Description string            `json:"description" bson:"description"`
    Price       float64           `json:"price" bson:"price"`
    Stock       int               `json:"stock" bson:"stock"`
    Category    string            `json:"category" bson:"category"`
    CreatedAt   time.Time         `json:"created_at" bson:"created_at"`
    UpdatedAt   time.Time         `json:"updated_at" bson:"updated_at"`
}
```

### Order
```go
type Order struct {
    ID        primitive.ObjectID `json:"id" bson:"_id,omitempty"`
    UserID    primitive.ObjectID `json:"user_id" bson:"user_id"`
    Items     []OrderItem        `json:"items" bson:"items"`
    Total     float64            `json:"total" bson:"total"`
    Status    string             `json:"status" bson:"status"`
    CreatedAt time.Time          `json:"created_at" bson:"created_at"`
    UpdatedAt time.Time          `json:"updated_at" bson:"updated_at"`
}
```

## 🔐 Authentication

For protected endpoints, include the JWT token in the Authorization header:
```
Authorization: Bearer your_jwt_token_here
```

## 📝 Error Handling

The API returns appropriate HTTP status codes and error messages in JSON format:
```json
{
    "error": "Error message here"
}
```

## 📋 Common HTTP Status Codes

- 200: Success
- 201: Created
- 400: Bad Request
- 401: Unauthorized
- 404: Not Found
- 409: Conflict (e.g., duplicate email)
- 500: Internal Server Error

## 🛡️ Security Features

- **Password Hashing**: All passwords are hashed using bcrypt
- **JWT Authentication**: Secure token-based authentication
- **Input Validation**: Comprehensive validation for all inputs
- **Protected Routes**: Authentication required for sensitive operations
- **Data Sanitization**: Input trimming and validation

## 🚀 Development Tips

1. Use the `.env` file to configure your environment
2. Keep your JWT token secure and include it in all protected requests
3. Monitor MongoDB connection in the console logs
4. Check response status codes and error messages for debugging
5. Use the provided test script for quick API validation
6. Use the server management scripts for easy deployment

## 🐳 Docker Deployment

### Development Environment

The project includes comprehensive Docker support for easy deployment:

#### Docker Files:
- `Dockerfile` - Multi-stage build for the Go application
- `docker-compose.yml` - Development environment with MongoDB and Mongo Express
- `docker-compose.prod.yml` - Production-ready configuration with nginx
- `.dockerignore` - Excludes unnecessary files from Docker build

#### Quick Docker Commands:
```bash
# Development
docker-compose up -d

# Production
docker-compose -f docker-compose.prod.yml up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# Rebuild
docker-compose up -d --build
```

#### Docker Services:
- **API**: `http://localhost:8080` - Main e-commerce API
- **MongoDB**: `localhost:27017` - Database with authentication
- **Mongo Express**: `http://localhost:8081` - MongoDB admin interface
- **Nginx** (production): Reverse proxy with SSL termination

#### Production Features:
- Multi-stage Docker builds for smaller images
- Non-root user for security
- Health checks for all services
- Resource limits and reservations
- SSL/TLS termination with nginx
- Rate limiting and security headers
- Persistent MongoDB data storage

### Environment Variables

For Docker deployment, use the `env.example` file as a template:

```bash
# Copy and customize
cp env.example .env

# Or use environment variables directly
export JWT_SECRET=your_secure_secret
export MONGO_ROOT_PASSWORD=your_secure_password
```

## 📦 Project Structure

```
EcomBackend/
├── main.go                 # Application entry point
├── routes.go               # Route definitions
├── go.mod                  # Go module file
├── .env                    # Environment variables
├── env.example            # Environment template
├── .gitignore             # Git ignore rules
├── README.md              # This documentation
├── test_api.ps1           # API test script
├── Dockerfile             # Docker configuration
├── docker-compose.yml     # Development Docker setup
├── docker-compose.prod.yml # Production Docker setup
├── .dockerignore          # Docker ignore rules
├── models/                 # Data models
│   ├── user.go
│   ├── product.go
│   └── order.go
├── handlers/               # Request handlers
│   ├── auth.go
│   ├── product.go
│   └── order.go
├── middleware/             # Middleware functions
│   └── auth.go
├── db/                     # Database connection
│   └── mongodb.go
├── scripts/                # Management scripts
│   ├── kill_port.ps1
│   ├── stop_server.ps1
│   ├── docker-setup.ps1
│   └── init-mongo.js
└── nginx/                  # Nginx configuration
    └── nginx.conf
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License. 