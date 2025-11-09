# Dokploy Deployment Guide - DirectApp with Autobase

**Last Updated**: 2025-11-09

Complete guide for deploying DirectApp to Dokploy with Autobase PostgreSQL cluster integration.

---

## Architecture Overview

**Hetzner VPS**: 157.180.125.91
- **Dokploy**: Container orchestration platform
- **Traefik**: Reverse proxy for HTTPS
- **Autobase**: PostgreSQL cluster (service name: `autobase`)
- **DirectApp**: This application (staging + production)

**Dokploy Network**:
- All services run in `dokploy-network`
- Internal service-to-service communication
- Traefik handles external HTTPS traffic

**Autobase Internal IPs** (within dokploy-network):
- Primary: 10.0.1.6:6432
- Replica: 10.0.1.7:6432

---

## Prerequisites

### 1. Autobase Service Running

Verify Autobase is deployed in Dokploy:

```bash
# SSH into Hetzner VPS
ssh root@157.180.125.91

# Check if Autobase is running
docker ps | grep autobase

# Test connection to Autobase primary
docker run --rm --network dokploy-network \
  -e PGPASSWORD='v5Kry76iPdEFUXOfxUlnswH77m68fAvI' \
  postgres:15.6 psql -h 10.0.1.6 -p 6432 -U postgres -c "SELECT version();"
```

**Expected**: Should show PostgreSQL version

### 2. Create Databases on Autobase

```bash
# Connect to Autobase
docker run --rm -it --network dokploy-network \
  -e PGPASSWORD='v5Kry76iPdEFUXOfxUlnswH77m68fAvI' \
  postgres:15.6 psql -h 10.0.1.6 -p 6432 -U postgres

# Create databases
CREATE DATABASE directapp_dev;
CREATE DATABASE directapp_staging;
CREATE DATABASE directapp_production;

# Verify
\l

# Exit
\q
```

### 3. Generate Security Keys

On your local machine:

```bash
# Generate Directus KEY (32 bytes)
openssl rand -base64 32

# Generate Directus SECRET (64 bytes)
openssl rand -base64 64
```

**Important**: Generate different keys for staging and production!

---

## Staging Deployment

### Step 1: Create Service in Dokploy

1. Log in to Dokploy: https://dokploy.your-domain.com
2. Navigate to your project
3. Click **"Create Service"**
4. Select **"Docker Compose"**
5. Name: `directapp-staging`

### Step 2: Configure Docker Compose

Paste `docker-compose.staging.yml` content into Dokploy:

```yaml
# Copy from docker-compose.staging.yml
# Or upload the file directly
```

### Step 3: Set Environment Variables

In Dokploy UI, add these environment variables:

**Database (Autobase)**:
```bash
DB_HOST=10.0.1.6
DB_PORT=6432
DB_DATABASE=directapp_staging
DB_USER=postgres
DB_PASSWORD=v5Kry76iPdEFUXOfxUlnswH77m68fAvI
```

**Directus Security** (use generated values):
```bash
DIRECTUS_KEY=<generated-32-byte-key>
DIRECTUS_SECRET=<generated-64-byte-secret>
```

**Admin Account** (first-time bootstrap only):
```bash
ADMIN_EMAIL=admin@staging-gapp.coms.no
ADMIN_PASSWORD=<your-secure-password>
```

**Application**:
```bash
PUBLIC_URL=https://staging-gapp.coms.no
CORS_ORIGIN=https://staging-gapp.coms.no
COOKIE_DOMAIN=.coms.no
```

**Email (Resend)**:
```bash
EMAIL_FROM=DirectApp Staging <noreply@coms.no>
RESEND_API_KEY=<your-resend-api-key>
```

**Storage (S3/R2/MinIO)** - Choose one:

