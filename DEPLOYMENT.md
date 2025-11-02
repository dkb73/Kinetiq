# Deployment Guide

## Architecture Overview

The application uses a **production-ready architecture** where:
- **Frontend**: React app built with Vite, served as static files
- **NGINX Gateway**: Single entry point (port 8080) that:
  - Serves frontend static files (HTML, CSS, JS)
  - Proxies API requests to backend microservices
- **Backend Services**: Multiple Node.js microservices handling different concerns

This is the **industry-standard approach** for deploying microservices with a frontend.

## How It Works

1. **Frontend Build Process**:
   - Docker builds the React app using a multi-stage Dockerfile
   - Build artifacts are stored in a Docker volume (`frontend-build`)
   - NGINX mounts this volume to serve the static files

2. **Request Routing**:
   - Browser requests `http://localhost:8080` → NGINX serves `index.html`
   - Browser requests `http://localhost:8080/api/events` → NGINX proxies to `read-api:3001`
   - Browser requests `http://localhost:8080/api/book` → NGINX proxies to `write-api:3000`

3. **No Separate Frontend Server Needed**:
   - Unlike development mode (`npm run dev`), production serves pre-built static files
   - Faster, more secure, and deployment-ready

## Local Development & Testing

### Start the System
```bash
# Windows
.\start-services.bat

# Linux/macOS
chmod +x start-services.sh
./start-services.sh
```

### Access the Application
- **Frontend + APIs**: http://localhost:8080
- **Direct API Testing** (optional):
  - Write API: http://localhost:3000
  - Read API: http://localhost:3001

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f frontend
docker-compose logs -f nginx
docker-compose logs -f write-api
```

### Rebuild Frontend After Code Changes
```bash
# Rebuild and restart frontend
docker-compose up -d --build frontend

# Wait a few seconds for build to complete
# NGINX will automatically serve the new build
```

## AWS Deployment Strategy

### Option 1: EC2 with Docker Compose (Simplest)
**Best for**: Learning, small-scale deployments

1. **Launch EC2 Instance**:
   - Instance type: t3.medium or larger (2 vCPU, 4GB RAM minimum)
   - OS: Amazon Linux 2 or Ubuntu 22.04
   - Security Group: Open ports 80, 443, 22

2. **Install Docker**:
   ```bash
   # Amazon Linux 2
   sudo yum update -y
   sudo yum install docker -y
   sudo service docker start
   sudo usermod -a -G docker ec2-user
   
   # Install Docker Compose
   sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   ```

3. **Deploy Application**:
   ```bash
   git clone <your-repo>
   cd distributed-ticket-system
   ./start-services.sh
   ```

4. **Configure Domain** (optional):
   - Point your domain to EC2 public IP
   - Update NGINX config for SSL/TLS with Let's Encrypt

### Option 2: ECS with Fargate (Production-Ready)
**Best for**: Scalable, managed deployments

1. **Create ECR Repositories** for each service:
   ```bash
   aws ecr create-repository --repository-name ticket-frontend
   aws ecr create-repository --repository-name ticket-write-api
   aws ecr create-repository --repository-name ticket-read-api
   # ... etc
   ```

2. **Build and Push Images**:
   ```bash
   # Login to ECR
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
   
   # Build and push frontend
   docker build -t ticket-frontend ./frontend
   docker tag ticket-frontend:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/ticket-frontend:latest
   docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/ticket-frontend:latest
   ```

3. **Create ECS Task Definitions** for each service

4. **Set up Application Load Balancer** to route traffic

5. **Use RDS, ElastiCache, MSK** instead of containerized databases

### Option 3: Kubernetes (EKS)
**Best for**: Large-scale, enterprise deployments

- Convert docker-compose.yml to Kubernetes manifests
- Use Helm charts for easier management
- Implement Horizontal Pod Autoscaling

## Environment Variables for Production

Create a `.env` file for production:

```env
# Database
POSTGRES_HOST=<RDS-endpoint>
POSTGRES_USER=<user>
POSTGRES_PASSWORD=<secure-password>
MONGO_URI=mongodb://<DocumentDB-endpoint>

# Kafka
KAFKA_BROKER=<MSK-endpoint>

# Redis
REDIS_URL=redis://<ElastiCache-endpoint>

# Frontend
NODE_ENV=production
```

## Security Checklist

- [ ] Change default database passwords
- [ ] Enable HTTPS/SSL (use Let's Encrypt or AWS Certificate Manager)
- [ ] Set up proper CORS policies
- [ ] Enable authentication/authorization
- [ ] Use AWS Secrets Manager for sensitive data
- [ ] Configure security groups to allow only necessary ports
- [ ] Enable CloudWatch logging
- [ ] Set up monitoring and alerts

## Monitoring & Logging

### Local Development
```bash
# Check service health
docker-compose ps

# View resource usage
docker stats

# Check specific service logs
docker-compose logs -f <service-name>
```

### Production (AWS)
- **CloudWatch**: Centralized logging and metrics
- **X-Ray**: Distributed tracing
- **Prometheus + Grafana**: Custom metrics dashboards

## Troubleshooting

### Frontend Not Loading
```bash
# Check if frontend build completed
docker-compose logs frontend

# Check if NGINX is serving files
docker exec -it <nginx-container> ls -la /usr/share/nginx/html

# Rebuild frontend
docker-compose up -d --build frontend
```

### API Requests Failing
```bash
# Check NGINX routing
docker-compose logs nginx

# Test API directly
curl http://localhost:3001/api/events
```

### Database Connection Issues
```bash
# Check database health
docker-compose ps postgres mongo

# View database logs
docker-compose logs postgres
docker-compose logs mongo
```

## Cost Optimization (AWS)

1. **Use Reserved Instances** for predictable workloads
2. **Auto-scaling** for variable traffic
3. **Spot Instances** for non-critical services
4. **CloudFront CDN** for static asset delivery
5. **S3** for frontend static files (alternative to NGINX)

## Next Steps

1. ✅ Test locally with `.\start-services.bat`
2. ✅ Verify frontend loads at http://localhost:8080
3. ✅ Test API endpoints
4. 📝 Set up CI/CD pipeline (GitHub Actions, AWS CodePipeline)
5. 🚀 Deploy to AWS using one of the strategies above
6. 🔒 Implement authentication and authorization
7. 📊 Set up monitoring and alerting
