# Self-hosted AI Starter Kit with ngrok for VPS

This setup provides a self-hosted AI development environment with n8n, Ollama, Qdrant, and ngrok tunneling for VPS deployment.

## Prerequisites

- VPS with:
  - Ubuntu 20.04 LTS or newer
  - 4GB+ RAM (8GB recommended)
  - 2+ CPU cores
  - 20GB+ storage

## Installation Steps

1. **Install Docker and Docker Compose**
   ```bash
   # Update system
   sudo apt update && sudo apt upgrade -y

   # Install Docker
   curl -fsSL https://get.docker.com -o get-docker.sh
   sudo sh get-docker.sh

   # Install Docker Compose
   sudo apt install docker-compose -y

   # Add user to docker group
   sudo usermod -aG docker $USER
   ```

2. **Clone this repository**
   ```bash
   git clone <your-repo-url>
   cd <repo-directory>
   ```

3. **Configure environment variables**
   ```bash
   # Copy example env file
   cp .env.example .env

   # Edit .env file with your settings
   nano .env
   ```

4. **Configure ngrok**
   ```bash
   # Copy example ngrok config
   cp ngrok.yml.example ngrok.yml

   # Edit ngrok.yml with your settings
   nano ngrok.yml
   ```

5. **Start the services**
   ```bash
   # Start all services
   docker-compose up -d

   # Check logs
   docker-compose logs -f
   ```

## Accessing the Services

- n8n: http://localhost:5678 (or via ngrok URL)
- ngrok Dashboard: http://localhost:4040
- Ollama API: http://localhost:11434
- Qdrant API: http://localhost:6333

## CPU-Specific Optimizations

The setup is configured for CPU-only usage with the following optimizations:

- Ollama:
  - Limited to 2 CPU cores
  - 4GB memory limit
  - Optimized for CPU inference

- Qdrant:
  - Limited to 1 CPU core
  - 2GB memory limit
  - Optimized storage settings for CPU

## Security Considerations

1. Change all default passwords in the `.env` file
2. Use strong passwords for all services
3. Consider setting up a firewall (UFW)
4. Keep your system and Docker images updated
5. Monitor your ngrok usage and limits

## Maintenance

### Updating Services
```bash
# Pull latest images
docker-compose pull

# Restart services
docker-compose up -d
```

### Backup
```bash
# Backup volumes
docker run --rm -v $(pwd):/backup -v n8n_data:/data alpine tar czf /backup/n8n_backup.tar.gz /data
docker run --rm -v $(pwd):/backup -v postgres_data:/data alpine tar czf /backup/postgres_backup.tar.gz /data
```

### Monitoring
```bash
# View logs
docker-compose logs -f

# Check container status
docker-compose ps

# Monitor CPU and memory usage
docker stats
```

## Troubleshooting

1. Check container logs: `docker-compose logs <service-name>`
2. Verify environment variables: `docker-compose config`
3. Check ngrok status: `docker-compose logs ngrok`
4. Monitor system resources: `htop` or `top`

## Support

For issues and support:
- n8n: https://community.n8n.io/
- Ollama: https://github.com/ollama/ollama
- Qdrant: https://github.com/qdrant/qdrant
- ngrok: https://ngrok.com/docs 