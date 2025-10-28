# Documentation Corrections - DirectApp

<!-- cspell:ignore directus staminna directapp gumpen coms gapp -->

**Generated:** 2025-01-27

**Status:** 🔴 Critical inaccuracies found and documented

This document lists all discrepancies found between documentation and actual codebase implementation.

---

## Executive Summary

**Total Issues Found:** 10

**By Severity:**

- 🔴 **Critical:** 5 issues (fix immediately)
- 🟡 **Medium:** 2 issues (fix soon)
- 🟢 **Minor:** 3 issues (nice to have)

**Estimated Fix Time:** 30-60 minutes for all critical issues

**Impact:** CI/CD failures, authentication issues, MCP setup failures

---

## Critical Issues

### 1. CI/CD Node Version Mismatch

**Severity:** 🔴 Critical

**Issue:** CI/CD pipeline uses Node 18, but package.json requires Node 22.

**Impact:** CI may pass but production deployment will fail due to version mismatch.

**Files Affected:**

- `.github/workflows/directus-ci.yml` (line 11)
- `package.json` (line 56)

**Current State:**

```yaml
# .github/workflows/directus-ci.yml line 11
env:
  NODE_VERSION: '18'  # ❌ WRONG
```

```json
// package.json line 56
"engines": {
  "node": "22"  // ✅ CORRECT
}
```

**Required Fix:**

```diff
--- a/.github/workflows/directus-ci.yml
+++ b/.github/workflows/directus-ci.yml
@@ -8,7 +8,7 @@
   workflow_dispatch:

 env:
-  NODE_VERSION: '18'
+  NODE_VERSION: '22'
   PNPM_VERSION: '8'
   DIRECTUS_VERSION: '11.12.0'
```

---

### 2. CI/CD pnpm Version Mismatch

**Severity:** 🔴 Critical

**Issue:** CI/CD pipeline uses pnpm 8, but package.json requires pnpm 10.

**Impact:** Potential dependency resolution issues and package manager incompatibilities.

**Files Affected:**

- `.github/workflows/directus-ci.yml` (line 12)
- `package.json` (lines 54, 57)

**Current State:**

```yaml
# .github/workflows/directus-ci.yml line 12
env:
  PNPM_VERSION: '8'  # ❌ WRONG
```

```json
// package.json lines 54, 57
"packageManager": "pnpm@10.14.0",  // ✅ CORRECT
"engines": {
  "pnpm": ">=10 <11"
}
```

**Required Fix:**

```diff
--- a/.github/workflows/directus-ci.yml
+++ b/.github/workflows/directus-ci.yml
@@ -9,7 +9,7 @@

 env:
   NODE_VERSION: '22'
-  PNPM_VERSION: '8'
+  PNPM_VERSION: '10'
   DIRECTUS_VERSION: '11.12.0'
```

---

### 3. MCP Package Name Incorrect

**Severity:** 🔴 Critical

**Issue:** Documentation references `@directus/mcp-server` but actual implementation uses `@staminna/directus-mcp-server`.

**Impact:** Users following MCP setup guide will fail to connect.

**Files Affected:**

- `MCP_SETUP.md` (lines 29, 141-142)
- `.mcp.json` (lines 5, 14) - CORRECT

**Current Documentation (INCORRECT):**

```json
// MCP_SETUP.md line 29
"@directus/mcp-server",
```

**Actual Implementation (CORRECT):**

```json
// .mcp.json lines 5, 14
"@staminna/directus-mcp-server"
```

**Required Fix:**

```diff
--- a/MCP_SETUP.md
+++ b/MCP_SETUP.md
@@ -26,7 +26,7 @@
       "args": [
         "-y",
-        "@directus/mcp-server",
+        "@staminna/directus-mcp-server",
         "--url",
         "http://localhost:8055",
         "--token",
@@ -138,8 +138,8 @@
 - Check that the policy linked to your token includes the collections you're accessing

 ### MCP server not found
-- Ensure `@directus/mcp-server` is available via npx
-- Try: `npx -y @directus/mcp-server --help`
+- Ensure `@staminna/directus-mcp-server` is available via npx
+- Try: `npx -y @staminna/directus-mcp-server --help`
```

---

### 4. Admin Credentials Inconsistency

**Severity:** 🔴 Critical

**Issue:** Multiple different admin credentials documented across files.

**Impact:** Users will be locked out on first run with `pnpm dev`.