```bash
# Option 1: AWS S3
STORAGE_LOCATIONS=s3
S3_ACCESS_KEY=<your-s3-key>
S3_SECRET_KEY=<your-s3-secret>
S3_BUCKET=directapp-staging
S3_REGION=eu-north-1

# Option 2: Cloudflare R2
STORAGE_LOCATIONS=s3
S3_ENDPOINT=https://<account-id>.r2.cloudflarestorage.com
S3_ACCESS_KEY=<r2-access-key>
S3_SECRET_KEY=<r2-secret-key>
S3_BUCKET=directapp-staging
S3_REGION=auto
```

**Norwegian Vehicle Registry**:
```bash
STATENS_VEGVESEN_TOKEN=<your-token>
```

**Optional (Monitoring)**:
```bash
SENTRY_DSN=<your-sentry-dsn>
```

### Step 4: Deploy

1. Click **"Deploy"** in Dokploy
2. Monitor logs for:
   ```
   Database connected successfully
   Server started at http://0.0.0.0:8055
   ```
3. Access: https://staging-gapp.coms.no

### Step 5: First-Time Setup

1. Log in with admin credentials
2. **IMPORTANT**: Change admin password immediately
3. Remove `ADMIN_EMAIL` and `ADMIN_PASSWORD` from environment variables
4. Redeploy service

### Step 6: Verify Traefik Labels

Ensure these labels are in docker-compose.staging.yml:

```yaml
labels:
  - "traefik.enable=true"
  - "traefik.http.routers.directapp-staging.rule=Host(`staging-gapp.coms.no`)"
  - "traefik.http.routers.directapp-staging.entrypoints=websecure"
  - "traefik.http.routers.directapp-staging.tls.certresolver=letsencrypt"
  - "traefik.http.routers.directapp-staging.service=directapp-staging-svc"
  - "traefik.http.services.directapp-staging-svc.loadbalancer.server.port=8055"
  - "traefik.docker.network=dokploy-network"
```

---

## Production Deployment

**CRITICAL**: Production deployment requires extra care!

### Pre-Deployment Checklist

- [ ] Staging environment fully tested
- [ ] All migrations tested on staging
- [ ] Security keys generated (different from staging)
- [ ] Backup strategy confirmed
- [ ] Monitoring configured (Sentry recommended)
- [ ] Admin password strong and unique
- [ ] S3 bucket for production created
- [ ] Email sending configured and tested
- [ ] Norwegian Vehicle Registry token valid
- [ ] Database `directapp_production` created on Autobase

### Step 1: Create Production Service

1. In Dokploy, create new service: `directapp-production`
2. Use `docker-compose.production.yml`

### Step 2: Set Environment Variables

**Use different values from staging!**

```bash
# Database
DB_HOST=10.0.1.6
DB_PORT=6432
DB_DATABASE=directapp_production
DB_USER=postgres
DB_PASSWORD=v5Kry76iPdEFUXOfxUlnswH77m68fAvI

# Directus Security (DIFFERENT from staging)
DIRECTUS_KEY=<new-generated-key>
DIRECTUS_SECRET=<new-generated-secret>

# Admin (remove after first deploy)
ADMIN_EMAIL=admin@gapp.coms.no
ADMIN_PASSWORD=<strong-unique-password>

# Application
PUBLIC_URL=https://gapp.coms.no
CORS_ORIGIN=https://gapp.coms.no
COOKIE_DOMAIN=.coms.no

# Email
EMAIL_FROM=DirectApp <noreply@coms.no>
RESEND_API_KEY=<production-resend-key>

# Storage
S3_BUCKET=directapp-production
# ... other S3 settings

# Norwegian Vehicle Registry
STATENS_VEGVESEN_TOKEN=<production-token>

# Monitoring (REQUIRED for production)
SENTRY_DSN=<production-sentry-dsn>
```

### Step 3: Deploy Production

1. Double-check all environment variables
2. Click **"Deploy"**
3. Monitor logs carefully
4. Test all critical functionality

### Step 4: Post-Deployment

