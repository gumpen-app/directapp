# Directus MCP Server - Current Status

**Date**: 2025-10-21
**Directus Version**: 11.12.0 ✅
**MCP Configuration**: ⚠️ Already configured (needs review)

---

## Current Configuration

### .mcp.json Setup

Your project **already has** a Directus MCP server configured:

```json
{
  "mcpServers": {
    "directapp-dev": {
      "command": "npx",
      "args": [
        "-y",
        "@staminna/directus-mcp-server",
        "--url",
        "${DIRECTUS_URL:-http://localhost:8055}",
        "--token",
        "your_local_dev_token_here"
      ],
      "env": {
        "DIRECTUS_URL": "http://localhost:8055"
      },
      "description": "Directus CMS (local development)"
    }
  }
}
```

### Analysis

**Package Used**: `@staminna/directus-mcp-server`
- This is a third-party MCP server implementation
- Not the official Directus v11.12+ built-in MCP server
- May have different capabilities than official server

**Security Issues**: ⚠️

1. **Hardcoded Token**: Token is visible in `.mcp.json`
   - Current: `your_local_dev_token_here`
   - Risk: If committed to git, token is exposed
   - Status: Check `.gitignore` coverage

2. **Token in Git History**:
   ```bash
   # Check if .mcp.json is tracked
   git log --oneline --follow .mcp.json
   ```

---

## Two MCP Approaches

### Approach 1: Third-Party Package (Current)

**Package**: `@staminna/directus-mcp-server`

**Pros**:
- May work with older Directus versions
- Additional features beyond official
- Community-maintained

**Cons**:
- Not official Directus implementation
- May lag behind official features
- Unknown security/maintenance status

**Configuration**:
```json
{
  "mcpServers": {
    "directus": {
      "command": "npx",
      "args": [
        "-y",
        "@staminna/directus-mcp-server",
        "--url",
        "${DIRECTUS_URL}",
        "--token",
        "${DIRECTUS_MCP_TOKEN}"
      ]
    }
  }
}
```

### Approach 2: Official Directus MCP (Recommended)

**Requires**: Directus v11.12+ (you have 11.12.0 ✅)

**Pros**:
- Official Directus implementation
- Built into Directus core
- Full feature support
- Better security model
- Direct from documentation

**Cons**:
- Requires enabling in Directus UI
- Newer, less community experience

**Configuration**:
```json
{
  "mcpServers": {
    "directus": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-fetch",
        "http://localhost:8055/mcp"
      ],
      "env": {
        "HEADERS": "{\"Authorization\": \"Bearer ${DIRECTUS_MCP_TOKEN}\"}"
      }
    }
  }
}
```

**Setup Required**:
1. Enable MCP in: Settings → AI → Model Context Protocol
2. Create dedicated MCP user
3. Generate access token
4. Configure as above

---

## Recommendations

### Option A: Stay with Current Setup (Quick)

**If** the current setup is working:

1. **Secure the token**:
   ```json
   {
     "mcpServers": {
       "directapp-dev": {
         "command": "npx",
         "args": [
           "-y",
           "@staminna/directus-mcp-server",
           "--url",
           "${DIRECTUS_URL}",
           "--token",
           "${DIRECTUS_MCP_TOKEN}"
         ],
         "env": {
           "DIRECTUS_URL": "http://localhost:8055"
         }
       }
     }
   }
   ```

2. **Set environment variable**:
   ```bash
   export DIRECTUS_MCP_TOKEN="your_local_dev_token_here"
   ```

3. **Verify .gitignore**:
   ```bash
   echo ".mcp.json" >> .gitignore  # If not already ignored
   ```

### Option B: Switch to Official (Recommended)

**Better long-term support and security:**

1. **Enable official MCP** in Directus UI
2. **Create dedicated MCP user** (not admin)
3. **Update .mcp.json** to use official endpoint
4. **Test connection** with schema query
5. **Remove old token** from Directus

See: `.claude/docs/MCP_QUICK_START.md` for full instructions

---

## Security Checklist

### Immediate Actions

- [ ] Check if `.mcp.json` is in git history
- [ ] Check if `.mcp.json` is in `.gitignore`
- [ ] Move token to environment variable
- [ ] Verify token is still valid
- [ ] Test current MCP connection

### Long-term Actions

- [ ] Evaluate third-party vs official MCP
- [ ] Create dedicated MCP user (not admin)
- [ ] Set minimal permissions
- [ ] Enable delete protection
- [ ] Document token rotation schedule