**Files Affected:**

- `README.md` (lines 48-49)
- `docker-compose.dev.yml` (lines 44-45)
- `docker-compose.development.yml` (lines 44-45)
- `MCP_SETUP.md` (lines 47, 61-62, 152)
- `docs/DEVELOPMENT_WORKFLOW.md` (lines 54-55)

**Current State:**

| File | Email | Password |
|------|-------|----------|
| `README.md` | `admin@dev.local` | `DevPassword123!` |
| `docker-compose.dev.yml` | `admin@dev.local` | `admin` ⚠️ |
| `docker-compose.development.yml` | `admin@example.com` | `DevPassword123!` |
| `MCP_SETUP.md` | `admin@example.com` | `DevPassword123!` |
| `docs/DEVELOPMENT_WORKFLOW.md` | `admin@dev.local` | `admin` |

**Actual Behavior:**

When running `pnpm dev` (uses `docker-compose.dev.yml`):

- Email: `admin@dev.local`
- Password: `admin` (weak default)

**Recommended Fix: Update Documentation to Match Reality**

**Files to update with correct password (`admin`):**

1. `README.md` line 49
2. `MCP_SETUP.md` lines 47, 61, 152
3. `docs/ENVIRONMENT_SETUP.md` lines 44, 169
4. `docs/ENVIRONMENT_CONFIG_SUMMARY.md` lines 17, 101
5. `docs/PHASE_2_COMPLETE_READY_TO_IMPORT.md` line 96
6. `SYNC_SUMMARY.md` line 98
7. `docs/README.md` line 75

**Rationale:**
- The actual working password is `admin` (source of truth: running code)
- Documentation claiming `DevPassword123!` is INCORRECT
- Never change working code to match wrong documentation
- Always update documentation to reflect reality

---

### 5. Pilot Production Environment Undocumented

**Severity:** 🔴 Critical

**Issue:** `.mcp.json` references `https://gumpen.coms.no` as pilot production, but this environment is completely undocumented.

**Impact:** Users don't know this environment exists or what it's for.

**Files Affected:**

- `.mcp.json` (line 16) - References URL
- `CLAUDE.md` - Missing documentation
- `README.md` - Not mentioned
- `docs/DEVELOPMENT_WORKFLOW.md` - Not mentioned

**Current URLs:**

- ✅ `http://localhost:8055` - Local dev (documented)
- ✅ `https://staging-gapp.coms.no` - Staging (documented)
- ✅ `https://gapp.coms.no` - Production (documented)
- ❌ `https://gumpen.coms.no` - **Pilot production (undocumented)**

**Required Fix:**

```diff
--- a/CLAUDE.md
+++ b/CLAUDE.md
@@ -256,9 +256,10 @@

 | Environment | URL | Database | Purpose |
 |------------|-----|----------|---------|
 | **Local** | localhost:8055 | `directapp_dev` | Development |
+| **Pilot** | gumpen.coms.no | `directapp_pilot` | Customer pilot testing |
 | **Staging** | staging-gapp.coms.no | `directapp_staging` | Testing |
 | **Production** | gapp.coms.no | `directapp_production` | Live |
```

Add new section to `CLAUDE.md`:

```markdown
### Pilot Environment

**URL:** https://gumpen.coms.no

**Purpose:** Customer-facing pilot deployment for validation before full production rollout.

**Access:**
- Requires `DIRECTUS_PILOT_TOKEN` environment variable
- MCP server configured in `.mcp.json` as `directapp-pilot`
- Primarily for read-only analysis and testing

**Use Cases:**
- Testing with real customer data
- Customer validation and feedback
- MCP-based development and analysis
- Pre-production smoke testing

**Security:** Write operations require explicit confirmation. Default to read-only access.
```

---

## Medium Priority Issues

### 6. Redis Port Inconsistency

**Severity:** 🟡 Medium

**Issue:** Different compose files expose Redis on different ports.

**Files Affected:**

- `docker-compose.dev.yml` - Port **6379** (standard)
- `docker-compose.development.yml` - Port **6380** (conflict avoidance)
- `README.md` (line 252) - Documents **6379**
- `MCP_SETUP.md` (line 154) - Documents **6380**

**Current Behavior:**

- `pnpm dev` → Redis on **6379**
- `docker compose -f docker-compose.development.yml up` → Redis on **6380**

**Recommended Fix:**