1. Log in and change admin password
2. Remove `ADMIN_EMAIL` and `ADMIN_PASSWORD`
3. Create regular user accounts
4. Configure RBAC roles
5. Test all workflows
6. Set up monitoring dashboards

---

## Local Development with SSH Tunnel

For local development, create an SSH tunnel to access Autobase:

### One-Time Setup

```bash
# Create SSH key if you don't have one
ssh-keygen -t ed25519 -C "directapp-dev"

# Copy public key to Hetzner VPS
ssh-copy-id root@157.180.125.91
```

### Start Development Session

```bash
# 1. Create SSH tunnel (run in separate terminal)
ssh -L 5432:10.0.1.6:6432 root@157.180.125.91 -N

# 2. Copy .env.example to .env
cp .env.example .env

# 3. Verify .env has correct settings:
#    DB_HOST=localhost
#    DB_PORT=5432
#    DB_DATABASE=directapp_dev

# 4. Start DirectApp
docker compose -f docker-compose.dev.yml up
```

**Access**: http://localhost:8055

### Stop Development Session

```bash
# Stop DirectApp
docker compose -f docker-compose.dev.yml down

# Stop SSH tunnel (Ctrl+C in tunnel terminal)
```

---

## Database Migrations

### Export from Pilot Production

If migrating from existing Directus instance (gumpen.coms.no):

```bash
# Export schema from pilot
npx directus schema snapshot --host https://gumpen.coms.no --token <admin-token> ./schema-pilot.yaml

# Apply to Autobase (via SSH tunnel)
npx directus schema apply --host http://localhost:8055 --token <admin-token> ./schema-pilot.yaml
```

### Manual Migration

```bash
# Export from pilot
pg_dump -h pilot-host -U pilot-user -d pilot-db \
  --schema-only --no-owner --no-acl -f schema.sql

# Import to Autobase (via SSH tunnel)
psql -h localhost -p 5432 -U postgres -d directapp_dev < schema.sql
```

---

## Monitoring & Debugging

### Check Service Logs (Dokploy)

1. Go to Dokploy UI
2. Select `directapp-staging` or `directapp-production`
3. Click **"Logs"** tab
4. Filter for errors

### Check Database Connection

```bash
# SSH into Hetzner VPS
ssh root@157.180.125.91

# Test Autobase connection from DirectApp container
docker exec -it directapp-staging sh
apk add postgresql-client
psql -h 10.0.1.6 -p 6432 -U postgres -d directapp_staging
```

### Common Issues

**Issue**: "Connection refused to 10.0.1.6:6432"

**Solution**:
- Check Autobase service is running: `docker ps | grep autobase`
- Verify both services in `dokploy-network`
- Check Autobase logs: `docker logs <autobase-container-id>`

**Issue**: "Database does not exist"

**Solution**:
- Create database manually (see Prerequisites section)
- Check `DB_DATABASE` environment variable matches

**Issue**: "Password authentication failed"

**Solution**:
- Verify `DB_PASSWORD` matches Autobase cluster password
- Check `DB_USER` is correct (likely `postgres`)

---

## Rollback Procedure

If deployment fails:

### Via Dokploy UI

1. Go to service in Dokploy
2. Click **"Deployments"** tab
3. Find previous successful deployment
4. Click **"Redeploy"**

### Manual Rollback

```bash
# SSH into VPS
ssh root@157.180.125.91

# List containers
docker ps -a | grep directapp

# Stop current version
docker stop directapp-staging

# Start previous version (if still exists)
docker start <previous-container-id>
```

---

## Backup & Restore

### Automated Backups (Recommended)

Autobase cluster should handle automated backups. Verify with your administrator:
- Backup frequency
- Retention period
- Restoration procedure

### Manual Backup

```bash
# From Hetzner VPS
docker run --rm --network dokploy-network \
  -e PGPASSWORD='v5Kry76iPdEFUXOfxUlnswH77m68fAvI' \
  -v $(pwd):/backup \
  postgres:15.6 pg_dump \
    -h 10.0.1.6 -p 6432 -U postgres \
    -d directapp_production \
    -F c -f /backup/directapp_prod_$(date +%Y%m%d).dump
```

