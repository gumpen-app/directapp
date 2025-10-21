# DirectApp - GitHub Secrets Setup

Configure GitHub repository secrets for automated CI/CD deployment to Dokploy.

**Last Updated:** 2025-10-21

---

## Overview

GitHub Actions needs these secrets to automatically deploy DirectApp to Dokploy staging/production environments.

**What GitHub Secrets Do:**
- Authenticate with Dokploy API
- Trigger deployments to staging (auto)
- Trigger deployments to production (manual)
- Access Dokploy compose services

---

## Required Secrets

| Secret Name | Value | Purpose |
|-------------|-------|---------|
| `DOKPLOY_URL` | `https://deploy.onecom.ai` | Dokploy server URL |
| `DOKPLOY_API_KEY` | See below | API authentication token |
| `DOKPLOY_STAGING_ID` | `25M8QUdsDQ97nW5YqPYLZ` | Staging compose service ID |
| `DOKPLOY_PRODUCTION_ID` | `YKhjz62y5ikBunLd6G2BS` | Production compose service ID |

---

## Method 1: GitHub Web UI (Recommended)

### Step 1: Navigate to Secrets

1. Go to your repository: https://github.com/gumpen-app/directapp
2. Click **Settings** (top menu)
3. Click **Secrets and variables** (left sidebar)
4. Click **Actions**
5. Click **New repository secret**

### Step 2: Add Each Secret

**Add DOKPLOY_URL:**
- Name: `DOKPLOY_URL`
- Secret: `https://deploy.onecom.ai`
- Click **Add secret**

**Add DOKPLOY_API_KEY:**
- Name: `DOKPLOY_API_KEY`
- Secret: `g_appBRUNDztIKIeJvKztXhjQFkUGbsySYCrjpMlHVWUryjEJvsLmaDwbmKigsYLDUJqG`
- Click **Add secret**

**Add DOKPLOY_STAGING_ID:**
- Name: `DOKPLOY_STAGING_ID`
- Secret: `25M8QUdsDQ97nW5YqPYLZ`
- Click **Add secret**

**Add DOKPLOY_PRODUCTION_ID:**
- Name: `DOKPLOY_PRODUCTION_ID`
- Secret: `YKhjz62y5ikBunLd6G2BS`
- Click **Add secret**

### Step 3: Verify

After adding all secrets, you should see:

```
Repository secrets (4)

DOKPLOY_URL                   Updated X minutes ago
DOKPLOY_API_KEY               Updated X minutes ago
DOKPLOY_STAGING_ID            Updated X minutes ago
DOKPLOY_PRODUCTION_ID         Updated X minutes ago
```

---

## Method 2: GitHub CLI (Faster)

### Prerequisites

Install GitHub CLI:
```bash
# macOS
brew install gh

# Ubuntu/Debian
sudo apt install gh

# Or download from: https://cli.github.com
```

### Authenticate

```bash
gh auth login
```

### Add All Secrets

```bash
# Navigate to repository
cd /path/to/directapp

# Add secrets
gh secret set DOKPLOY_URL -b "https://deploy.onecom.ai"
gh secret set DOKPLOY_API_KEY -b "g_appBRUNDztIKIeJvKztXhjQFkUGbsySYCrjpMlHVWUryjEJvsLmaDwbmKigsYLDUJqG"
gh secret set DOKPLOY_STAGING_ID -b "25M8QUdsDQ97nW5YqPYLZ"
gh secret set DOKPLOY_PRODUCTION_ID -b "YKhjz62y5ikBunLd6G2BS"
```

### Verify

```bash
gh secret list
```

Expected output:
```
DOKPLOY_URL                   Updated X minutes ago
DOKPLOY_API_KEY               Updated X minutes ago
DOKPLOY_STAGING_ID            Updated X minutes ago
DOKPLOY_PRODUCTION_ID         Updated X minutes ago
```

---

## Method 3: Automated Script

### Create Setup Script

Create `scripts/setup-github-secrets.sh`:

