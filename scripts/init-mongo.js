// MongoDB initialization script
// This script runs when the MongoDB container starts for the first time

// Switch to the ecommerce database
db = db.getSiblingDB('ecommerce');

// Create collections with validation
db.createCollection("users", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["email", "password", "name"],
      properties: {
        email: {
          bsonType: "string",
          pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
        },
        password: {
          bsonType: "string",
          minLength: 6
        },
        name: {
          bsonType: "string",
          minLength: 2
        }
      }
    }
  }
});

db.createCollection("products", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["name", "description", "price", "stock"],
      properties: {
        name: {
          bsonType: "string",
          minLength: 1
        },
        description: {
          bsonType: "string"
        },
        price: {
          bsonType: "number",
          minimum: 0
        },
        stock: {
          bsonType: "int",
          minimum: 0
        }
      }
    }
  }
});

db.createCollection("orders", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["user_id", "items", "total", "status"],
      properties: {
        user_id: {
          bsonType: "objectId"
        },
        items: {
          bsonType: "array",
          items: {
            bsonType: "object",
            required: ["product_id", "quantity", "price"],
            properties: {
              product_id: {
                bsonType: "objectId"
              },
              quantity: {
                bsonType: "int",
                minimum: 1
              },
              price: {
                bsonType: "number",
                minimum: 0
              }
            }
          }
        },
        total: {
          bsonType: "number",
          minimum: 0
        },
        status: {
          enum: ["pending", "processing", "shipped", "delivered", "cancelled"]
        }
      }
    }
  }
});

// Create indexes for better performance
db.users.createIndex({ "email": 1 }, { unique: true });
db.products.createIndex({ "name": 1 });
db.products.createIndex({ "category": 1 });
db.orders.createIndex({ "user_id": 1 });
db.orders.createIndex({ "status": 1 });
db.orders.createIndex({ "created_at": -1 });

print("MongoDB initialization completed successfully!");
print("Database: ecommerce");
print("Collections created: users, products, orders");
print("Indexes created for better performance"); 