### Restore from Backup

```bash
docker run --rm --network dokploy-network \
  -e PGPASSWORD='v5Kry76iPdEFUXOfxUlnswH77m68fAvI' \
  -v $(pwd):/backup \
  postgres:15.6 pg_restore \
    -h 10.0.1.6 -p 6432 -U postgres \
    -d directapp_production \
    -c /backup/directapp_prod_20251109.dump
```

---

## Security Best Practices

### Environment Variables

- ✅ Store secrets in Dokploy secrets UI (not docker-compose.yml)
- ✅ Use different keys for staging and production
- ✅ Rotate keys periodically
- ✅ Never commit secrets to git

### Database Access

- ✅ Create dedicated database user (not `postgres`) for production
- ✅ Use strong passwords (32+ characters)
- ✅ Limit database access to dokploy-network only
- ✅ Enable database audit logging

### Network Security

- ✅ Autobase NOT exposed externally (dokploy-network only)
- ✅ All HTTP traffic via Traefik with HTTPS
- ✅ CORS configured for specific domains only
- ✅ Rate limiting enabled in production

### Application Security

- ✅ Strong admin password
- ✅ Change default admin credentials immediately
- ✅ Remove `ADMIN_EMAIL`/`ADMIN_PASSWORD` after first deploy
- ✅ Implement RBAC with Norwegian roles
- ✅ Enable 2FA for admin users (if Directus supports)

---

## Performance Tuning

### Database Connection Pooling

For production, consider adding PgBouncer:

```yaml
# Add to docker-compose.production.yml
pgbouncer:
  image: edoburu/pgbouncer:latest
  container_name: directapp-pgbouncer
  restart: unless-stopped
  networks:
    - dokploy-network
  environment:
    DB_HOST: 10.0.1.6
    DB_PORT: 6432
    DB_USER: postgres
    DB_PASSWORD: ${DB_PASSWORD}
    POOL_MODE: transaction
    MAX_CLIENT_CONN: 1000
    DEFAULT_POOL_SIZE: 20
```

Then update Directus to connect to PgBouncer instead of Autobase directly.

### Redis Memory Limits

Adjust Redis memory based on usage:

```yaml
redis:
  command:
    - "redis-server"
    - "--maxmemory"
    - "512mb"  # Increase if needed
```

### Directus Workers

For heavy workloads, add dedicated worker containers (future enhancement).

---

## Maintenance Windows

### Scheduled Maintenance

1. Announce maintenance window to users
2. Put application in maintenance mode (if Directus supports)
3. Stop accepting new requests
4. Backup database
5. Perform updates
6. Test thoroughly
7. Resume normal operations

### Zero-Downtime Deployment

For critical production systems:

1. Deploy new version alongside old version
2. Run health checks
3. Switch Traefik routing to new version
4. Monitor for errors
5. Keep old version running for quick rollback
6. Remove old version after confirmation

---

## Support & Troubleshooting

### Logs Location

**Dokploy UI**: Most convenient
**Docker**: `docker logs <container-name>`
**Sentry**: Production error tracking

### Health Checks

**Directus Health Endpoint**:
```bash
curl https://staging-gapp.coms.no/server/health
```

**Database Connection**:
```bash
# From within DirectApp container
curl http://localhost:8055/server/health
```

### Performance Monitoring

**Database Queries**:
```sql
-- Check slow queries
SELECT
  query,
  mean_exec_time,
  calls
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;
```

**Redis Stats**:
```bash
docker exec -it directapp-staging-redis redis-cli INFO stats
```

---

**Last Updated**: 2025-11-09
**Maintained By**: DirectApp Team
**Deployment Platform**: Dokploy on Hetzner VPS 157.180.125.91
