# Snowflake Infrastructure

A comprehensive Docker-based infrastructure stack providing observability, authorization, data storage, and development tools for Snowflake applications.

## 🏗️ Architecture Overview

This infrastructure stack provides a complete development and production environment with the following components:

- **Reverse Proxy & Load Balancer**: Traefik for routing and SSL termination
- **Observability Stack**: Prometheus, Grafana, Loki, and Alloy for monitoring and logging
- **Authorization Service**: OpenFGA for fine-grained access control
- **Data Storage**: PostgreSQL and Redis for persistent and cached data
- **Development Tools**: Bastion host with comprehensive debugging utilities

## 🚀 Services

| Service        | Description                        | Web Interface              | Internal Port |
| -------------- | ---------------------------------- | -------------------------- | ------------- |
| **Traefik**    | Reverse proxy and load balancer    | `http://traefik.localhost` | 8080          |
| **Grafana**    | Metrics and monitoring dashboards  | `http://grafana.localhost` | 3000          |
| **Prometheus** | Metrics collection and storage     | `http://prom.localhost`    | 9090          |
| **Loki**       | Log aggregation and storage        | `http://loki.localhost`    | 3100          |
| **Alloy**      | Telemetry data collection agent    | `http://alloy.localhost`   | 12345         |
| **OpenFGA**    | Fine-grained authorization service | `http://openfga.localhost` | 3000          |
| **PostgreSQL** | Primary database                   | -                          | 5432          |
| **Redis**      | Cache and session storage          | -                          | 6379          |
| **Bastion**    | SSH access and debugging tools     | SSH: `localhost:2222`      | 22            |

## 📋 Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- At least 4GB RAM available for containers
- SSH client (for bastion access)

## 🔧 Quick Start

### 1. Clone and Setup

```bash
git clone <repository-url>
cd snowflake-infra
```

### 2. Environment Configuration

Copy the example environment file and configure your settings:

```bash
cp .env.example .env
```

Edit `.env` with your configuration:

```bash
# PostgreSQL Configuration
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your-secure-password

# OpenFGA Configuration
OPENFGA_DATASTORE_ENGINE=postgres
OPENFGA_DATASTORE_URI=postgres://postgres:your-secure-password@postgres:5432/openfga?sslmode=disable
OPENFGA_PLAYGROUND_ENABLED=true
```

### 3. Start Services

```bash
# Start all services
docker compose up -d

# Or start specific services
docker compose up -d traefik grafana prometheus
```

### 4. Verify Installation

Check that all services are running:

```bash
docker compose ps
```

Visit the web interfaces:

- **Grafana**: http://grafana.localhost
- **Prometheus**: http://prom.localhost
- **Traefik Dashboard**: http://traefik.localhost
- **OpenFGA**: http://openfga.localhost

## 🔑 Access & Authentication

### SSH Access (Bastion Host)

The bastion host provides secure SSH access to the Docker network for debugging:

```bash
# SSH into bastion (password-less with SSH keys)
ssh -p 2222 snowflake@localhost

# Or using the container directly
docker exec -it snowflake-infra-bastion-1 bash
```

**SSH Key Setup**: Add your public SSH key to `authorized_keys` file in the repository root.

### Service Authentication

- **Grafana**: Default login `admin/admin` (change on first login)
- **OpenFGA**: No authentication by default (configure as needed)
- **Prometheus**: No authentication (internal service)

## 🛠️ Development & Debugging

### Bastion Host Tools

The bastion container includes comprehensive debugging tools:

```bash
# Network diagnostics
ping postgres
nmap redis
tcpdump -i any host grafana

# System monitoring
htop
iotop
lsof -i :5432

# API testing
curl -s http://grafana:3000/api/health | jq
curl http://prometheus:9090/api/v1/status/config
```

For detailed debugging guide, see: [`docs/bastion-debugging-guide.md`](docs/bastion-debugging-guide.md)

### Database Access

#### PostgreSQL

```bash
# From host (if port exposed)
psql -h localhost -p 5432 -U postgres

# From bastion host
psql -h postgres -U postgres -d openfga
```

**Available Databases:**

- `openfga` - OpenFGA authorization data
- `idms` - Identity management service (reserved)

#### Redis

```bash
# From bastion host
redis-cli -h redis
redis-cli -h redis ping
```

## 📊 Monitoring & Observability

### Metrics (Prometheus + Grafana)

- **Prometheus** collects metrics from all services
- **Grafana** provides visualization dashboards
- **Alloy** acts as a telemetry collector and forwarder

#### Key Metrics Endpoints:

