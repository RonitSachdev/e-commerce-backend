package main

import (
	"ecombackend/handlers"
	"ecombackend/middleware"

	"github.com/gin-gonic/gin"
)

func initializeRoutes(router *gin.Engine) {
	// Public routes
	router.POST("/api/auth/register", handlers.Register)
	router.POST("/api/auth/login", handlers.Login)
	
	// Products routes (some public, some protected)
	router.GET("/api/products", handlers.GetProducts)
	router.GET("/api/products/:id", handlers.GetProduct)
	
	// Protected routes
	protected := router.Group("/api")
	protected.Use(middleware.AuthMiddleware())
	{
		// Product management (admin only in a real app)
		protected.POST("/products", handlers.CreateProduct)
		protected.PUT("/products/:id", handlers.UpdateProduct)
		protected.DELETE("/products/:id", handlers.DeleteProduct)

		// Order management
		protected.POST("/orders", handlers.CreateOrder)
		protected.GET("/orders", handlers.GetUserOrders)
		protected.GET("/orders/:id", handlers.GetOrder)
		protected.PUT("/orders/:id/status", handlers.UpdateOrderStatus)
	}
} 