---

## Testing Current Setup

### 1. Check if MCP is working

Ask Claude Code:
```
Can you tell me about my Directus schema?
```

Expected: List of collections (cars, dealerships, etc.)

### 2. Verify token validity

```bash
curl -H "Authorization: Bearer your_local_dev_token_here" \
  http://localhost:8055/items/directus_collections

# Should return: Collection list (HTTP 200)
# If error: Token invalid or expired
```

### 3. Check package availability

```bash
npx @staminna/directus-mcp-server --help
```

---

## Migration Path (Third-party → Official)

### Step 1: Backup Current Config

```bash
cp .mcp.json .mcp.json.backup
```

### Step 2: Enable Official MCP

1. Login: http://localhost:8055/admin
2. Settings → AI → Model Context Protocol
3. Toggle: MCP Server = ON
4. Save

### Step 3: Create New MCP User

1. User Directory → Create User
2. Email: `mcp-official@localhost`
3. Role: Administrator (restrict later)
4. Generate token → Copy
5. Save

### Step 4: Update .mcp.json

```json
{
  "mcpServers": {
    "directus-official": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-fetch",
        "http://localhost:8055/mcp"
      ],
      "env": {
        "HEADERS": "{\"Authorization\": \"Bearer ${DIRECTUS_MCP_TOKEN}\"}"
      },
      "description": "Official Directus MCP (v11.12+)"
    }
  }
}
```

### Step 5: Set Token

```bash
export DIRECTUS_MCP_TOKEN="[new token from step 3]"
```

### Step 6: Test

Restart Claude Code, then:
```
Can you tell me about my Directus schema?
```

### Step 7: Cleanup (if successful)

1. Remove old third-party config from .mcp.json
2. Delete old MCP user token in Directus
3. Remove backup if not needed

---

## Additional MCP Servers Configured

Your `.mcp.json` also has:

1. **GitHub** - Issues, PRs, Projects
2. **Context7** - Documentation search
3. **Local FS** - Filesystem access

All working together with Directus MCP! 🎉

---

## Quick Actions

### Check Token in Git

```bash
# See if .mcp.json is tracked
git log --oneline -- .mcp.json

# Check .gitignore
grep -E "\.mcp\.json" .gitignore

# If not ignored, add it:
echo ".mcp.json" >> .gitignore
git add .gitignore
git commit -m "chore: Ignore .mcp.json to protect tokens"
```

### Secure Current Setup

```bash
# 1. Store current token
export DIRECTUS_MCP_TOKEN="your_local_dev_token_here"

# 2. Update .mcp.json (replace hardcoded token)
# Change: "--token", "your_local_dev_token_here"
# To:     "--token", "${DIRECTUS_MCP_TOKEN}"

# 3. Add to shell profile
echo 'export DIRECTUS_MCP_TOKEN="your_local_dev_token_here"' >> ~/.bashrc
```

### Test Connection

```bash
# Test API access
curl -H "Authorization: Bearer your_local_dev_token_here" \
  http://localhost:8055/server/info

# Expected: Server info JSON
```

---

## Resources

**Configuration Guides**:
- Quick Start: `.claude/docs/MCP_QUICK_START.md`
- Full Guide: `.claude/docs/DIRECTUS_MCP_SERVER.md`

**Official Docs**:
- Directus MCP: https://directus.io/docs/guides/ai/mcp
- Installation: https://directus.io/docs/guides/ai/mcp/installation
- Security: https://directus.io/docs/guides/ai/mcp/security

**Third-Party Package**:
- GitHub: https://github.com/staminna/directus-mcp-server
- npm: https://www.npmjs.com/package/@staminna/directus-mcp-server

---

## Decision Matrix

| Criteria | Third-Party (Current) | Official (Recommended) |
|----------|----------------------|------------------------|
| Version Support | Any Directus | v11.12+ only |
| Security | Community | Official |
| Features | May vary | Full official |
| Maintenance | Community | Directus team |
| Documentation | Package docs | Official docs |
| Setup | Already done ✅ | Needs enabling |
| Token Security | ⚠️ Exposed | Can be secured |

**Recommendation**: Switch to official for better long-term support and security.

---

**Status**: ⚠️ MCP configured but needs security review
**Priority**: Medium (working but insecure token)
**Next Steps**: Secure token OR migrate to official

---

**Last Updated**: 2025-10-21
