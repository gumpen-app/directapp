# Staging Deployment Checklist

**Environment**: Staging (staging-gapp.coms.no)
**Platform**: Dokploy on Hetzner VPS (157.180.125.91)
**Last Updated**: 2025-11-09

---

## Pre-Deployment

### Database Setup
- [ ] Autobase cluster accessible from Dokploy (10.0.1.6:6432)
- [ ] Database `directapp_staging` created on Autobase
- [ ] Connection tested from dokploy-network

### Security Keys
- [ ] Generated unique `DIRECTUS_KEY` (32 bytes): `openssl rand -base64 32`
- [ ] Generated unique `DIRECTUS_SECRET` (64 bytes): `openssl rand -base64 64`
- [ ] Generated strong admin password (16+ characters)
- [ ] Keys are different from dev environment
- [ ] Keys stored securely (not in git)

### External Services
- [ ] S3 bucket `directapp-staging` created
- [ ] S3 credentials obtained (access key + secret key)
- [ ] Resend account configured for staging
- [ ] Resend API key obtained
- [ ] Norwegian Vehicle Registry staging token obtained
- [ ] (Optional) Sentry project created for staging

### DNS & Domain
- [ ] DNS record for `staging-gapp.coms.no` points to Hetzner VPS (157.180.125.91)
- [ ] Traefik Let's Encrypt configured on Dokploy

---

## Deployment Steps

### 1. Create Service in Dokploy

1. Log in to Dokploy: https://dokploy.your-domain.com
2. Navigate to your project (or create new project)
3. Click **"Create Service"**
4. Select **"Docker Compose"**
5. Name: `directapp-staging`

### 2. Upload Docker Compose

1. Copy contents of `docker-compose.staging.yml`
2. Paste into Dokploy UI Docker Compose editor
3. Verify configuration:
   - Container name: `directapp-staging`
   - Network: `dokploy-network` (external)
   - Traefik labels: Host(`staging-gapp.coms.no`)

### 3. Set Environment Variables

Use `.env.staging.example` as template. Set these in Dokploy UI:

**Required Variables**:
```bash
# Database (Autobase)
DB_HOST=10.0.1.6
DB_PORT=6432
DB_DATABASE=directapp_staging
DB_USER=postgres
DB_PASSWORD=<autobase-password>

# Directus Security
DIRECTUS_KEY=<generated-32-byte-key>
DIRECTUS_SECRET=<generated-64-byte-secret>

# Admin (first-time only)
ADMIN_EMAIL=admin@staging-gapp.coms.no
ADMIN_PASSWORD=<strong-password>

# Application
PUBLIC_URL=https://staging-gapp.coms.no
CORS_ORIGIN=https://staging-gapp.coms.no
COOKIE_DOMAIN=.coms.no

# Email
EMAIL_FROM=DirectApp Staging <noreply@coms.no>
RESEND_API_KEY=<resend-api-key>

# Storage
STORAGE_LOCATIONS=s3
S3_ACCESS_KEY=<s3-access-key>
S3_SECRET_KEY=<s3-secret-key>
S3_BUCKET=directapp-staging
S3_REGION=eu-north-1

# Norwegian Vehicle Registry
STATENS_VEGVESEN_TOKEN=<staging-token>
```

**Optional Variables**:
```bash
# Monitoring
SENTRY_DSN=<staging-sentry-dsn>
```

### 4. Deploy Service

1. Click **"Deploy"** in Dokploy
2. Monitor deployment logs for:
   - `Database connected successfully`
   - `Server started at http://0.0.0.0:8055`
3. Wait for health check to pass (green status)

### 5. Verify Deployment

**Health Check**:
```bash
curl https://staging-gapp.coms.no/server/health
```
Expected: `{"status":"ok"}`

**Access Admin**:
1. Navigate to: https://staging-gapp.coms.no
2. Should redirect to: https://staging-gapp.coms.no/admin
3. Log in with: `admin@staging-gapp.coms.no` / `<password>`

---

## Post-Deployment

### Immediate Actions

- [ ] Successfully logged in to admin panel
- [ ] Changed admin password to different strong password
- [ ] Created test user account
- [ ] Verified database connection (check collections)
- [ ] Tested file upload (check S3 bucket)
- [ ] Sent test email (check Resend logs)
- [ ] Tested Norwegian Vehicle Registry integration

### Security Hardening

