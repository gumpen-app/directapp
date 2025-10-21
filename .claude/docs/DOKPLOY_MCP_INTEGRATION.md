# Dokploy MCP Integration - Natural Language DevOps

**Created**: 2025-10-21
**Purpose**: Enable natural language control of Dokploy infrastructure via MCP

---

## 🎯 Vision

"I really want AI / DevOps integration for me to natural language everything"

This document tracks the integration of Dokploy MCP server to enable natural language infrastructure management.

---

## ✅ MCP Server Installed

### Configuration Added

File: `.mcp.json`

```json
{
  "mcpServers": {
    "dokploy": {
      "command": "npx",
      "args": ["-y", "@ahdev/dokploy-mcp"],
      "env": {
        "DOKPLOY_URL": "https://deploy.onecom.ai/api",
        "DOKPLOY_API_KEY": "g_appBRUNDztIKIeJvKztXhjQFkUGbsySYCrjpMlHVWUryjEJvsLmaDwbmKigsYLDUJqG"
      },
      "description": "Dokploy DevOps (deployments, domains, projects)"
    }
  }
}
```

### Activation

**For the MCP server to become available**, you need to:

1. **Restart Claude Code** - MCP servers are loaded at startup
2. **Or reload MCP servers** - Check your IDE for "Reload MCP Servers" command

Once loaded, you should see new tools available with the prefix `mcp__dokploy__*`

---

## 🛠️ Available MCP Tools (67 total)

### ✅ What You CAN Do With Natural Language

#### 📊 Project Management (6 tools)
```
"List all projects in Dokploy"
→ Uses: project-all

"Show me project details for G-app"
→ Uses: project-one

"Create a new project called 'test-env'"
→ Uses: project-create

"Update project description"
→ Uses: project-update

"Duplicate the G-app project"
→ Uses: project-duplicate

"Delete the test project"
→ Uses: project-remove
```

#### 🚀 Application Management (26 tools)
```
"Deploy the frontend application"
→ Uses: application-deploy

"Stop the backend app"
→ Uses: application-stop

"Start the API service"
→ Uses: application-start

"Update environment variables for app-xyz"
→ Uses: application-saveEnvironment

"Connect GitHub repo to my application"
→ Uses: application-saveGithubProvider

"Show application monitoring data"
→ Uses: application-readAppMonitoring
```

#### 🌐 Domain Management (9 tools)
```
"List domains for staging compose"
→ Uses: domain-byComposeId

"Add staging-gapp.coms.no domain to compose"
→ Uses: domain-create

"Update domain SSL settings"
→ Uses: domain-update

"Delete old domain"
→ Uses: domain-delete

"Check if my domain DNS is configured correctly"
→ Uses: domain-validateDomain
```

#### 🐘 Database Management (26 tools)
```
"Create a PostgreSQL database"
→ Uses: postgres-create

"Start MySQL database"
→ Uses: mysql-start

"Update database environment variables"
→ Uses: postgres-saveEnvironment
```

---

## ❌ Current Limitations

### What You CANNOT Do (Yet)

#### Compose-Specific Operations

The Dokploy MCP server (as of v1.0) **does not include Compose-specific tools**:

❌ **Cannot:**
- Update Compose environment variables via natural language
- Deploy Compose stacks via MCP
- Get Compose service status
- Restart Compose services
- Read Compose logs

**Why?** The MCP server currently focuses on Applications and Databases, not Docker Compose stacks.

#### Workarounds

**For Compose Operations**, you still need to use:

1. **Dokploy Dashboard** (for env vars)
   ```
   https://deploy.onecom.ai
   → Projects → G-app → Staging Compose → Environment
   ```

2. **Deployment Script** (for deploys)
   ```bash
   ./scripts/deploy.sh staging
   ```

3. **Direct API** (for automation)
   ```bash
   curl -X POST "https://deploy.onecom.ai/api/compose.deploy" \
     -H "x-api-key: $DOKPLOY_API_KEY" \
     -d '{"composeId": "25M8QUdsDQ97nW5YqPYLZ"}'
   ```

---

## 🎯 What We CAN Do With MCP

### Hybrid Approach: MCP + Dashboard

Even though we can't manage Compose env vars via MCP, we CAN:

#### 1. Manage Domains for Compose Services

```
Natural Language Command:
"Add the domain staging-gapp.coms.no to the Directus service in staging compose with SSL enabled"

Uses MCP Tool: domain-create
{
  "host": "staging-gapp.coms.no",
  "port": 8055,
  "https": true,
  "certificateType": "letsencrypt",
  "composeId": "25M8QUdsDQ97nW5YqPYLZ",
  "serviceName": "directus",
  "domainType": "compose"
}
```

This is HUGE because it means:
- ✅ No manual dashboard clicking for domain setup
- ✅ SSL configuration automated
- ✅ Can script domain provisioning

#### 2. Query Infrastructure State

```
"Show me all domains configured for staging"
→ domain-byComposeId → {"composeId": "25M8QUdsDQ97nW5YqPYLZ"}

"List all projects"
→ project-all

"What domains are configured for the G-app project?"
→ Combines project-one + domain queries
```

#### 3. Manage Application Deployments

If we convert our Compose stack to Applications in Dokploy, we'd get:
- ✅ Full environment variable management via MCP
- ✅ Deploy/stop/start via natural language
- ✅ Git integration
- ✅ Build configuration