```bash
#!/bin/bash
# Setup GitHub Secrets for DirectApp

set -e

echo "🔐 Setting up GitHub Secrets for DirectApp"
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) not installed"
    echo "Install: https://cli.github.com"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "🔑 Please authenticate with GitHub"
    gh auth login
fi

echo "Adding secrets..."

# Add secrets
gh secret set DOKPLOY_URL -b "https://deploy.onecom.ai"
gh secret set DOKPLOY_API_KEY -b "g_appBRUNDztIKIeJvKztXhjQFkUGbsySYCrjpMlHVWUryjEJvsLmaDwbmKigsYLDUJqG"
gh secret set DOKPLOY_STAGING_ID -b "25M8QUdsDQ97nW5YqPYLZ"
gh secret set DOKPLOY_PRODUCTION_ID -b "YKhjz62y5ikBunLd6G2BS"

echo ""
echo "✅ All secrets added successfully!"
echo ""
echo "Verify with: gh secret list"
```

### Run Script

```bash
chmod +x scripts/setup-github-secrets.sh
./scripts/setup-github-secrets.sh
```

---

## Getting the Dokploy API Key

If you need to regenerate the API key:

### Via Dokploy UI

1. Login to Dokploy: https://deploy.onecom.ai
2. Click your profile (top right)
3. Click **Settings**
4. Click **API/CLI** tab
5. Click **Generate Token**
6. Copy the token
7. Update `DOKPLOY_API_KEY` secret in GitHub

### Current API Key

The current API key for DirectApp is:
```
g_appBRUNDztIKIeJvKztXhjQFkUGbsySYCrjpMlHVWUryjEJvsLmaDwbmKigsYLDUJqG
```

**Expires:** Check Dokploy UI for expiration date

---

## Getting Compose Service IDs

If you need to find the compose service IDs:

### Via Dokploy UI

1. Login to Dokploy: https://deploy.onecom.ai
2. Navigate to project: **G-app**
3. Click on service (staging or production)
4. Look at URL in browser:
   ```
   https://deploy.onecom.ai/dashboard/project/<project-id>/services/compose/<compose-id>
   ```
5. The `<compose-id>` is what you need

### Via Dokploy API

```bash
API_KEY="g_appBRUNDztIKIeJvKztXhjQFkUGbsySYCrjpMlHVWUryjEJvsLmaDwbmKigsYLDUJqG"

# List all projects
curl -s "https://deploy.onecom.ai/api/project.all" \
  -H "x-api-key: $API_KEY" | jq .

# Find compose services
# (Look for services named "staging" and "production")
```

### Current IDs

| Environment | Compose ID |
|------------|-----------|
| **Staging** | `25M8QUdsDQ97nW5YqPYLZ` |
| **Production** | `YKhjz62y5ikBunLd6G2BS` |

---

## Testing GitHub Actions

After adding secrets, test the CI/CD pipeline:

### Test 1: Push to Main (Auto-deploy Staging)

```bash
# Make a small change
echo "# Test" >> README.md

# Commit and push
git add README.md
git commit -m "test: trigger CI/CD"
git push origin main
```

**Expected:**
1. GitHub Actions runs
2. Builds extensions
3. Auto-deploys to staging
4. Staging accessible at: https://staging-gapp.coms.no

### Test 2: Manual Production Deployment

1. Go to: https://github.com/gumpen-app/directapp/actions
2. Click **DirectApp CI/CD** workflow
3. Click **Run workflow** dropdown
4. Select **main** branch
5. Click **Run workflow**

**Expected:**
1. GitHub Actions runs
2. Builds extensions
3. Deploys to production (requires approval)
4. Production accessible at: https://gapp.coms.no

---

## Troubleshooting

### Secret Not Found Error

**Problem:**
```
Error: Secret DOKPLOY_API_KEY not found
```

**Solution:**
1. Verify secret name is exact (case-sensitive)
2. Check secret is in correct repository
3. Re-add secret via GitHub UI or CLI

### Authentication Failed

**Problem:**
```
Error: 401 Unauthorized
```