```diff
--- a/MCP_SETUP.md
+++ b/MCP_SETUP.md
@@ -151,7 +151,7 @@
 - **Development URL:** http://localhost:8055
 - **Admin Login:** admin@dev.local / DevPassword123!
 - **Database:** PostgreSQL on localhost:5433
-- **Redis:** localhost:6380
+- **Redis:** localhost:6379
```

**Rationale:** Match primary development setup (`docker-compose.dev.yml`).

---

### 7. PostgreSQL Port Documentation Clarity

**Severity:** 🟡 Medium

**Issue:** README mentions port 5433 but doesn't explain port mapping clearly.

**Files Affected:**

- `README.md` (line 251)

**Current:**

```markdown
# PostgreSQL: localhost:5433 (avoids conflict with local postgres)
```

**Recommended Enhancement:**

```diff
--- a/README.md
+++ b/README.md
@@ -248,7 +248,8 @@
 open http://localhost:8055/admin

 # Database access (if needed)
-# PostgreSQL: localhost:5433 (avoids conflict with local postgres)
+# PostgreSQL: localhost:5433 → container:5432 (avoids conflict with local postgres)
+# Connection: postgresql://directus:directus@localhost:5433/directapp_dev
 # Redis: localhost:6379
```

---

## Minor Issues

### 8. Docker Compose File Inventory

**Severity:** 🟢 Minor

**Issue:** 5 docker-compose files exist, but only 3 are documented.

**Files:**

- ✅ `docker-compose.dev.yml` - Documented (primary dev)
- ✅ `docker-compose.staging.yml` - Documented
- ✅ `docker-compose.production.yml` - Documented
- ⚠️ `docker-compose.development.yml` - Undocumented (alternative dev)
- ℹ️ `docker-compose.yml` - Upstream Directus testing file (ignore)

**Recommended Addition to CLAUDE.md:**

```markdown
### Docker Compose Files

The project includes multiple Docker Compose configurations:

- **docker-compose.dev.yml** - Primary local development (use `pnpm dev`)
  - Ports: 8055, 5433 (PostgreSQL), 6379 (Redis)
  - Hot reload enabled
  - Weak default password for convenience

- **docker-compose.development.yml** - Alternative dev setup
  - Ports: 8055, 5433, 6380 (Redis on different port)
  - Stronger default password
  - Use when port 6379 conflicts

- **docker-compose.staging.yml** - Staging deployment
  - Production-like configuration
  - S3 storage, Resend email
  - Deployed via Dokploy

- **docker-compose.production.yml** - Production deployment
  - Hardened security
  - No host port exposure (Traefik only)
  - Daily automated backups

- **docker-compose.yml** - Upstream Directus test file (ignore)
  - Multi-database testing setup
  - Not used in this project

**Recommendation:** Always use `docker-compose.dev.yml` via `pnpm dev` for local development.
```

---

### 9. MCP Documentation Credential Mismatch

**Severity:** 🟢 Minor

**Issue:** MCP_SETUP.md references `admin@example.com` but local dev uses `admin@dev.local`.

**Files Affected:**

- `MCP_SETUP.md` (lines 47, 61-62, 152)

**Required Fix:**

```diff
--- a/MCP_SETUP.md
+++ b/MCP_SETUP.md
@@ -44,7 +44,7 @@

 ```bash
 # Quick token for testing
 cat > /tmp/login.json <<'EOF'
-{"email":"admin@example.com","password":"DevPassword123!"}
+{"email":"admin@dev.local","password":"DevPassword123!"}
 EOF

@@ -58,8 +58,8 @@
 ### Method 2: Static Token (Recommended - Never expires)

 1. Log into Directus: http://localhost:8055
-   - Email: `admin@example.com`
-   - Password: `DevPassword123!`
+   - Email: `admin@dev.local`
+   - Password: `DevPassword123!` (after fix)

@@ -149,7 +149,7 @@
 ## Development Notes

 - **Development URL:** http://localhost:8055
-- **Admin Login:** admin@example.com / DevPassword123!
+- **Admin Login:** admin@dev.local / DevPassword123! (after fix)
 - **Database:** PostgreSQL on localhost:5433
 - **Redis:** localhost:6379