---

## 💡 Recommended Pattern for DirectApp

### Current Setup (Compose)

```yaml
# docker-compose.staging.yml
services:
  directus:
    labels:
      - "traefik.http.routers.directapp-staging.rule=Host(`staging-gapp.${DOMAIN}`)"
```

**Operations:**
- ❌ Env vars: Dashboard only
- ✅ Domains: Can use MCP!
- ⚠️ Deploy: Script only

### Alternative: Convert to Dokploy Application

**If we migrated from Compose to Dokploy Application:**

```
Directus → Dokploy Application
- Image: directus/directus:11.12.0
- Environment: Managed in Dokploy
- Domains: Managed via MCP
- Deployments: Triggered via MCP
```

**Benefits:**
- ✅ Full MCP control
- ✅ Natural language for everything
- ✅ Better monitoring integration
- ✅ Automated rollbacks

**Tradeoff:**
- ❌ Lose docker-compose.yml simplicity
- ❌ More Dokploy-specific configuration

---

## 📋 Next Steps

### Immediate (Staging Fix)

Since MCP can't update Compose env vars:

1. **Manual**: Update DOMAIN in Dokploy dashboard
   ```
   https://deploy.onecom.ai → G-app → Staging → Environment
   Change: DOMAIN="staging-gapp.coms.no" → DOMAIN="coms.no"
   ```

2. **MCP**: Verify domain exists (optional)
   ```
   "Show domains for staging compose 25M8QUdsDQ97nW5YqPYLZ"
   ```

3. **Script**: Redeploy
   ```bash
   ./scripts/deploy.sh staging
   ```

4. **MCP**: Could add domain programmatically if missing
   ```
   "Create domain staging-gapp.coms.no for staging compose"
   ```

### Future Enhancements

#### Option A: Request Compose Tools in MCP

**File GitHub Issue:**
```
Title: Add Docker Compose Management Tools to MCP Server

Requested Tools:
- compose-deploy
- compose-saveEnvironment
- compose-restart
- compose-logs
- compose-status

Use Case: DirectApp uses Docker Compose for multi-service stacks
(Directus + PostgreSQL + Redis). Need programmatic env management.
```

**Repository**: https://github.com/Dokploy/mcp/issues

#### Option B: Create Custom MCP Extension

**Build our own Compose tools:**

```typescript
// src/mcp/tools/compose/composeEnvironment.ts
export const composeSaveEnvironment = {
  name: "compose-saveEnvironment",
  description: "Update environment variables for Compose service",
  inputSchema: z.object({
    composeId: z.string(),
    env: z.string()
  })
}
```

**Time estimate**: 4-6 hours
**Benefit**: Full control, can contribute back to Dokploy MCP

#### Option C: Migrate to Dokploy Applications

**Convert Compose → Applications:**
- Directus → Application
- PostgreSQL → Managed Database
- Redis → Managed Database

**Time estimate**: 2-3 hours
**Benefit**: Full MCP support immediately

---

## 🎉 What This Enables

### Natural Language DevOps Examples

Once MCP server is loaded:

```
You: "Create a new domain for the staging environment
      at staging-v2.gapp.coms.no with SSL enabled"

Claude: *Uses domain-create tool*
        ✅ Domain created
        ✅ SSL provisioned via Let's Encrypt
        ✅ Traefik updated automatically

You: "Show me all projects and their deployment status"

Claude: *Uses project-all*
        📊 G-app: 3 services (2 running, 1 stopped)
        📊 Organisasjonskart: 1 service (running)
        📊 Gumpen Skade: 2 services (running)

You: "Deploy the frontend application to production"

Claude: *Uses application-deploy*
        🚀 Deployment triggered
        ⏳ Building...
        ✅ Deployed successfully
```

---

## 📊 Integration Status

### Current State

| Feature | Status | Method |
|---------|--------|--------|
| Project Management | ✅ MCP | Natural language |
| Application Deploy | ✅ MCP | Natural language |
| Domain Management | ✅ MCP | Natural language |
| Database Management | ✅ MCP | Natural language |
| **Compose Env Vars** | ❌ Manual | Dashboard only |
| **Compose Deploy** | ⚠️ Script | `./scripts/deploy.sh` |
| **Compose Domains** | ✅ MCP | Natural language |

### Goal State

| Feature | Goal | ETA |
|---------|------|-----|
| Compose Env Vars | ✅ MCP | Pending MCP update or custom extension |
| Compose Deploy | ✅ MCP | Pending MCP update |
| All Infrastructure | ✅ MCP | Q1 2026 |

---

## 🚀 Quick Reference

### MCP Tool Prefixes

```bash
# Once MCP server loads, you'll see:
mcp__dokploy__project-all
mcp__dokploy__application-deploy
mcp__dokploy__domain-create
mcp__dokploy__postgres-create
...67 total tools
```

### Test MCP Connection

```
Natural Language Test:
"List all Dokploy projects"

Expected: Returns list of projects from deploy.onecom.ai
```

### Documentation

- **MCP Server Repo**: https://github.com/Dokploy/mcp
- **Tool Reference**: `/tools/dokploy-mcp/TOOLS.md`
- **MCP Protocol**: https://modelcontextprotocol.io

---

**Last Updated**: 2025-10-21 13:00 UTC
**Status**: MCP configured, pending Claude Code restart
**Next**: Restart IDE → Test natural language commands