- [ ] Removed `ADMIN_EMAIL` from Dokploy environment variables
- [ ] Removed `ADMIN_PASSWORD` from Dokploy environment variables
- [ ] Redeployed service (to apply environment changes)
- [ ] Verified admin can still log in with new password
- [ ] Checked Sentry is receiving events (if configured)

### Documentation

- [ ] Documented actual deployment date
- [ ] Recorded any issues encountered
- [ ] Updated DOKPLOY_DEPLOYMENT_GUIDE.md if needed
- [ ] Shared staging URL with team

---

## Smoke Tests

Run these tests to verify staging environment:

### Basic Functionality
- [ ] Admin panel loads
- [ ] User can log in
- [ ] Collections visible
- [ ] Items can be created
- [ ] Items can be updated
- [ ] Items can be deleted
- [ ] Search works
- [ ] Filters work

### File Operations
- [ ] File upload works
- [ ] Files appear in S3 bucket
- [ ] Files can be downloaded
- [ ] Image thumbnails generate

### Email
- [ ] Password reset email sends
- [ ] Email arrives in inbox
- [ ] Email links work

### API
- [ ] REST API accessible: `https://staging-gapp.coms.no/items/`
- [ ] GraphQL accessible: `https://staging-gapp.coms.no/graphql`
- [ ] Authentication works
- [ ] CORS configured correctly

### Norwegian Integration
- [ ] Vehicle lookup by VIN works
- [ ] Vehicle lookup by license plate works
- [ ] Data auto-populates correctly

### Performance
- [ ] Page load times acceptable (<2s)
- [ ] Redis cache working (check logs)
- [ ] Database queries responsive

---

## Rollback Procedure

If deployment fails:

### Via Dokploy UI
1. Navigate to service: `directapp-staging`
2. Click **"Deployments"** tab
3. Find previous successful deployment
4. Click **"Redeploy"**

### Via CLI (if Dokploy UI unavailable)
```bash
# SSH into VPS
ssh root@157.180.125.91

# List containers
docker ps -a | grep directapp-staging

# Stop current version
docker stop directapp-staging directapp-staging-redis

# Start previous version (if still exists)
docker start <previous-container-id>

# Or redeploy from git
cd /path/to/directapp
git checkout <previous-commit>
docker compose -f docker-compose.staging.yml up -d
```

---

## Troubleshooting

### Container won't start

**Check logs**:
```bash
docker logs directapp-staging
```

**Common issues**:
- Missing environment variables
- Database connection failed
- Redis not accessible
- Invalid S3 credentials

### Database connection failed

**Test from container**:
```bash
docker exec -it directapp-staging sh
apk add postgresql-client
psql -h 10.0.1.6 -p 6432 -U postgres -d directapp_staging
```

**Verify**:
- Autobase service running: `docker ps | grep autobase`
- Both services in `dokploy-network`
- Database exists: `\l` in psql
- Correct password in environment variables

### Traefik not routing

**Check labels**:
```bash
docker inspect directapp-staging | grep -A 10 Labels
```

**Verify**:
- `traefik.enable=true` set
- Host rule matches DNS: `staging-gapp.coms.no`
- Container in `dokploy-network`
- No port conflicts

### S3 upload fails

**Check environment**:
- `S3_ACCESS_KEY` and `S3_SECRET_KEY` correct
- `S3_BUCKET` exists and accessible
- `S3_REGION` matches bucket region
- Bucket CORS configured (if needed)

---

## Success Criteria

Deployment is successful when:

- ✅ Health check returns `{"status":"ok"}`
- ✅ Admin panel accessible via HTTPS
- ✅ Can log in and create/edit items
- ✅ Files upload to S3
- ✅ Emails send via Resend
- ✅ Norwegian Vehicle Registry integration works
- ✅ No errors in Sentry (if configured)
- ✅ All smoke tests pass

---

## Next Steps

After successful staging deployment:

1. **Test thoroughly** - Run all smoke tests and user workflows
2. **Monitor** - Watch Sentry for errors, check Dokploy logs
3. **Document** - Update deployment guide with any learnings
4. **Prepare production** - Use staging experience to refine production deployment
5. **CI/CD** - Set up GitHub Actions for automated deployments

---

**Deployment Contact**: DirectApp Team
**Support**: See DOKPLOY_DEPLOYMENT_GUIDE.md
**Emergency Rollback**: See Rollback Procedure above
