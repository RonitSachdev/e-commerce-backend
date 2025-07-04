package handlers

import (
	"context"
	"log"
	"net/http"
	"time"

	"ecombackend/db"
	"ecombackend/models"

	"github.com/gin-gonic/gin"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

func CreateOrder(c *gin.Context) {
	var orderCreate models.OrderCreate
	if err := c.ShouldBindJSON(&orderCreate); err != nil {
		log.Printf("Order creation - JSON binding error: %v", err)
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	log.Printf("Order creation - Received order with %d items", len(orderCreate.Items))

	// Get user ID from context (set by auth middleware)
	userID, exists := c.Get("user_id")
	if !exists {
		log.Printf("Order creation - User not authenticated")
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	log.Printf("Order creation - User ID: %v", userID)

	// Convert OrderCreate to Order
	order := models.Order{
		UserID:    userID.(primitive.ObjectID),
		Status:    "pending",
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	// Convert items and validate product IDs
	var total float64
	for i, itemCreate := range orderCreate.Items {
		log.Printf("Order creation - Processing item %d: ProductID=%s, Quantity=%d, Price=%.2f",
			i+1, itemCreate.ProductID, itemCreate.Quantity, itemCreate.Price)

		// Convert string product ID to ObjectID
		productID, err := primitive.ObjectIDFromHex(itemCreate.ProductID)
		if err != nil {
			log.Printf("Order creation - Invalid product ID: %s, error: %v", itemCreate.ProductID, err)
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid product ID: " + itemCreate.ProductID})
			return
		}

		// Verify product exists
		productCollection := db.GetCollection("products")
		var product models.Product
		err = productCollection.FindOne(context.Background(), bson.M{"_id": productID}).Decode(&product)
		if err != nil {
			log.Printf("Order creation - Product not found: %s, error: %v", itemCreate.ProductID, err)
			c.JSON(http.StatusBadRequest, gin.H{"error": "Product not found: " + itemCreate.ProductID})
			return
		}

		log.Printf("Order creation - Product found: %s", product.Name)

		// Create order item
		orderItem := models.OrderItem{
			ProductID: productID,
			Quantity:  itemCreate.Quantity,
			Price:     itemCreate.Price,
		}

		order.Items = append(order.Items, orderItem)
		total += itemCreate.Price * float64(itemCreate.Quantity)
	}

	order.Total = total
	log.Printf("Order creation - Total calculated: %.2f", total)

	collection := db.GetCollection("orders")
	result, err := collection.InsertOne(context.Background(), order)
	if err != nil {
		log.Printf("Order creation - Database error: %v", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create order"})
		return
	}

	order.ID = result.InsertedID.(primitive.ObjectID)
	log.Printf("Order creation - Order created successfully with ID: %s", order.ID.Hex())
	c.JSON(http.StatusCreated, order)
}

func GetUserOrders(c *gin.Context) {
	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	collection := db.GetCollection("orders")
	cursor, err := collection.Find(context.Background(), bson.M{"user_id": userID})
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch orders"})
		return
	}
	defer cursor.Close(context.Background())

	var orders []models.Order
	if err := cursor.All(context.Background(), &orders); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode orders"})
		return
	}

	c.JSON(http.StatusOK, orders)
}

func GetOrder(c *gin.Context) {
	id, err := primitive.ObjectIDFromHex(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid order ID"})
		return
	}

	userID, exists := c.Get("user_id")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "User not authenticated"})
		return
	}

	collection := db.GetCollection("orders")
	var order models.Order
	err = collection.FindOne(context.Background(), bson.M{
		"_id":     id,
		"user_id": userID,
	}).Decode(&order)

	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Order not found"})
		return
	}

	c.JSON(http.StatusOK, order)
}

func UpdateOrderStatus(c *gin.Context) {
	id, err := primitive.ObjectIDFromHex(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid order ID"})
		return
	}

	var statusUpdate struct {
		Status string `json:"status" binding:"required"`
	}
	if err := c.ShouldBindJSON(&statusUpdate); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	collection := db.GetCollection("orders")
	result, err := collection.UpdateOne(
		context.Background(),
		bson.M{"_id": id},
		bson.M{
			"$set": bson.M{
				"status":     statusUpdate.Status,
				"updated_at": time.Now(),
			},
		},
	)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update order status"})
		return
	}

	if result.MatchedCount == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Order not found"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Order status updated successfully"})
}
