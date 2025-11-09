# Autobase Connection Checklist

**Before starting DirectApp with Autobase cluster, verify these prerequisites:**

---

## Network Connectivity Tests

### 1. Test Basic Network Connectivity

```bash
# Test if host 10.0.1.6 is reachable
ping -c 3 10.0.1.6

# Test if port 6432 is open
telnet 10.0.1.6 6432
# OR
nc -zv 10.0.1.6 6432
# OR
curl -v telnet://10.0.1.6:6432
```

**Expected Result:** Connection should succeed

**If it fails:**
- Check if Autobase cluster is running
- Verify firewall rules allow traffic to 10.0.1.6:6432
- Ensure you're on the correct network (VPN if required)

### 2. Test PostgreSQL Connection

```bash
# If psql is installed on host
PGPASSWORD='v5Kry76iPdEFUXOfxUlnswH77m68fAvI' psql -h 10.0.1.6 -p 6432 -U postgres -c "SELECT version();"

# If psql is NOT installed, use Docker
docker run --rm -e PGPASSWORD='v5Kry76iPdEFUXOfxUlnswH77m68fAvI' postgres:15.6 psql -h 10.0.1.6 -p 6432 -U postgres -c "SELECT version();"
```

**Expected Result:** Should show PostgreSQL version

**If it fails with "Connection refused":**
- Autobase cluster might not be running
- Port 6432 might be closed
- Firewall blocking the connection

**If it fails with "Password authentication failed":**
- Password might be incorrect
- User 'postgres' might not exist or have different password

**If it hangs (no response):**
- Network routing issue
- Firewall dropping packets
- Port not accessible

---

## Database Preparation

### 3. Create Required Databases

Once connection works, create the three databases:

```bash
# Connect to cluster
PGPASSWORD='v5Kry76iPdEFUXOfxUlnswH77m68fAvI' psql -h 10.0.1.6 -p 6432 -U postgres

# Create databases
CREATE DATABASE directapp_dev;
CREATE DATABASE directapp_staging;
CREATE DATABASE directapp_production;

# Verify
\l

# Exit
\q
```

### 4. Verify Database Access

```bash
# Test each database
PGPASSWORD='v5Kry76iPdEFUXOfxUlnswH77m68fAvI' psql -h 10.0.1.6 -p 6432 -U postgres -d directapp_dev -c "SELECT current_database();"

PGPASSWORD='v5Kry76iPdEFUXOfxUlnswH77m68fAvI' psql -h 10.0.1.6 -p 6432 -U postgres -d directapp_staging -c "SELECT current_database();"

PGPASSWORD='v5Kry76iPdEFUXOfxUlnswH77m68fAvI' psql -h 10.0.1.6 -p 6432 -U postgres -d directapp_production -c "SELECT current_database();"
```

**Expected Result:** Each command should return the database name

---

## Security Configuration

### 5. Verify pg_hba.conf (Autobase Administrator)

Ask your Autobase administrator to verify that pg_hba.conf allows connections:

```
# Example pg_hba.conf entry
host    all             postgres        10.0.0.0/8              md5
```

This allows connections from the 10.0.0.0/8 network range.

### 6. Firewall Rules

Ensure firewall allows:
- **Source**: Docker host IP (where DirectApp runs)
- **Destination**: 10.0.1.6:6432
- **Protocol**: TCP

---

## DirectApp Configuration

### 7. Set Up .env File

```bash
# Copy template
cp .env.example .env

# Verify configuration
cat .env | grep -E "DB_HOST|DB_PORT|DB_DATABASE|DB_USER|DB_PASSWORD"
```

**Expected output:**
```
DB_HOST=10.0.1.6
DB_PORT=6432
DB_DATABASE=directapp_dev
DB_USER=postgres
DB_PASSWORD=v5Kry76iPdEFUXOfxUlnswH77m68fAvI
```

### 8. Start DirectApp Development

```bash
# Start services
docker compose -f docker-compose.dev.yml up

# Watch for connection errors
docker compose -f docker-compose.dev.yml logs -f directus
```

**Expected log output:**
```
directapp-dev | Database connected successfully
directapp-dev | Server started at http://0.0.0.0:8055
```

**If you see "Connection refused":**
- Autobase cluster not reachable from Docker container
- Check Docker network configuration
- Try `--network host` mode (not recommended for production)

**If you see "Password authentication failed":**
- DB_PASSWORD in .env doesn't match Autobase cluster
- Double-check credentials

