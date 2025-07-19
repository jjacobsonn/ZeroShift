# ZeroShift Makefile
# Provides convenient commands for building, testing, and managing the project

.PHONY: help build test clean docker-build docker-up docker-down switch-blue switch-green status health

# Default target
help:
	@echo "ZeroShift - Blue-Green Deployment Infrastructure"
	@echo ""
	@echo "Available commands:"
	@echo "  build         - Build Go binaries for blue and green services"
	@echo "  test          - Run tests for all services"
	@echo "  clean         - Clean build artifacts"
	@echo "  docker-build  - Build all Docker images"
	@echo "  docker-up     - Start all services with Docker Compose"
	@echo "  docker-down   - Stop all services"
	@echo "  switch-blue   - Switch traffic to blue environment"
	@echo "  switch-green  - Switch traffic to green environment"
	@echo "  status        - Show current deployment status"
	@echo "  health        - Check health of all services"
	@echo "  logs          - Show logs from all services"
	@echo "  logs-blue     - Show logs from blue service"
	@echo "  logs-green    - Show logs from green service"
	@echo "  logs-proxy    - Show logs from proxy service"

# Build Go binaries
build:
	@echo "Building blue service..."
	cd blue && go build -o main .
	@echo "Building green service..."
	cd green && go build -o main .

# Run tests
test:
	@echo "Running tests for blue service..."
	cd blue && go test -v
	@echo "Running tests for green service..."
	cd green && go test -v

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -f blue/main
	rm -f green/main
	@echo "Clean complete"

# Build Docker images
docker-build:
	@echo "Building Docker images..."
	docker-compose -f deploy/docker-compose.yml build
	@echo "Docker build complete"

# Start services
docker-up:
	@echo "Starting ZeroShift services..."
	docker-compose -f deploy/docker-compose.yml up -d
	@echo "Services started. Use 'make status' to check status"

# Stop services
docker-down:
	@echo "Stopping ZeroShift services..."
	docker-compose -f deploy/docker-compose.yml down
	@echo "Services stopped"

# Switch to blue environment
switch-blue:
	@echo "Switching to blue environment..."
	cd deploy && ./switch.sh blue

# Switch to green environment
switch-green:
	@echo "Switching to green environment..."
	cd deploy && ./switch.sh green

# Show status
status:
	@echo "Checking deployment status..."
	cd deploy && ./switch.sh status

# Check health
health:
	@echo "Checking health of all services..."
	cd deploy && ./switch.sh health

# Show all logs
logs:
	@echo "Showing logs from all services..."
	docker-compose -f deploy/docker-compose.yml logs -f

# Show blue service logs
logs-blue:
	@echo "Showing logs from blue service..."
	docker-compose -f deploy/docker-compose.yml logs -f blue

# Show green service logs
logs-green:
	@echo "Showing logs from green service..."
	docker-compose -f deploy/docker-compose.yml logs -f green

# Show proxy logs
logs-proxy:
	@echo "Showing logs from proxy service..."
	docker-compose -f deploy/docker-compose.yml logs -f proxy

# Development setup
dev-setup:
	@echo "Setting up development environment..."
	@echo "Installing Go dependencies..."
	cd blue && go mod tidy
	cd green && go mod tidy
	@echo "Making switch script executable..."
	chmod +x deploy/switch.sh
	@echo "Development setup complete"

# Full deployment (build, test, deploy)
deploy: test docker-build docker-up
	@echo "Deployment complete!"
	@echo "Use 'make status' to check deployment status"

# Quick start (setup and deploy)
quick-start: dev-setup deploy
	@echo "ZeroShift is ready!"
	@echo "Access the application at: http://localhost"
	@echo "Use 'make status' to check status"
	@echo "Use 'make switch-green' to switch to green environment" 