- Container metrics: Automatically discovered via Docker labels
- Custom application metrics: Configure in `_config/prometheus/prometheus.yml`

### Logs (Loki)

- **Loki** aggregates logs from all Docker containers
- Access via Grafana's Explore view
- Query logs with LogQL: `{container_name="snowflake-infra-postgres-1"}`

### Alerting

Configure alerting rules in:

- Prometheus: `_config/prometheus/prometheus.yml`
- Grafana: Via the web interface

## 🔐 Authorization (OpenFGA)

OpenFGA provides fine-grained access control with relationship-based permissions:

```bash
# Example: Create a store
curl -X POST http://openfga.localhost/stores \
  -H "Content-Type: application/json" \
  -d '{"name": "my-app"}'

# Check authorization
curl -X POST http://openfga.localhost/stores/{store-id}/check \
  -H "Content-Type: application/json" \
  -d '{
    "tuple_key": {
      "user": "user:alice",
      "relation": "reader",
      "object": "document:roadmap"
    }
  }'
```

For detailed OpenFGA usage, visit: https://openfga.dev/docs

## ⚙️ Configuration

### Traefik

Configuration files in `_config/traefik/`:

- `traefik.yml` - Main Traefik configuration
- Add custom routes and middleware as needed

### Prometheus

Configuration in `_config/prometheus/prometheus.yml`:

- Service discovery via Docker labels
- Scrape targets and rules
- Remote write configuration

### Loki

Configuration in `_config/loki/loki-config.yaml`:

- Log retention policies
- Storage configuration
- API settings

### Alloy

Configuration in `_config/alloy/config.alloy`:

- Telemetry collection rules
- Data forwarding configuration
- Service discovery

## 🚀 Deployment

### Development

```bash
# Start with logs
docker compose up

# Start in background
docker compose up -d

# Restart specific service
docker compose restart grafana
```

### Production

1. **Security**:
   - Change default passwords
   - Configure proper authentication
   - Set up SSL certificates
   - Review network security

2. **Monitoring**:
   - Configure external alerting
   - Set up log retention policies
   - Monitor resource usage

3. **Backup**:
   - PostgreSQL data: `postgres_data` volume
   - Redis data: `redis_data` volume
   - Configuration files in `_config/`

## 🔄 Maintenance

### Updates

```bash
# Pull latest images
docker compose pull

# Restart with new images
docker compose up -d

# View logs
docker compose logs -f [service-name]
```

### Backup & Restore

#### Database Backup

```bash
# PostgreSQL backup
docker exec snowflake-infra-postgres-1 pg_dumpall -U postgres > backup.sql

# Redis backup
docker exec snowflake-infra-redis-1 redis-cli BGSAVE
```

#### Volume Backup

```bash
# Create volume backups
docker run --rm -v snowflake-infra_postgres_data:/data -v $(pwd):/backup ubuntu tar czf /backup/postgres_backup.tar.gz /data
```

### Cleanup

```bash
# Stop and remove containers
docker compose down

# Remove volumes (WARNING: destroys data)
docker compose down -v

# Remove images
docker compose down --rmi all
```

## 🐛 Troubleshooting

### Common Issues

#### Services Not Starting

```bash
# Check service status
docker compose ps

# View service logs
docker compose logs [service-name]

# Check resource usage
docker stats
```

#### Network Connectivity

```bash
# Test from bastion
docker exec -it snowflake-infra-bastion-1 bash
ping postgres
telnet redis 6379
```

#### Database Connection Issues

```bash
# Check PostgreSQL health
docker exec snowflake-infra-postgres-1 pg_isready -U postgres

# Check Redis connectivity
docker exec snowflake-infra-redis-1 redis-cli ping
```

### Performance Issues

- **High CPU**: Check `docker stats` and scale services if needed
- **Memory**: Monitor with `htop` from bastion host
- **Disk**: Check volume usage with `df -h`

### Service-Specific Issues

- **Grafana**: Check data source connections in web interface
- **Prometheus**: Verify targets in `/targets` endpoint
- **OpenFGA**: Check database migrations completed successfully
- **Traefik**: Verify routing rules and service discovery

## 📚 Additional Resources

- [Bastion Debugging Guide](docs/bastion-debugging-guide.md) - Comprehensive debugging tools and techniques
- [Grafana Documentation](https://grafana.com/docs/)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [OpenFGA Documentation](https://openfga.dev/docs)
- [Traefik Documentation](https://doc.traefik.io/traefik/)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

**Need Help?**

- Check the troubleshooting section above
- Review service logs: `docker compose logs [service]`
- SSH into bastion for network debugging: `ssh -p 2222 snowflake@localhost`
