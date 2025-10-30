# DirectApp Dokploy Configuration - URGENT FIX

**Date**: 2025-10-30
**Status**: Issues identified and fixes provided

---

## 🚨 Current Issues

### Staging
- **Error**: "Service name not found"
- **Cause**: Dokploy compose configuration incomplete

### Production
- **Error**: SSL errors on URLs
- **Cause**: Domain not configured in Dokploy

---

## ✅ Solution

### Step 1: Configure Dokploy Compose Source

For BOTH staging and production applications, you need to configure the compose file source in Dokploy UI:

#### Staging (`USdQOoYpD-sCfneo9kQbs`)

1. Go to: https://deploy.onecom.ai/.../USdQOoYpD-sCfneo9kQbs
2. Click **Settings** → **Source**
3. Configure:
   ```
   Repository: https://github.com/gumpen-app/directapp
   Branch: development
   Compose File: docker-compose.production.yml
   Build Path: /
   ```
4. Click **Save**

#### Production (`YKhjz62y5ikBunLd6G2BS`)

1. Go to: https://deploy.onecom.ai/.../YKhjz62y5ikBunLd6G2BS
2. Click **Settings** → **Source**
3. Configure:
   ```
   Repository: https://github.com/gumpen-app/directapp
   Branch: main
   Compose File: docker-compose.production.yml
   Build Path: /
   ```
4. Click **Save**

---

### Step 2: Configure Domains in Dokploy

#### Staging

1. Go to application settings
2. Click **Domains** tab
3. Add domain: `staging-gapp.coms.no`
4. Enable **HTTPS** (Let's Encrypt automatic)
5. Save

#### Production

1. Go to application settings
2. Click **Domains** tab
3. Add domain: `gapp.coms.no`
4. Enable **HTTPS** (Let's Encrypt automatic)
5. Save

---

### Step 3: Verify DNS

Make sure DNS is pointing to your Dokploy server:

```bash
# Check staging
dig staging-gapp.coms.no

# Check production
dig gapp.coms.no
```

Both should point to your Dokploy server IP.

---

## 📋 Service Names

The main service in the compose file is: **`directus`**

Other services:
- `postgres` - Database
- `redis` - Cache
- `backup` - Automated backups

---

## 🔧 Environment Variables Already Configured

Both applications should have environment variables set (from `.env.staging` and `.env.production`):

- `DIRECTUS_KEY`
- `DIRECTUS_SECRET`
- `DB_*` variables
- `PUBLIC_URL`
- `DOMAIN`
- `S3_*` variables
- etc.

---

## 🚀 After Configuration

Once you've completed Steps 1-3:

1. **Redeploy Staging**:
   ```bash
   git push origin development  # Triggers auto-deploy
   ```

2. **Redeploy Production**:
   ```bash
   git checkout main
   git merge development
   git push origin main  # Triggers auto-deploy
   ```

3. **Or manually in Dokploy UI**:
   - Click **Deploy** button in each application

---

## ✅ Expected Results

### Staging
- URL: https://staging-gapp.coms.no
- Status: Running
- SSL: Valid (Let's Encrypt)
- Admin: https://staging-gapp.coms.no/admin

### Production
- URL: https://gapp.coms.no
- Status: Running
- SSL: Valid (Let's Encrypt)
- Admin: https://gapp.coms.no/admin

---

## 🐛 If Still Not Working

### "Service name not found" persists:

Check in Dokploy logs which service it's looking for. The compose file has:
- Main service: `directus` (NOT `directapp` - that's just the container name)

### SSL errors persist:

1. Check DNS is pointing to correct IP
2. Wait 1-5 minutes for Let's Encrypt to issue certificate
3. Check Traefik logs in Dokploy
4. Verify domain is added in Dokploy UI

### Application won't start:

1. Check Dokploy logs for the specific error
2. Verify all environment variables are set
3. Check database connection (postgres service should start first)
4. Verify S3 credentials are correct

---

## 📝 Key Points

1. **Compose File Location**: Must be in GitHub repository
2. **Service Name**: `directus` (defined in docker-compose.production.yml)
3. **Domain Configuration**: Must be done in Dokploy UI, not just env vars
4. **DNS**: Must point to Dokploy server before SSL will work
5. **Auto-deploy**: Only works after source is configured in Dokploy

---

## 🎯 Quick Checklist

**In Dokploy UI for each app:**
- [ ] Source repository configured
- [ ] Correct branch selected
- [ ] Compose file path set
- [ ] Domain added
- [ ] HTTPS enabled
- [ ] Environment variables present
- [ ] DNS pointing to server

**In GitHub:**
- [x] `docker-compose.production.yml` in repository
- [x] GitHub Actions configured
- [x] Environment variables set
- [x] Branch policies configured

---

**Need Help?**

The main issue is that Dokploy needs to know WHERE to find the compose file. The API calls are working, but Dokploy can't deploy because it doesn't have the source configuration.

Configure the source in Dokploy UI first, then redeploy!
