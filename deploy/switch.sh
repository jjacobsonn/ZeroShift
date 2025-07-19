#!/bin/bash

# ZeroShift Blue-Green Deployment Switch Script
# This script switches traffic between blue and green environments

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
LIVE_FILE="live.txt"
PROXY_CONTAINER="zeroshift-proxy"
BLUE_CONTAINER="zeroshift-blue"
GREEN_CONTAINER="zeroshift-green"
HEALTH_TIMEOUT=30
HEALTH_RETRIES=3

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] WARNING: $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ERROR: $1${NC}"
}

info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] INFO: $1${NC}"
}

# Function to check if container is healthy
check_container_health() {
    local container=$1
    local port=$2
    local retries=$HEALTH_RETRIES
    local timeout=$HEALTH_TIMEOUT
    
    log "Checking health of $container on port $port..."
    
    for i in $(seq 1 $retries); do
        if curl -f -s "http://localhost:$port/health" > /dev/null 2>&1; then
            log "✅ $container is healthy"
            return 0
        else
            warn "Attempt $i/$retries: $container health check failed"
            if [ $i -lt $retries ]; then
                sleep 2
            fi
        fi
    done
    
    error "❌ $container health check failed after $retries attempts"
    return 1
}

# Function to get current live environment
get_current_live() {
    if [ -f "$LIVE_FILE" ]; then
        cat "$LIVE_FILE" | tr -d '[:space:]'
    else
        echo "blue"
    fi
}

# Function to switch to target environment
switch_to() {
    local target=$1
    local current=$(get_current_live)
    
    if [ "$target" = "$current" ]; then
        warn "Already running on $target environment"
        return 0
    fi
    
    log "🔄 Switching from $current to $target environment"
    
    # Check target environment health
    if [ "$target" = "blue" ]; then
        check_container_health "$BLUE_CONTAINER" "8081"
    elif [ "$target" = "green" ]; then
        check_container_health "$GREEN_CONTAINER" "8082"
    else
        error "Invalid target environment: $target"
        return 1
    fi
    
    # Update live.txt
    echo "$target" > "$LIVE_FILE"
    log "📝 Updated $LIVE_FILE to $target"
    
    # Update nginx configuration
    local backend_config=""
    if [ "$target" = "blue" ]; then
        backend_config="set \$backend blue_backend;"
    else
        backend_config="set \$backend green_backend;"
    fi
    
    # Update nginx backend configuration
    docker exec "$PROXY_CONTAINER" sh -c "echo '$backend_config' > /etc/nginx/backend.conf"
    log "🔧 Updated nginx backend configuration"
    
    # Reload nginx configuration
    if docker exec "$PROXY_CONTAINER" nginx -s reload; then
        log "✅ Nginx configuration reloaded successfully"
    else
        error "❌ Failed to reload nginx configuration"
        return 1
    fi
    
    # Verify switch
    sleep 2
    if check_proxy_health; then
        log "🎉 Successfully switched to $target environment"
        log "🌐 Traffic now routing to $target backend"
        return 0
    else
        error "❌ Proxy health check failed after switch"
        return 1
    fi
}

# Function to check proxy health
check_proxy_health() {
    if curl -f -s "http://localhost/health" > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to show current status
show_status() {
    local current=$(get_current_live)
    local blue_status="❌"
    local green_status="❌"
    
    if docker ps --format "table {{.Names}}" | grep -q "$BLUE_CONTAINER"; then
        blue_status="✅"
    fi
    
    if docker ps --format "table {{.Names}}" | grep -q "$GREEN_CONTAINER"; then
        green_status="✅"
    fi
    
    echo ""
    echo "🔄 ZeroShift Blue-Green Deployment Status"
    echo "=========================================="
    echo "Current Live Environment: ${BLUE}$current${NC}"
    echo ""
    echo "Container Status:"
    echo "  Blue Environment:  $blue_status $BLUE_CONTAINER"
    echo "  Green Environment: $green_status $GREEN_CONTAINER"
    echo "  Proxy:             ✅ $PROXY_CONTAINER"
    echo ""
    echo "Health Endpoints:"
    echo "  Blue:  http://localhost:8081/health"
    echo "  Green: http://localhost:8082/health"
    echo "  Proxy: http://localhost/health"
    echo ""
    echo "Main Endpoints:"
    echo "  Blue:  http://localhost:8081/"
    echo "  Green: http://localhost:8082/"
    echo "  Proxy: http://localhost/"
    echo ""
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  blue     Switch traffic to blue environment"
    echo "  green    Switch traffic to green environment"
    echo "  status   Show current deployment status"
    echo "  health   Check health of all services"
    echo "  help     Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 blue     # Switch to blue environment"
    echo "  $0 green    # Switch to green environment"
    echo "  $0 status   # Show current status"
    echo ""
}

# Function to check all services health
check_all_health() {
    log "🔍 Checking health of all services..."
    
    local all_healthy=true
    
    # Check blue
    if check_container_health "$BLUE_CONTAINER" "8081"; then
        log "✅ Blue environment is healthy"
    else
        error "❌ Blue environment is unhealthy"
        all_healthy=false
    fi
    
    # Check green
    if check_container_health "$GREEN_CONTAINER" "8082"; then
        log "✅ Green environment is healthy"
    else
        error "❌ Green environment is unhealthy"
        all_healthy=false
    fi
    
    # Check proxy
    if check_proxy_health; then
        log "✅ Proxy is healthy"
    else
        error "❌ Proxy is unhealthy"
        all_healthy=false
    fi
    
    if [ "$all_healthy" = true ]; then
        log "🎉 All services are healthy"
    else
        error "❌ Some services are unhealthy"
        return 1
    fi
}

# Main script logic
main() {
    local command=${1:-}
    
    case "$command" in
        "blue")
            switch_to "blue"
            ;;
        "green")
            switch_to "green"
            ;;
        "status")
            show_status
            ;;
        "health")
            check_all_health
            ;;
        "help"|"-h"|"--help")
            show_usage
            ;;
        "")
            show_status
            ;;
        *)
            error "Unknown command: $command"
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@" 