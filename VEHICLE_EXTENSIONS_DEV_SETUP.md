# Vehicle Extensions - Development Setup (Quick Guide)

**Date**: 2025-10-29
**Status**: ✅ Simple setup using staging tokens

---

## TL;DR - 2 Minute Setup

Since **staging already has all environment variables configured**, just copy the token values to dev.

### Step 1: Get Token from Staging

Check staging environment configuration (Dokploy or `.env` file on staging server):

```bash
# If you have SSH access to staging
ssh staging-server
cat .env | grep STATENS_VEGVESEN_TOKEN

# Or check Dokploy environment variables for directapp-staging
```

### Step 2: Add to Development `.env`

```bash
# In project root
echo "STATENS_VEGVESEN_TOKEN=your-token-from-staging" >> .env
```

### Step 3: Restart Development Environment

```bash
docker compose -f docker-compose.dev.yml restart directus
```

### Step 4: Verify It Works

```bash
# Health check (should show configured: true)
curl http://localhost:8055/directapp-endpoint-vehicle-lookup/health

# Expected:
# {"status":"healthy","configured":true}
```

**Done!** ✅ vehicle-lookup now works in development with the same token as staging.

---

## Why This Works

### Same Extension, Same API
- Development and staging use the **same extension code**
- Both call the **same external API** (Statens Vegvesen)
- The API token works in **both environments**

### No Separate Tokens Needed
- **One token** can be used across all environments
- Staging has production-like token? Use it in dev too
- Staging has test token? That's fine for development

### Environment Isolation
- Token value might be different per environment (test vs production)
- But the **variable name** is the same: `STATENS_VEGVESEN_TOKEN`
- Development just needs *a* valid token, doesn't matter which one

---

## Complete Development `.env` Setup

If you want to copy **all** the relevant tokens from staging to dev:

```bash
# Norwegian Vehicle Registry API
STATENS_VEGVESEN_TOKEN=your-token-from-staging

# OpenAI API (for ask-cars-ai extension)
OPENAI_API_KEY=your-openai-key-from-staging

# Any other API tokens staging uses
# Just copy them to dev for consistent behavior
```

**Restart after adding**:
```bash
docker compose -f docker-compose.dev.yml restart directus
```

---

## Verification Checklist

After copying tokens from staging:

### 1. Check vehicle-lookup
```bash
curl http://localhost:8055/directapp-endpoint-vehicle-lookup/health
# Expected: {"status":"healthy","configured":true}
```

### 2. Test vehicle-search (should already work)
```bash
TOKEN="your-dev-admin-token"
curl -X GET "http://localhost:8055/directapp-endpoint-vehicle-search/stats" \
  -H "Authorization: Bearer $TOKEN"
```

### 3. Test ask-cars-ai (if OpenAI key added)
```bash
curl -X POST "http://localhost:8055/directapp-endpoint-ask-cars-ai/" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query":"Find all Toyota cars"}'
```

---

## Token Management

### Where to Get Staging Tokens

**Option 1: Dokploy Dashboard**
1. Log into Dokploy
2. Find directapp-staging service
3. Go to Environment Variables
4. Copy `STATENS_VEGVESEN_TOKEN` value

**Option 2: SSH to Staging Server**
```bash
ssh staging-server
docker exec directapp-staging env | grep STATENS_VEGVESEN_TOKEN
```

**Option 3: Check Staging Config**
```bash
# If staging .env is in git (shouldn't be, but might be .env.example)
cat .env.staging
```

### Security Note

- **DO NOT commit tokens to git**
- Keep `.env` in `.gitignore`
- Use `.env.example` with placeholder values
- Share tokens via secure channels (password manager, encrypted chat)

---

## Troubleshooting

### "Health shows configured: false"

**Problem**: Token not set in dev environment

**Fix**:
```bash
# Check if token is set
docker exec directapp-dev env | grep STATENS_VEGVESEN_TOKEN

# If empty, add to .env and restart
echo "STATENS_VEGVESEN_TOKEN=your-token" >> .env
docker compose -f docker-compose.dev.yml restart directus
```

### "API returns 401 or 403"

**Problem**: Token is invalid or expired

**Possible causes**:
- Copied token incorrectly (whitespace, quotes)
- Token expired
- Token doesn't have required permissions

**Fix**:
1. Verify token in staging still works
2. Check token has no extra whitespace
3. Regenerate token if expired

### "API returns 503"

**Problem**: External API (Statens Vegvesen) is unavailable

**Check**:
- Is staging vehicle-lookup working?
- Is Statens Vegvesen API up?
- Check Directus logs for detailed error

---

## Summary

| Task | Command | Time |
|------|---------|------|
| Get staging token | Check Dokploy/SSH | 1 min |
| Add to dev `.env` | `echo "STATENS_VEGVESEN_TOKEN=..." >> .env` | 10 sec |
| Restart dev | `docker compose -f docker-compose.dev.yml restart directus` | 30 sec |
| Verify | `curl localhost:8055/directapp-endpoint-vehicle-lookup/health` | 10 sec |

**Total**: ~2 minutes ✅

---

## Key Insight

**Staging has all the working environment variables.**

Instead of:
- ❌ Getting new API tokens for development
- ❌ Signing up for separate test accounts
- ❌ Configuring each extension individually

Just:
- ✅ Copy token values from staging to dev
- ✅ Restart development environment
- ✅ Done

**Development should mirror staging configuration for consistency.**