**If you see "Database does not exist":**
- Run Step 3 to create databases
- Verify DB_DATABASE value in .env

---

## Troubleshooting Checklist

Use this checklist to diagnose connection issues:

- [ ] Can ping 10.0.1.6 from host?
- [ ] Can telnet/nc to 10.0.1.6:6432 from host?
- [ ] Can connect with psql from host (if installed)?
- [ ] Can connect with psql from Docker container?
- [ ] Have you created the three databases?
- [ ] Is .env file configured correctly?
- [ ] Is Docker container on correct network?
- [ ] Are firewall rules configured?
- [ ] Is Autobase pg_hba.conf configured to allow connections?

---

## Quick Test Script

Save this as `test-autobase-connection.sh`:

```bash
#!/bin/bash

echo "========================================="
echo "AUTOBASE CONNECTION TEST"
echo "========================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ERRORS=0

# Test 1: Ping
echo -n "1. Testing network connectivity (ping)... "
if ping -c 1 -W 2 10.0.1.6 > /dev/null 2>&1; then
  echo -e "${GREEN}✓${NC}"
else
  echo -e "${RED}✗${NC} - Cannot ping 10.0.1.6"
  ERRORS=$((ERRORS + 1))
fi

# Test 2: Port
echo -n "2. Testing port 6432 accessibility... "
if timeout 5 bash -c 'cat < /dev/null > /dev/tcp/10.0.1.6/6432' 2>/dev/null; then
  echo -e "${GREEN}✓${NC}"
else
  echo -e "${RED}✗${NC} - Port 6432 not accessible"
  ERRORS=$((ERRORS + 1))
fi

# Test 3: PostgreSQL Connection
echo -n "3. Testing PostgreSQL connection... "
if docker run --rm -e PGPASSWORD='v5Kry76iPdEFUXOfxUlnswH77m68fAvI' postgres:15.6 psql -h 10.0.1.6 -p 6432 -U postgres -c "SELECT 1;" > /dev/null 2>&1; then
  echo -e "${GREEN}✓${NC}"
else
  echo -e "${RED}✗${NC} - Cannot connect to PostgreSQL"
  ERRORS=$((ERRORS + 1))
fi

# Test 4: Database Exists
echo -n "4. Testing directapp_dev database... "
if docker run --rm -e PGPASSWORD='v5Kry76iPdEFUXOfxUlnswH77m68fAvI' postgres:15.6 psql -h 10.0.1.6 -p 6432 -U postgres -d directapp_dev -c "SELECT 1;" > /dev/null 2>&1; then
  echo -e "${GREEN}✓${NC}"
else
  echo -e "${YELLOW}⚠${NC} - Database directapp_dev does not exist (run CREATE DATABASE directapp_dev;)"
fi

echo ""
echo "========================================="
if [ $ERRORS -eq 0 ]; then
  echo -e "${GREEN}ALL CRITICAL TESTS PASSED${NC}"
  echo "You can start DirectApp with: docker compose -f docker-compose.dev.yml up"
else
  echo -e "${RED}$ERRORS CRITICAL TEST(S) FAILED${NC}"
  echo "Fix the errors above before starting DirectApp"
fi
echo "========================================="
```

Run with:
```bash
chmod +x test-autobase-connection.sh
./test-autobase-connection.sh
```

---

## If Connection Still Fails

### Option 1: Use Docker Host Network Mode

Modify docker-compose.dev.yml:

```yaml
services:
  directus:
    network_mode: host  # Add this line
    # Remove 'networks:' section
```

**Warning:** This exposes all container ports on host. Only for testing.

### Option 2: Check Docker Network

```bash
# Inspect Docker network
docker network inspect directapp-dev

# Try creating container in host network
docker run --rm --network host postgres:15.6 psql -h 10.0.1.6 -p 6432 -U postgres -c "SELECT 1;"
```

### Option 3: Use IP Address Instead of Hostname

Already using IP (10.0.1.6), but verify DNS resolution not interfering:

```bash
# Check if there's a hostname
nslookup 10.0.1.6

# Try connecting by hostname if available
```

### Option 4: Contact Autobase Administrator

If all else fails, ask Autobase administrator to:
1. Verify cluster is running: `pg_isready -h 10.0.1.6 -p 6432`
2. Check pg_hba.conf allows connections from your IP
3. Check PostgreSQL logs for connection attempts
4. Verify port 6432 is not blocked by firewall

---

**Last Updated**: 2025-11-09
**Next Step**: Run the test script above before starting DirectApp
