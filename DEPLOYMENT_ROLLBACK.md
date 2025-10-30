# Data Isolation Implementation - Rollback Procedures

**Version:** 1.0
**Date:** 2025-10-30
**Related Tasks:** IMP-001-T3, IMP-001-T4, IMP-001-T5
**Implementation Tag:** `data-isolation-v1.0`

---

## Table of Contents

1. [Overview](#overview)
2. [Pre-Rollback Checklist](#pre-rollback-checklist)
3. [Rollback Procedures](#rollback-procedures)
4. [Verification Steps](#verification-steps)
5. [Emergency Procedures](#emergency-procedures)
6. [Recovery After Rollback](#recovery-after-rollback)

---

## Overview

This document provides step-by-step procedures to rollback the data isolation implementation deployed in Phase 1.3. The rollback removes:

- 234 permissions created for data isolation
- 10 policies created for role-based access control
- 9 policy-role links in directus_access
- 9 Norwegian roles (keeps Administrator)
- Test data (10 test cars, 4 test users, 1 test dealership)

**Rollback Time:** ~10 minutes
**Downtime Required:** No (permissions can be removed while system is running)
**Data Loss:** Test data only (production data unaffected)

---

## Pre-Rollback Checklist

Before starting rollback, verify:

- [ ] You have admin access to Directus (email: `admin@example.com`)
- [ ] Directus is running and accessible at `http://localhost:8055`
- [ ] You have PostgreSQL access (`docker exec -it directapp-database-1 psql -U directus`)
- [ ] You have a backup of the current state (optional but recommended)
- [ ] You understand the impact: all role-based data isolation will be removed

### Create Backup (Recommended)

```bash
# Backup current permissions state
docker exec directapp-database-1 pg_dump -U directus -d directus \
  -t directus_permissions \
  -t directus_policies \
  -t directus_access \
  -t directus_roles \
  > /tmp/permissions_backup_$(date +%Y%m%d_%H%M%S).sql

# Backup entire database (optional)
docker exec directapp-database-1 pg_dump -U directus -d directus \
  > /tmp/directus_full_backup_$(date +%Y%m%d_%H%M%S).sql
```

---

## Rollback Procedures

### Step 1: Login and Get Admin Token

```bash
# Get admin access token
ADMIN_TOKEN=$(curl -s -X POST http://localhost:8055/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@example.com", "password": "your-admin-password"}' \
  | jq -r '.data.access_token')

echo "Admin token: $ADMIN_TOKEN"
```

**Verification:** Token should be a long alphanumeric string (not "null")

---

### Step 2: Delete All Non-Admin Permissions

This removes all 234 permissions created during implementation.

```bash
# Get list of all permission IDs (except system defaults)
PERM_IDS=$(docker exec -i directapp-database-1 psql -U directus -d directus -t -c "
  SELECT id FROM directus_permissions
  WHERE policy IN (
    SELECT id FROM directus_policies
    WHERE name LIKE 'Policy for%'
  )
")

# Delete permissions via API (one by one)
for perm_id in $PERM_IDS; do
  curl -s -X DELETE "http://localhost:8055/permissions/$perm_id" \
    -H "Authorization: Bearer $ADMIN_TOKEN"
  echo "Deleted permission: $perm_id"
done
```

**Alternative SQL Method (Faster):**

```bash
docker exec -i directapp-database-1 psql -U directus -d directus <<EOF
DELETE FROM directus_permissions
WHERE policy IN (
  SELECT id FROM directus_policies
  WHERE name LIKE 'Policy for%'
);
EOF
```

**Expected Result:** ~186 permissions deleted (234 total - 48 admin permissions)

---

### Step 3: Delete Policy-Role Links

Remove the links between roles and custom policies in `directus_access` table.

```bash
docker exec -i directapp-database-1 psql -U directus -d directus <<EOF
DELETE FROM directus_access
WHERE policy IN (
  SELECT id FROM directus_policies
  WHERE name LIKE 'Policy for%' AND name != 'Policy for admin'
);
EOF
```

**Expected Result:** ~9 access records deleted

---

### Step 4: Delete Custom Policies

Remove the 10 policies created for role-based access control.

**Important:** Keep Administrator's default policy, only delete custom "Policy for" policies.

```bash
docker exec -i directapp-database-1 psql -U directus -d directus <<EOF
DELETE FROM directus_policies
WHERE name LIKE 'Policy for%' AND name != 'Policy for admin';
EOF
```

**Expected Result:** ~9 policies deleted

**For Administrator Policy:**

If you want to clean up the Administrator policy too (and restore to default):

```bash
# Delete custom admin permissions
docker exec -i directapp-database-1 psql -U directus -d directus <<EOF
DELETE FROM directus_permissions
WHERE policy IN (
  SELECT id FROM directus_policies
  WHERE name = 'Policy for admin'
);

DELETE FROM directus_access
WHERE policy IN (
  SELECT id FROM directus_policies
  WHERE name = 'Policy for admin'
);

DELETE FROM directus_policies
WHERE name = 'Policy for admin';
EOF
```

---

### Step 5: Delete Norwegian Roles

Remove the 9 Norwegian roles created during implementation, keeping only Administrator.

**Role UUIDs to Delete:**

```bash
docker exec -i directapp-database-1 psql -U directus -d directus <<EOF
-- Delete all roles except Administrator
DELETE FROM directus_roles
WHERE id IN (
  'ee808af7-0949-4b75-84f4-1c9e0dfa69e0',  -- Nybilselger
  'cd3a5d9c-d59c-4524-9c28-33e6c3569aad',  -- Bruktbilselger
  'f38c74dd-ee9e-4be8-8b00-addc62d51426',  -- Delelager
  'eab7e56b-8e6a-46e5-b914-a96f34e52f88',  -- Mottakskontrollør
  '21ca52e4-c9c9-4ce0-9f06-dd1e3bf797c9',  -- Booking
  '9c08b1cf-fb6d-49c4-b58c-ad7c52ca0df3',  -- Mekaniker
  'd8fcd3fc-df99-4b42-88cc-c5ca1ee9a8f6',  -- Bilpleiespesialist
  '7b63e6b0-e47b-4dc6-8ee5-e96f7ed7d764',  -- Daglig leder
  'c6ef9a1b-42e1-4b8c-86d1-ef6c2ece3e9f'   -- Økonomiansvarlig
);
EOF
```

**Expected Result:** 9 roles deleted

---

### Step 6: Delete Test Data

Remove test users, test cars, and test dealership created during testing.

**Delete Test Users:**

```bash
docker exec -i directapp-database-1 psql -U directus -d directus <<EOF
DELETE FROM directus_users
WHERE email IN (
  'nybilselger.kristiansand@test.com',
  'mekaniker.kristiansand@test.com',
  'nybilselger.mandal@test.com',
  'mekaniker.mandal@test.com'
);
EOF
```

**Expected Result:** 4 test users deleted

**Delete Test Cars:**

```bash
docker exec -i directapp-database-1 psql -U directus -d directus <<EOF
DELETE FROM cars
WHERE vin LIKE 'TESTVIN%';
EOF
```

**Expected Result:** 10 test cars deleted

**Delete Test Dealership (Mandal Bil AS):**

```bash
docker exec -i directapp-database-1 psql -U directus -d directus <<EOF
DELETE FROM dealership
WHERE dealership_name = 'Mandal Bil AS';
EOF
```

**Expected Result:** 1 dealership deleted

**Note:** Keep "Gumpen Skade og Bilpleie AS" (Kristiansand) if it's a real production dealership.

---

### Step 7: Restart Directus (Optional)

Restart Directus to clear any cached permissions.

```bash
docker restart directapp-directus-1
```

**Wait Time:** ~30 seconds for Directus to fully restart

---

## Verification Steps

After rollback, verify the system is in the expected state.

### Verify Permissions Removed

```bash
docker exec -i directapp-database-1 psql -U directus -d directus <<EOF
-- Should return 0 (or only default system permissions)
SELECT COUNT(*) FROM directus_permissions
WHERE policy IN (
  SELECT id FROM directus_policies
  WHERE name LIKE 'Policy for%'
);
EOF
```

**Expected:** 0 permissions

### Verify Policies Removed

```bash
docker exec -i directapp-database-1 psql -U directus -d directus <<EOF
-- Should return 0 custom policies
SELECT COUNT(*) FROM directus_policies
WHERE name LIKE 'Policy for%';
EOF
```

**Expected:** 0 policies

### Verify Roles Removed

```bash
docker exec -i directapp-database-1 psql -U directus -d directus <<EOF
-- Should return only Administrator role
SELECT name FROM directus_roles ORDER BY name;
EOF
```

**Expected:** Only "Administrator" role

### Verify Test Data Removed

```bash
docker exec -i directapp-database-1 psql -U directus -d directus <<EOF
-- Should return 0 test users
SELECT COUNT(*) FROM directus_users WHERE email LIKE '%@test.com';

-- Should return 0 test cars
SELECT COUNT(*) FROM cars WHERE vin LIKE 'TESTVIN%';

-- Check dealership count (should be 1 if you kept Kristiansand)
SELECT dealership_name FROM dealership ORDER BY dealership_name;
EOF
```

**Expected:**
- 0 test users
- 0 test cars
- 1 or more production dealerships

### Verify Admin Access Still Works

```bash
# Login as admin
curl -s -X POST http://localhost:8055/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@example.com", "password": "your-admin-password"}' \
  | jq -r '.data.access_token'

# Should return a valid token
```

**Expected:** Valid access token returned

---

## Emergency Procedures

### If Rollback Fails Midway

**Symptom:** Rollback script errors out partway through

**Solution:**

1. **Check what was deleted:**
   ```bash
   docker exec -i directapp-database-1 psql -U directus -d directus <<EOF
   SELECT COUNT(*) FROM directus_permissions;
   SELECT COUNT(*) FROM directus_policies;
   SELECT COUNT(*) FROM directus_roles;
   EOF
   ```

2. **Continue from where it failed:**
   - Re-run only the failed step
   - Check error messages for foreign key constraints
   - Delete in correct order: permissions → access → policies → roles

3. **If database is corrupted:**
   ```bash
   # Restore from backup
   docker exec -i directapp-database-1 psql -U directus -d directus \
     < /tmp/directus_full_backup_YYYYMMDD_HHMMSS.sql
   ```

### If Admin Access is Lost

**Symptom:** Cannot login as admin after rollback

**Solution:**

```bash
# Reset admin to default Administrator role
docker exec -i directapp-database-1 psql -U directus -d directus <<EOF
UPDATE directus_users
SET role = '6a3a7817-803b-45df-9a5a-0d6842dcba9d'
WHERE email = 'admin@example.com';
EOF
```

### If Directus Won't Start

**Symptom:** Directus crashes on startup after rollback

**Solution:**

```bash
# Check Directus logs
docker logs directapp-directus-1 --tail 100

# Common fixes:
# 1. Remove orphaned permissions
docker exec -i directapp-database-1 psql -U directus -d directus <<EOF
DELETE FROM directus_permissions WHERE policy NOT IN (SELECT id FROM directus_policies);
DELETE FROM directus_access WHERE policy NOT IN (SELECT id FROM directus_policies);
EOF

# 2. Restart Directus
docker restart directapp-directus-1
```

---

## Recovery After Rollback

After successful rollback, the system returns to pre-implementation state:

### What's Restored

- ✅ Only Administrator role exists
- ✅ No custom policies or permissions
- ✅ No test data (test users, test cars, test dealership)
- ✅ Admin has full unrestricted access
- ✅ All production data intact (real dealerships, real cars, real users)

### What's Lost

- ❌ All 9 Norwegian roles deleted
- ❌ All 234 permissions deleted
- ❌ Dealership-based data isolation removed
- ❌ Test environment data removed

### Next Steps

If you need to re-implement data isolation:

1. **Re-run implementation scripts:**
   ```bash
   python3 /tmp/create_permissions_v2.py
   ```

2. **Re-create test environment:**
   - Create test dealership
   - Create test cars
   - Create test users
   - Re-run isolation tests

3. **Review documentation:**
   - `DATA_ISOLATION_IMPLEMENTATION.md`
   - `PERMISSION_IMPLEMENTATION_SUMMARY.md`
   - `docs/ROLE_PERMISSIONS_PLAN.md`

---

## Complete Rollback Script

For convenience, here's a complete rollback script that runs all steps:

```bash
#!/bin/bash
# complete_rollback.sh - Full rollback of data isolation implementation

set -e  # Exit on error

echo "=========================================="
echo "Data Isolation Rollback Script"
echo "=========================================="

# Step 1: Get admin token
echo "[1/7] Getting admin access token..."
ADMIN_TOKEN=$(curl -s -X POST http://localhost:8055/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@example.com", "password": "your-admin-password"}' \
  | jq -r '.data.access_token')

if [ "$ADMIN_TOKEN" == "null" ] || [ -z "$ADMIN_TOKEN" ]; then
  echo "ERROR: Failed to get admin token"
  exit 1
fi
echo "✓ Admin token obtained"

# Step 2: Delete permissions
echo "[2/7] Deleting custom permissions..."
docker exec -i directapp-database-1 psql -U directus -d directus <<EOF
DELETE FROM directus_permissions
WHERE policy IN (
  SELECT id FROM directus_policies
  WHERE name LIKE 'Policy for%'
);
EOF
echo "✓ Permissions deleted"

# Step 3: Delete access records
echo "[3/7] Deleting policy-role links..."
docker exec -i directapp-database-1 psql -U directus -d directus <<EOF
DELETE FROM directus_access
WHERE policy IN (
  SELECT id FROM directus_policies
  WHERE name LIKE 'Policy for%'
);
EOF
echo "✓ Access records deleted"

# Step 4: Delete policies
echo "[4/7] Deleting custom policies..."
docker exec -i directapp-database-1 psql -U directus -d directus <<EOF
DELETE FROM directus_policies
WHERE name LIKE 'Policy for%';
EOF
echo "✓ Policies deleted"

# Step 5: Delete roles
echo "[5/7] Deleting Norwegian roles..."
docker exec -i directapp-database-1 psql -U directus -d directus <<EOF
DELETE FROM directus_roles
WHERE id IN (
  'ee808af7-0949-4b75-84f4-1c9e0dfa69e0',
  'cd3a5d9c-d59c-4524-9c28-33e6c3569aad',
  'f38c74dd-ee9e-4be8-8b00-addc62d51426',
  'eab7e56b-8e6a-46e5-b914-a96f34e52f88',
  '21ca52e4-c9c9-4ce0-9f06-dd1e3bf797c9',
  '9c08b1cf-fb6d-49c4-b58c-ad7c52ca0df3',
  'd8fcd3fc-df99-4b42-88cc-c5ca1ee9a8f6',
  '7b63e6b0-e47b-4dc6-8ee5-e96f7ed7d764',
  'c6ef9a1b-42e1-4b8c-86d1-ef6c2ece3e9f'
);
EOF
echo "✓ Roles deleted"

# Step 6: Delete test data
echo "[6/7] Deleting test data..."
docker exec -i directapp-database-1 psql -U directus -d directus <<EOF
DELETE FROM directus_users WHERE email LIKE '%@test.com';
DELETE FROM cars WHERE vin LIKE 'TESTVIN%';
DELETE FROM dealership WHERE dealership_name = 'Mandal Bil AS';
EOF
echo "✓ Test data deleted"

# Step 7: Restart Directus
echo "[7/7] Restarting Directus..."
docker restart directapp-directus-1
sleep 10
echo "✓ Directus restarted"

echo "=========================================="
echo "Rollback completed successfully!"
echo "=========================================="
echo ""
echo "Verification:"
docker exec -i directapp-database-1 psql -U directus -d directus <<EOF
SELECT 'Permissions:' as item, COUNT(*)::text as count FROM directus_permissions WHERE policy IN (SELECT id FROM directus_policies WHERE name LIKE 'Policy for%')
UNION ALL
SELECT 'Policies:', COUNT(*)::text FROM directus_policies WHERE name LIKE 'Policy for%'
UNION ALL
SELECT 'Roles:', COUNT(*)::text FROM directus_roles
UNION ALL
SELECT 'Test Users:', COUNT(*)::text FROM directus_users WHERE email LIKE '%@test.com'
UNION ALL
SELECT 'Test Cars:', COUNT(*)::text FROM cars WHERE vin LIKE 'TESTVIN%';
EOF
```

**Usage:**
```bash
chmod +x complete_rollback.sh
./complete_rollback.sh
```

---

## Support

If you encounter issues during rollback:

1. Check logs: `docker logs directapp-directus-1 --tail 100`
2. Review this document's Emergency Procedures section
3. Contact: Dev team or create GitHub issue
4. Reference: `DATA_ISOLATION_IMPLEMENTATION.md`

---

**Document Version:** 1.0
**Last Updated:** 2025-10-30
**Maintained By:** DirectApp Development Team
