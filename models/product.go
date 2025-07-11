package models

import (
	"time"

	"go.mongodb.org/mongo-driver/bson/primitive"
)

type Product struct {
	ID          primitive.ObjectID `json:"id" bson:"_id,omitempty"`
	Name        string            `json:"name" bson:"name"`
	Description string            `json:"description" bson:"description"`
	Price       float64           `json:"price" bson:"price"`
	Stock       int              `json:"stock" bson:"stock"`
	Category    string            `json:"category" bson:"category"`
	CreatedAt   time.Time         `json:"created_at" bson:"created_at"`
	UpdatedAt   time.Time         `json:"updated_at" bson:"updated_at"`
} 