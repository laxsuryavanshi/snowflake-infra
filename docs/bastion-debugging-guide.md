# Bastion Server Debugging Guide

This guide covers the diagnostic tools available in the bastion server for debugging applications on the Docker network.

## Network Diagnostics

### Basic Connectivity

```bash
# Test connectivity to services
ping postgres
ping redis
ping grafana

# Test specific ports
telnet postgres 5432
telnet redis 6379
nc -zv loki 3100
```

### Network Analysis

```bash
# Show network interfaces and routing
ip addr show
ip route show
netstat -rn

# List active connections
ss -tuln
netstat -tuln

# Check DNS resolution
dig postgres
nslookup grafana
host openfga
```

### Advanced Network Debugging

```bash
# Capture network traffic
tcpdump -i any host postgres
tcpdump -i any port 3100

# Scan for open ports on services
nmap postgres
nmap -p 1-1000 redis
nmap -sT grafana

# Trace network path
traceroute postgres
traceroute grafana
```

## Docker Network Inspection

### Container Information

```bash
# List Docker networks
docker network ls

# Inspect the snowflake network
docker network inspect snowflake-infra_snowflake-network

# List running containers
docker ps

# Check container logs
docker logs snowflake-infra-postgres-1
docker logs snowflake-infra-grafana-1 --tail 50
```

### Service Health Checks

```bash
# Check specific service endpoints
curl -I http://grafana:3000/api/health
curl -s http://loki:3100/ready
curl -s http://prometheus:9090/-/healthy
curl -s http://alloy:12345/-/healthy
```

## System Monitoring

### Process and Resource Monitoring

```bash
# Interactive process monitor
htop

# Check system resources
free -h
df -h
vmstat 1 5

# Monitor I/O
iotop

# List open files by process
lsof -p <pid>
lsof -i :22  # Files using port 22
```

### Application Debugging

```bash
# Trace system calls
strace -p <pid>
strace -e network curl http://grafana:3000

# Debug process behavior
ps aux | grep postgres
ps aux | grep grafana
```

## HTTP/API Testing

### REST API Testing

```bash
# Test Grafana API
curl -s http://grafana:3000/api/health | jq .

# Test OpenFGA API
curl -s http://openfga:3000/healthz

# Test Prometheus API
curl -s http://prometheus:9090/api/v1/status/config | jq .

# Test with authentication
curl -H "Authorization: Bearer token" http://service:port/api
```

### File Operations

```bash
# Download and analyze logs
wget http://loki:3100/loki/api/v1/query?query='{job="docker"}'

# Process JSON responses
curl -s http://prometheus:9090/api/v1/targets | jq '.data.activeTargets[] | select(.health != "up")'
```

## Common Debugging Scenarios

### Database Connection Issues

```bash
# Test PostgreSQL connection
telnet postgres 5432
# If successful, try psql (if installed):
# psql -h postgres -U postgres -d snowflake

# Check Redis connection
redis-cli -h redis ping
```

### Service Discovery Problems

```bash
# Verify DNS resolution in Docker network
dig postgres
dig +short grafana
nslookup redis

# Check if services are listening
nmap -sT postgres redis grafana
```

### Network Connectivity Issues

```bash
# Test inter-container communication
ping -c 3 postgres
traceroute postgres

# Check Docker network configuration
docker network inspect snowflake-infra_snowflake-network

# Monitor network traffic
tcpdump -i any -n host postgres and port 5432
```

### Performance Debugging

```bash
# Monitor system resources
htop
iotop -o

# Check network performance
ping -c 10 -i 0.1 postgres
curl -w "%{time_total}\n" -o /dev/null -s http://grafana:3000

# Trace application calls
strace -e trace=network,file curl http://grafana:3000
```

## Quick Reference Commands

```bash
# Network status overview
ss -tuln | grep LISTEN

# Service health check
for service in postgres redis grafana loki prometheus; do
  echo "=== $service ==="
  nc -zv $service 5432 2>/dev/null || nc -zv $service 6379 2>/dev/null || nc -zv $service 3000 2>/dev/null || echo "Check port"
done

# Docker containers status
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Resource usage summary
echo "=== CPU/Memory ==="
free -h
echo "=== Disk ==="
df -h /
echo "=== Network ==="
ip -brief addr show
```

## Tips for Effective Debugging

1. **Start with basic connectivity**: Use `ping` and `telnet` first
2. **Check DNS resolution**: Many issues are DNS-related in Docker networks
3. **Monitor logs**: Use `docker logs` to see application-specific errors
4. **Use JSON processing**: `jq` is invaluable for parsing API responses
5. **Network capture**: `tcpdump` can reveal protocol-level issues
6. **Resource monitoring**: Check if issues are resource-related with `htop`/`iotop`
