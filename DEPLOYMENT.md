# ZeroShift Deployment Guide

This guide provides step-by-step instructions for deploying and managing the ZeroShift blue-green deployment infrastructure.

## Quick Deployment

### 1. Local Development Setup

```bash
# Clone the repository
git clone https://github.com/jjacobsonn/ZeroShift.git
cd ZeroShift

# Quick start (builds, tests, and starts all services)
make quick-start

# Check status
make status
```

### 2. Manual Setup

```bash
# Build and test
make test
make docker-build

# Start services
make docker-up

# Check deployment status
make status
```

## Accessing the Application

Once deployed, you can access the application at:

- **Main Application**: http://localhost
- **Blue Service**: http://localhost:8081
- **Green Service**: http://localhost:8082
- **Health Check**: http://localhost/health

## Blue-Green Switching

### Manual Switching

```bash
# Switch to blue environment
make switch-blue

# Switch to green environment
make switch-green

# Check current status
make status
```

### Using the Switch Script Directly

```bash
cd deploy

# Switch to blue
./switch.sh blue

# Switch to green
./switch.sh green

# Show status
./switch.sh status

# Check health
./switch.sh health
```

## Docker Management

### Service Management

```bash
# Start all services
make docker-up

# Stop all services
make docker-down

# View logs
make logs
make logs-blue
make logs-green
make logs-proxy
```

### Individual Container Management

```bash
# View running containers
docker ps

# View container logs
docker logs zeroshift-blue
docker logs zeroshift-green
docker logs zeroshift-proxy

# Execute commands in containers
docker exec -it zeroshift-blue sh
docker exec -it zeroshift-green sh
docker exec -it zeroshift-proxy sh
```

## Testing

### Run Tests

```bash
# Run all tests
make test

# Test individual services
cd blue && go test -v
cd green && go test -v
```

### Manual Testing

```bash
# Test health endpoints
curl http://localhost:8081/health
curl http://localhost:8082/health
curl http://localhost/health

# Test main endpoints
curl http://localhost:8081/
curl http://localhost:8082/
curl http://localhost/

# Test with jq for formatted output
curl -s http://localhost/ | jq
curl -s http://localhost:8081/health | jq
```

## Configuration

### Environment Variables

The services can be configured using environment variables:

```bash
# Blue service port
export PORT=8081

# Green service port
export PORT=8082
```

### Docker Compose Configuration

Edit `deploy/docker-compose.yml` to modify:

- Port mappings
- Environment variables
- Health check settings
- Resource limits

### Nginx Configuration

Edit `proxy/nginx.conf` to modify:

- Upstream configurations
- Proxy settings
- SSL/TLS settings
- Logging configuration

## Troubleshooting

### Common Issues

1. **Services not starting**
   ```bash
   # Check Docker logs
   make logs
   
   # Check individual service logs
   make logs-blue
   make logs-green
   make logs-proxy
   ```

2. **Health checks failing**
   ```bash
   # Check if services are responding
   curl -v http://localhost:8081/health
   curl -v http://localhost:8082/health
   
   # Check container status
   docker ps
   docker inspect zeroshift-blue
   ```

3. **Switch not working**
   ```bash
   # Check current status
   make status
   
   # Check nginx configuration
   docker exec zeroshift-proxy nginx -t
   
   # Check live.txt file
   cat deploy/live.txt
   ```

4. **Port conflicts**
   ```bash
   # Check what's using the ports
   lsof -i :80
   lsof -i :8081
   lsof -i :8082
   
   # Stop conflicting services
   sudo lsof -ti:80 | xargs kill -9
   ```

### Debug Mode

```bash
# Start services in debug mode
docker-compose -f deploy/docker-compose.yml up

# Check detailed logs
docker-compose -f deploy/docker-compose.yml logs -f --tail=100
```

## Security Considerations

### Production Deployment

1. **Use HTTPS**: Configure SSL/TLS certificates
2. **Network Security**: Use proper firewall rules
3. **Secrets Management**: Use environment variables or secrets
4. **Regular Updates**: Keep Docker images updated
5. **Monitoring**: Set up proper monitoring and alerting

### Security Best Practices

```bash
# Run security scans
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image zeroshift-blue:latest

# Check for vulnerabilities
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy fs .
```

## Monitoring

### Health Monitoring

```bash
# Set up health monitoring
while true; do
  curl -f http://localhost/health || echo "Health check failed"
  sleep 30
done
```

### Metrics Collection

Consider adding metrics collection:

- Prometheus for metrics
- Grafana for visualization
- ELK stack for logging

## CI/CD Integration

### GitHub Actions

The project includes GitHub Actions workflows for:

- Automated testing
- Security scanning
- Docker image building
- Deployment to staging/production

### Manual Deployment

```bash
# Build new images
make docker-build

# Deploy to staging
make docker-up

# Test staging
make health

# Switch to new version
make switch-green  # or make switch-blue
```

## Logging

### View Logs

```bash
# All services
make logs

# Individual services
make logs-blue
make logs-green
make logs-proxy

# Follow logs in real-time
docker-compose -f deploy/docker-compose.yml logs -f
```

### Log Configuration

Logs are configured in:

- `proxy/nginx.conf` - Nginx access and error logs
- Go services - Standard output logging
- Docker Compose - Container logging

## Support

### Getting Help

1. Check the logs: `make logs`
2. Verify configuration: `make status`
3. Test connectivity: `make health`
4. Review documentation: `README.md`

### Common Commands Reference

```bash
# Essential commands
make help          # Show all available commands
make status        # Check deployment status
make health        # Check service health
make switch-blue   # Switch to blue environment
make switch-green  # Switch to green environment
make logs          # View all logs
make docker-down   # Stop all services
make docker-up     # Start all services
```

---

For more information, see the main [README.md](README.md) file. 