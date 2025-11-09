# Autobase PostgreSQL Cluster Setup

**Last Updated**: 2025-11-09

This document explains how DirectApp uses the Autobase PostgreSQL cluster instead of local PostgreSQL containers.

---

## Cluster Details

**Autobase PostgreSQL Cluster Configuration:**

| Component | Value |
|-----------|-------|
| **Primary Address** | 10.0.1.6 |
| **Replica Address** | 10.0.1.7 |
| **Port** | 6432 |
| **User** | postgres |
| **Password** | `v5Kry76iPdEFUXOfxUlnswH77m68fAvI` |

**Architecture:**
- Primary/Replica setup for high availability
- Port 6432 (non-standard PostgreSQL port)
- Currently using primary only (replica available for read scaling)

---

## Database Structure

Three separate databases on the same cluster:

| Environment | Database Name | Purpose |
|-------------|--------------|---------|
| **Development** | `directapp_dev` | Local development with hot reload |
| **Staging** | `directapp_staging` | Testing deployment (staging-gapp.coms.no) |
| **Production** | `directapp_production` | Live production (gapp.coms.no) |

---

## First-Time Setup

### 1. Create Databases on Autobase Cluster

Connect to the Autobase primary and create the three databases:

```bash
# Connect to Autobase cluster
psql -h 10.0.1.6 -p 6432 -U postgres

# Create databases
CREATE DATABASE directapp_dev;
CREATE DATABASE directapp_staging;
CREATE DATABASE directapp_production;

# Verify
\l

# Exit
\q
```

**Optional: Create dedicated user (recommended for production)**

```sql
-- Create dedicated user
CREATE USER directapp WITH PASSWORD 'your-secure-password-here';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE directapp_dev TO directapp;
GRANT ALL PRIVILEGES ON DATABASE directapp_staging TO directapp;
GRANT ALL PRIVILEGES ON DATABASE directapp_production TO directapp;

-- If using dedicated user, update docker-compose files:
-- DB_USER: directapp (instead of postgres)
```

### 2. Configure Local Development

```bash
# Copy environment template
cp .env.example .env

# Edit .env if needed (default values point to Autobase)
# The .env.example already has the correct Autobase configuration

# Start development environment
docker compose -f docker-compose.dev.yml up
```

**First startup:**
- Directus will connect to `directapp_dev` on Autobase cluster
- Initial migrations will create all tables
- Admin account created (admin@dev.local / admin)
- Access: http://localhost:8055

### 3. Configure Staging (Dokploy)

In Dokploy UI for staging service:

**Environment Variables:**
```bash
# Database (Autobase)
DB_HOST=10.0.1.6
DB_PORT=6432
DB_DATABASE=directapp_staging
DB_USER=postgres
DB_PASSWORD=v5Kry76iPdEFUXOfxUlnswH77m68fAvI

# Directus Security (GENERATE NEW VALUES)
DIRECTUS_KEY=$(openssl rand -base64 32)
DIRECTUS_SECRET=$(openssl rand -base64 64)

# Admin Bootstrap (remove after first deploy)
ADMIN_EMAIL=admin@staging-gapp.coms.no
ADMIN_PASSWORD=your-secure-admin-password

# Application
PUBLIC_URL=https://staging-gapp.coms.no

# Add other required variables...
```

### 4. Configure Production (Dokploy)

In Dokploy UI for production service:

**Environment Variables:**
```bash
# Database (Autobase)
DB_HOST=10.0.1.6
DB_PORT=6432
DB_DATABASE=directapp_production
DB_USER=postgres
DB_PASSWORD=v5Kry76iPdEFUXOfxUlnswH77m68fAvI

# Directus Security (GENERATE NEW VALUES - DIFFERENT FROM STAGING)
DIRECTUS_KEY=$(openssl rand -base64 32)
DIRECTUS_SECRET=$(openssl rand -base64 64)

# Admin Bootstrap (remove after first deploy)
ADMIN_EMAIL=admin@gapp.coms.no
ADMIN_PASSWORD=your-secure-admin-password

# Application
PUBLIC_URL=https://gapp.coms.no

# Add other required variables...
```

---

## Benefits of Autobase Cluster

**✅ Advantages:**

1. **Centralized Database Management**
   - Single cluster for all environments
   - Professional database hosting
   - Easier backups and maintenance

2. **High Availability**
   - Primary/Replica setup
   - Automatic failover (if configured)
   - Read scaling capability

3. **Reduced Docker Overhead**
   - No PostgreSQL containers to manage
   - Faster container startup
   - Less disk space usage

4. **Data Persistence**
   - Database survives container recreation
   - Easy migration between environments
   - Centralized backup strategy

**⚠️ Considerations:**

1. **Network Dependency**
   - Local development requires network access to Autobase cluster
   - Cannot work offline (unlike local PostgreSQL container)

2. **Security**
   - Ensure Autobase cluster allows connections from Docker host
   - Consider firewall rules for production access
   - Use dedicated database user (not `postgres`) for production

3. **Shared Resources**
   - All environments share the same cluster
   - Monitor resource usage
   - Consider connection pooling (PgBouncer) if needed

---

## Connection Testing

### Test from Host Machine

```bash
# Install PostgreSQL client if not already installed
sudo apt-get install postgresql-client

# Test connection to Autobase primary
psql -h 10.0.1.6 -p 6432 -U postgres -d directapp_dev -c "SELECT version();"

# Test connection to replica (read-only)
psql -h 10.0.1.7 -p 6432 -U postgres -d directapp_dev -c "SELECT version();"
```

