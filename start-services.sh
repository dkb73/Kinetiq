#!/bin/bash

echo "Starting Distributed Ticket System..."

# Stop any existing containers
echo "Stopping existing containers..."
docker-compose down

# Start infrastructure services first
echo "Starting infrastructure services (PostgreSQL, Redis, MongoDB, Kafka, Zookeeper)..."
docker-compose up -d postgres redis mongo zookeeper kafka

# Wait for PostgreSQL to be ready
echo "Waiting for PostgreSQL to be ready..."
sleep 15

# Wait for MongoDB to be ready
echo "Waiting for MongoDB to be ready..."
sleep 10

# Wait for Kafka to be ready
echo "Waiting for Kafka to be ready..."
sleep 10

# Start application services
echo "Starting application services..."
docker-compose up -d worker data-sync-service

# Wait a bit for them to initialize
echo "Waiting for worker and data-sync to initialize..."
sleep 10

# Start API services
echo "Starting API services..."
docker-compose up -d write-api read-api

# Wait for APIs to be ready
echo "Waiting for APIs to be ready..."
sleep 10

# Build and start frontend
echo "Building frontend..."
docker-compose up -d --build frontend

# Wait for frontend build to complete
echo "Waiting for frontend build to complete..."
sleep 15

# Start nginx gateway (serves frontend and proxies API)
echo "Starting nginx gateway..."
docker-compose up -d nginx

echo ""
echo "========================================"
echo "All services started successfully!"
echo "========================================"
echo "Frontend + API Gateway: http://localhost:8080"
echo "Check logs with: docker-compose logs -f"
echo "========================================"