**Solutions:**
1. Verify `DOKPLOY_API_KEY` is correct
2. Check API key hasn't expired in Dokploy
3. Regenerate API key in Dokploy if needed
4. Update GitHub secret with new key

### Deployment Not Triggered

**Problem:** Push to main doesn't trigger deployment

**Solutions:**
1. Check GitHub Actions is enabled:
   - Settings → Actions → General → Allow all actions
2. Verify workflow file exists: `.github/workflows/directus-ci.yml`
3. Check workflow syntax is valid
4. Look at Actions tab for errors

### Wrong Compose ID

**Problem:**
```
Error: Compose service not found
```

**Solutions:**
1. Verify `DOKPLOY_STAGING_ID` and `DOKPLOY_PRODUCTION_ID`
2. Check IDs in Dokploy UI (URL bar)
3. Update GitHub secrets with correct IDs

---

## Security Best Practices

### DO ✅

1. ✅ Keep API keys secret (never commit to code)
2. ✅ Use GitHub secrets (encrypted at rest)
3. ✅ Rotate API keys quarterly
4. ✅ Limit API key permissions if possible
5. ✅ Monitor GitHub Actions logs for unauthorized access
6. ✅ Use different API keys for different projects

### DON'T ❌

1. ❌ Commit secrets to Git
2. ❌ Share secrets via email/chat
3. ❌ Log secrets in GitHub Actions
4. ❌ Use personal API keys for CI/CD
5. ❌ Store secrets in plaintext files
6. ❌ Reuse API keys across multiple services

---

## Rotating Secrets

### When to Rotate

Rotate secrets:
- ✅ Quarterly (every 3 months)
- ✅ When team member leaves
- ✅ If key is compromised
- ✅ After security incident

### How to Rotate

**Step 1: Generate New API Key**
1. Login to Dokploy
2. Settings → API/CLI → Generate Token
3. Copy new token

**Step 2: Update GitHub Secret**
```bash
gh secret set DOKPLOY_API_KEY -b "new-api-key-here"
```

**Step 3: Revoke Old Key**
1. In Dokploy: Settings → API/CLI
2. Delete old token

**Step 4: Test**
```bash
# Trigger workflow to verify
git push origin main
```

---

## Environment-Specific Secrets

If you need different secrets per environment:

### Setup

```bash
# Staging secrets
gh secret set DOKPLOY_STAGING_API_KEY -b "staging-key"
gh secret set STAGING_DB_PASSWORD -b "staging-db-pass"

# Production secrets
gh secret set DOKPLOY_PRODUCTION_API_KEY -b "production-key"
gh secret set PRODUCTION_DB_PASSWORD -b "production-db-pass"
```

### Use in Workflow

```yaml
# .github/workflows/directus-ci.yml
- name: Deploy to staging
  env:
    API_KEY: ${{ secrets.DOKPLOY_STAGING_API_KEY }}
    DB_PASSWORD: ${{ secrets.STAGING_DB_PASSWORD }}

- name: Deploy to production
  env:
    API_KEY: ${{ secrets.DOKPLOY_PRODUCTION_API_KEY }}
    DB_PASSWORD: ${{ secrets.PRODUCTION_DB_PASSWORD }}
```

---

## Verification Checklist

After setup, verify:

- [ ] All 4 secrets added to GitHub
- [ ] Secret names match workflow file exactly
- [ ] API key is valid (test with `curl`)
- [ ] Compose IDs are correct
- [ ] GitHub Actions enabled
- [ ] Test deployment to staging works
- [ ] Test manual production deployment works

---

## Next Steps

1. ✅ Add all GitHub secrets (this guide)
2. ✅ Push to main to trigger staging deployment
3. ✅ Verify staging deployment succeeded
4. ✅ Test staging environment
5. ✅ Manually deploy to production
6. ✅ Verify production deployment succeeded

---

## Additional Resources

- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [Dokploy API Documentation](https://docs.dokploy.com/docs/api)
- [Environment Setup Guide](./ENVIRONMENT_SETUP.md)

---

**Questions?** Create an [issue](https://github.com/gumpen-app/directapp/issues) or check the docs.