### Test from Docker Container

```bash
# Start a test PostgreSQL container
docker run -it --rm postgres:15.6 psql -h 10.0.1.6 -p 6432 -U postgres -d directapp_dev

# If successful, you should see the PostgreSQL prompt
directapp_dev=#
```

---

## Backup Strategy

### Option 1: Autobase Cluster Backups (Recommended)

If Autobase cluster has automated backups configured, rely on those:
- Check with your Autobase administrator
- Ensure backup schedule meets your RPO (Recovery Point Objective)
- Verify backup restoration process

### Option 2: Manual Database Dumps

For additional safety, create periodic dumps:

```bash
# Dump development database
pg_dump -h 10.0.1.6 -p 6432 -U postgres directapp_dev -F c -f directapp_dev_$(date +%Y%m%d).dump

# Dump staging database
pg_dump -h 10.0.1.6 -p 6432 -U postgres directapp_staging -F c -f directapp_staging_$(date +%Y%m%d).dump

# Dump production database (CRITICAL - schedule daily)
pg_dump -h 10.0.1.6 -p 6432 -U postgres directapp_production -F c -f directapp_production_$(date +%Y%m%d).dump

# Restore from dump
pg_restore -h 10.0.1.6 -p 6432 -U postgres -d directapp_dev directapp_dev_20251109.dump
```

### Option 3: Continuous Archiving

For production, consider setting up WAL archiving:
- Work with Autobase administrator
- Configure Point-in-Time Recovery (PITR)
- Test restoration regularly

---

## Migration from Local PostgreSQL

If you previously had data in local PostgreSQL containers:

```bash
# 1. Dump existing local database
docker exec directapp-dev-postgres pg_dump -U directus directapp_dev -F c -f /tmp/local_dump.dump
docker cp directapp-dev-postgres:/tmp/local_dump.dump ./local_dump.dump

# 2. Restore to Autobase cluster
pg_restore -h 10.0.1.6 -p 6432 -U postgres -d directapp_dev -c local_dump.dump

# 3. Verify data
psql -h 10.0.1.6 -p 6432 -U postgres -d directapp_dev -c "\dt"

# 4. Remove old PostgreSQL containers and volumes
docker compose -f docker-compose.dev.yml down -v
```

---

## Troubleshooting

### Connection Refused

**Error:** `FATAL: connection refused`

**Solutions:**
1. Check Autobase cluster is running
2. Verify firewall allows connections from your IP
3. Ensure port 6432 is accessible
4. Test with `telnet 10.0.1.6 6432`

### Authentication Failed

**Error:** `FATAL: password authentication failed`

**Solutions:**
1. Verify DB_PASSWORD in .env matches Autobase password
2. Check DB_USER is correct (postgres)
3. Ensure pg_hba.conf allows connections from Docker network

### Database Does Not Exist

**Error:** `FATAL: database "directapp_dev" does not exist`

**Solutions:**
1. Create database manually (see First-Time Setup)
2. Verify DB_DATABASE environment variable
3. Check you're connecting to correct host/port

### SSL/TLS Issues

**Error:** `SSL connection has been closed unexpectedly`

**Solutions:**
1. Add `DB_SSL=false` to environment if Autobase doesn't use SSL
2. Or configure SSL certificates if required
3. Check Autobase cluster SSL configuration

---

## Monitoring

### Connection Monitoring

```sql
-- Check active connections
SELECT
  datname,
  count(*) as connections
FROM pg_stat_activity
WHERE datname IN ('directapp_dev', 'directapp_staging', 'directapp_production')
GROUP BY datname;

-- Check long-running queries
SELECT
  pid,
  now() - query_start as duration,
  state,
  query
FROM pg_stat_activity
WHERE state != 'idle'
  AND now() - query_start > interval '5 minutes';
```

### Database Size

```sql
SELECT
  datname,
  pg_size_pretty(pg_database_size(datname)) as size
FROM pg_database
WHERE datname IN ('directapp_dev', 'directapp_staging', 'directapp_production');
```

---

## Future Enhancements

### Read Replica Usage

To use the Autobase replica (10.0.1.7) for read operations:

1. **Configure Directus Read Replica** (requires Directus configuration)
2. **Use PgBouncer** for connection pooling and read/write splitting
3. **Application-level routing** - read from replica, write to primary

### Connection Pooling

For production, consider adding PgBouncer:

```yaml
# Add to docker-compose.production.yml
pgbouncer:
  image: edoburu/pgbouncer:latest
  environment:
    DB_HOST: 10.0.1.6
    DB_PORT: 6432
    DB_USER: postgres
    DB_PASSWORD: ${DB_PASSWORD}
    POOL_MODE: transaction
    MAX_CLIENT_CONN: 1000
    DEFAULT_POOL_SIZE: 20
```

Then update Directus to connect to PgBouncer instead of direct connection.

---

## Security Checklist

- [ ] Create dedicated database user (not `postgres`) for production
- [ ] Rotate database password regularly
- [ ] Ensure DB_PASSWORD is stored in Dokploy secrets (not in docker-compose.yml)
- [ ] Configure firewall to allow only necessary IPs
- [ ] Enable SSL/TLS for database connections
- [ ] Set up database audit logging
- [ ] Regular backup testing
- [ ] Monitor connection limits

---

**Last Updated**: 2025-11-09
**Maintained By**: DirectApp Team
**Autobase Cluster**: Primary 10.0.1.6:6432, Replica 10.0.1.7:6432
