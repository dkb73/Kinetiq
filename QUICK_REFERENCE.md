# Quick Reference Card

## 🚀 Start Everything
```bash
# Windows
.\start-services.bat

# Linux/macOS
./start-services.sh
```

## 🌐 Access Points
- **Frontend + APIs**: http://localhost:8080
- **Direct Write API** (optional): http://localhost:3000
- **Direct Read API** (optional): http://localhost:3001

## 🔍 Common Commands

### Check Status
```bash
docker-compose ps
```

### View All Logs
```bash
docker-compose logs -f
```

### View Specific Service Logs
```bash
docker-compose logs -f frontend
docker-compose logs -f nginx
docker-compose logs -f write-api
docker-compose logs -f read-api
docker-compose logs -f worker
```

### Rebuild Frontend After Code Changes
```bash
docker-compose up -d --build frontend
# Wait 15 seconds, then refresh browser
```

### Rebuild Any Service
```bash
docker-compose up -d --build <service-name>
```

### Stop Everything
```bash
docker-compose down
```

### Stop and Remove All Data
```bash
docker-compose down -v
```

### Full Reset (Nuclear Option)
```bash
docker-compose down
docker volume rm distributed-ticket-system_postgres_data
docker volume rm distributed-ticket-system_mongo_data
docker volume rm distributed-ticket-system_frontend-build
docker system prune -a --volumes
# Then run start-services.bat again
```

## 🧪 Test API Endpoints

### Get All Events
```bash
curl http://localhost:8080/api/events
```

### Get Specific Event
```bash
curl http://localhost:8080/api/events/concert123
```

### Book a Ticket
```bash
curl -X POST http://localhost:8080/api/book \
  -H "Content-Type: application/json" \
  -d '{"userId":"user-123","eventId":"concert123","seatId":"A2"}'
```

## 📊 Monitoring

### Resource Usage
```bash
docker stats
```

### Check Container Health
```bash
docker-compose ps
```

### Inspect NGINX Config
```bash
docker exec -it <nginx-container-id> cat /etc/nginx/nginx.conf
```

### Check Frontend Build Files
```bash
docker exec -it <nginx-container-id> ls -la /usr/share/nginx/html
```

## 🐛 Troubleshooting

### Frontend Not Loading
1. Check frontend build logs:
   ```bash
   docker-compose logs frontend
   ```
2. Verify files exist in NGINX:
   ```bash
   docker exec -it <nginx-container> ls -la /usr/share/nginx/html
   ```
3. Rebuild frontend:
   ```bash
   docker-compose up -d --build frontend
   ```

### API Not Working
1. Check NGINX logs:
   ```bash
   docker-compose logs nginx
   ```
2. Test API directly:
   ```bash
   curl http://localhost:3001/api/events
   ```
3. Check service logs:
   ```bash
   docker-compose logs write-api
   docker-compose logs read-api
   ```

### Database Issues
1. Check database status:
   ```bash
   docker-compose ps postgres mongo
   ```
2. View database logs:
   ```bash
   docker-compose logs postgres
   docker-compose logs mongo
   ```

### Kafka Issues
1. Check Kafka health:
   ```bash
   docker-compose logs kafka
   ```
2. Verify Kafka topics:
   ```bash
   docker exec -it <kafka-container> kafka-topics --list --bootstrap-server localhost:9092
   ```

## 📦 Service Overview

| Service | Purpose | Port |
|---------|---------|------|
| frontend | React app builder | - |
| nginx | Gateway (frontend + API proxy) | 8080 |
| write-api | Booking requests | 3000 |
| read-api | Event queries | 3001 |
| worker | Background booking processor | - |
| data-sync-service | DB synchronization | - |
| postgres | Write database | 5432 |
| mongo | Read database | 27017 |
| redis | Distributed locking | 6379 |
| kafka | Message queue | 9092 |
| zookeeper | Kafka coordination | 2181 |

## 🎯 Key Files

- `docker-compose.yml` - Service orchestration
- `nginx/nginx.conf` - Gateway routing config
- `frontend/Dockerfile` - Frontend build config
- `start-services.bat` - Windows startup script
- `start-services.sh` - Linux/macOS startup script
- `DEPLOYMENT.md` - AWS deployment guide
- `README.md` - Full documentation

## ⚡ Pro Tips

1. **First time setup**: Allow 5-10 minutes for all images to download and build
2. **Frontend changes**: Always rebuild with `--build` flag
3. **Database reset**: Use `docker-compose down -v` to clear all data
4. **Logs**: Use `-f` flag to follow logs in real-time
5. **Production**: See DEPLOYMENT.md for AWS deployment strategies