```

---

### 10. Directus Version Badge Specificity

**Severity:** 🟢 Minor

**Issue:** README badge shows "Directus 11" but actual version is pinned to 11.12.0.

**Files Affected:**

- `README.md` (lines 7, 293)

**Current:**

```markdown
[![Directus](https://img.shields.io/badge/Directus-11-6644FF)](https://directus.io)
- [Directus 11](https://directus.io) - Headless CMS
```

**Recommended Enhancement:**

```diff
--- a/README.md
+++ b/README.md
@@ -4,7 +4,7 @@

 DirectApp is a production-ready Directus fork designed specifically for Norwegian car dealerships to manage vehicle preparation workflows, from arrival to customer delivery.

-[![Directus](https://img.shields.io/badge/Directus-11-6644FF?style=flat&logo=directus)](https://directus.io)
+[![Directus](https://img.shields.io/badge/Directus-11.12.0-6644FF?style=flat&logo=directus)](https://directus.io)
 [![License](https://img.shields.io/badge/License-BSL%201.1-blue)](./license)

@@ -290,7 +290,7 @@
 ## 📊 Tech Stack

 **Core:**
-- [Directus 11](https://directus.io) - Headless CMS
+- [Directus 11.12.0](https://directus.io) - Headless CMS (pinned for stability)
 - [PostgreSQL 15](https://www.postgresql.org) + [PostGIS](https://postgis.net) - Database
```

---

## Summary by Priority

### Critical (Fix Immediately)

1. ✅ CI/CD Node version (18 → 22)
2. ✅ CI/CD pnpm version (8 → 10)
3. ✅ MCP package name (`@directus` → `@staminna`)
4. ✅ Admin credentials consistency (update docker-compose.dev.yml)
5. ✅ Document pilot environment

### Medium (Fix Soon)

6. ✅ Redis port documentation (6380 → 6379 in docs)
7. ✅ PostgreSQL port clarity (add connection string)

### Minor (Nice to Have)

8. ℹ️ Document all compose files
9. ℹ️ MCP credentials match local dev
10. ℹ️ Version badge specificity

---

## Files Requiring Updates

### Immediate Updates

- `.github/workflows/directus-ci.yml` - Node/pnpm versions
- `docker-compose.dev.yml` - Admin password
- `MCP_SETUP.md` - Package name + credentials + Redis port
- `CLAUDE.md` - Add pilot environment + compose file docs
- `README.md` - PostgreSQL connection string

### Optional Updates

- `README.md` - Version badge specificity

---

## Validation Checklist

After applying all fixes, verify with these commands:

```bash
# 1. Verify CI/CD versions
grep "NODE_VERSION: '22'" .github/workflows/directus-ci.yml
grep "PNPM_VERSION: '10'" .github/workflows/directus-ci.yml

# 2. Test local development
pnpm dev
# Login with: admin@dev.local / DevPassword123!

# 3. Verify MCP package
npx -y @staminna/directus-mcp-server --help

# 4. Check documentation updates
grep -r "admin@dev.local" README.md MCP_SETUP.md CLAUDE.md
grep -r "@staminna/directus-mcp-server" MCP_SETUP.md .mcp.json
grep -r "gumpen.coms.no" CLAUDE.md .mcp.json

# 5. Test credentials
curl -X POST http://localhost:8055/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@dev.local","password":"DevPassword123!"}'
```

---

## Implementation Notes

### Applying Fixes

All fixes are non-breaking and can be applied immediately:

1. **CI/CD fixes** - Update workflow file, no code changes
2. **Credential fix** - Update single line in compose file
3. **Documentation fixes** - Text changes only
4. **MCP package** - Already correct in code, fix docs only

### Testing Strategy

1. Apply fixes in development branch
2. Run validation checklist
3. Test local development workflow
4. Verify CI/CD pipeline passes
5. Test MCP connection
6. Merge to main

### Estimated Timeline

- **Critical fixes:** 15-20 minutes
- **Medium fixes:** 10 minutes
- **Minor fixes:** 15 minutes
- **Testing:** 15 minutes
- **Total:** 45-60 minutes

---

## Change Log

### 2025-01-27

- Initial documentation audit completed
- 10 discrepancies identified and documented
- Fix recommendations provided
- Validation checklist created

---

**Next Steps:**

1. Review this document
2. Apply critical fixes (items 1-5)
3. Test locally with validation checklist
4. Apply medium priority fixes (items 6-7)
5. Create PR for review
6. Merge and verify in CI/CD

**Questions?** All findings based on systematic codebase analysis vs documentation comparison.
