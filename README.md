# E-commerce Backend API

A RESTful API for an e-commerce platform built with Go, Gin, and MongoDB.

## Prerequisites

- Go 1.21 or higher
- MongoDB
- Git
- A REST API client (like Postman, Insomnia, or cURL)

## Setup Instructions

### 1. Install Go (if not installed)
- Visit [Go's official download page](https://golang.org/dl/)
- Download and install the appropriate version for your OS
- Verify installation by running:
  ```bash
  go version
  ```

### 2. Install MongoDB (if not installed)
- Download [MongoDB Community Server](https://www.mongodb.com/try/download/community)
- Follow the installation instructions for your OS
- Start MongoDB service
- Default MongoDB URL will be: `mongodb://localhost:27017`

### 3. Project Setup

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
   Note: For JWT_SECRET, use a secure random string. You can generate one using PowerShell:
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

## Testing the API

### Using Postman/Insomnia

1. **Register a User**
   ```http
   POST http://localhost:8080/api/auth/register
   Content-Type: application/json

   {
       "email": "test@example.com",
       "password": "password123",
       "name": "Test User",
       "address": "123 Test St"
   }
   ```

2. **Login**
   ```http
   POST http://localhost:8080/api/auth/login
   Content-Type: application/json

   {
       "email": "test@example.com",
       "password": "password123"
   }
   ```
   Save the returned JWT token for authenticated requests.

3. **Create a Product (Protected Route)**
   ```http
   POST http://localhost:8080/api/products
   Authorization: Bearer <your-jwt-token>
   Content-Type: application/json

   {
       "name": "Test Product",
       "description": "A test product",
       "price": 29.99,
       "stock": 100,
       "category": "Test Category"
   }
   ```

4. **Create an Order (Protected Route)**
   ```http
   POST http://localhost:8080/api/orders
   Authorization: Bearer <your-jwt-token>
   Content-Type: application/json

   {
       "items": [
           {
               "product_id": "<product-id-from-previous-step>",
               "quantity": 2,
               "price": 29.99
           }
       ]
   }
   ```

### Using cURL

1. **Register:**
   ```bash
   curl -X POST http://localhost:8080/api/auth/register \
   -H "Content-Type: application/json" \
   -d '{"email":"test@example.com","password":"password123","name":"Test User","address":"123 Test St"}'
   ```

2. **Login:**
   ```bash
   curl -X POST http://localhost:8080/api/auth/login \
   -H "Content-Type: application/json" \
   -d '{"email":"test@example.com","password":"password123"}'
   ```

3. **Get Products (Public):**
   ```bash
   curl http://localhost:8080/api/products
   ```

4. **Create Product (Protected):**
   ```bash
   curl -X POST http://localhost:8080/api/products \
   -H "Authorization: Bearer <your-jwt-token>" \
   -H "Content-Type: application/json" \
   -d '{"name":"Test Product","description":"A test product","price":29.99,"stock":100,"category":"Test Category"}'
   ```

## API Endpoints Reference

### Authentication Endpoints

#### Register User
- **POST** `/api/auth/register`
- Body:
```json
{
    "email": "user@example.com",
    "password": "password123",
    "name": "John Doe",
    "address": "123 Street, City"
}
```

#### Login
- **POST** `/api/auth/login`
- Body:
```json
{
    "email": "user@example.com",
    "password": "password123"
}
```
- Returns: JWT token

### Products Endpoints

#### Get All Products (Public)
- **GET** `/api/products`

#### Get Single Product (Public)
- **GET** `/api/products/:id`

#### Create Product (Protected)
- **POST** `/api/products`
- Requires Authentication
- Body:
```json
{
    "name": "Product Name",
    "description": "Product Description",
    "price": 99.99,
    "stock": 100,
    "category": "Electronics"
}
```

#### Update Product (Protected)
- **PUT** `/api/products/:id`
- Requires Authentication
- Body: Same as Create Product

#### Delete Product (Protected)
- **DELETE** `/api/products/:id`
- Requires Authentication

### Orders Endpoints

#### Create Order (Protected)
- **POST** `/api/orders`
- Requires Authentication
- Body:
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

#### Get User Orders (Protected)
- **GET** `/api/orders`
- Requires Authentication

#### Get Single Order (Protected)
- **GET** `/api/orders/:id`
- Requires Authentication

#### Update Order Status (Protected)
- **PUT** `/api/orders/:id/status`
- Requires Authentication
- Body:
```json
{
    "status": "processing"
}
```

## Authentication

For protected endpoints, include the JWT token in the Authorization header:
```
Authorization: Bearer your_jwt_token_here
```

## Error Handling

The API returns appropriate HTTP status codes and error messages in JSON format:
```json
{
    "error": "Error message here"
}
```

## Common HTTP Status Codes

- 200: Success
- 201: Created
- 400: Bad Request
- 401: Unauthorized
- 404: Not Found
- 500: Internal Server Error

## Troubleshooting

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

## Development Tips

1. Use the `.env` file to configure your environment
2. Keep your JWT token secure and include it in all protected requests
3. Monitor MongoDB connection in the console logs
4. Check response status codes and error messages for debugging 