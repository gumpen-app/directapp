# Directus MCP Server - Quick Start

**Status**: ✅ Compatible (Directus v11.12.0)
**Server URL**: http://localhost:8055/mcp
**Setup Time**: ~5 minutes

---

## 🚀 Quick Setup (5 Steps)

### Step 1: Start Dev Server

```bash
pnpm dev
# or
docker compose -f docker-compose.dev.yml up
```

Wait for: `Directus started at http://localhost:8055`

### Step 2: Enable MCP in Directus

1. Open: http://localhost:8055/admin
2. Login: `admin@example.com` / `admin`
3. Navigate: **Settings → AI → Model Context Protocol**
4. Toggle: **MCP Server = ON**
5. Click: **Save**

### Step 3: Create MCP User

1. Go to: **User Directory → Create User**
2. Fill in:
   - First Name: `MCP`
   - Last Name: `Dev`
   - Email: `mcp@localhost`
   - Role: `Administrator` (for now, restrict later)
3. Click: **Save**
4. Open user profile → **Token** section
5. Click: **Generate** → Copy token
6. Click: **Save**

### Step 4: Configure Claude Code

Add to `.mcp.json`:

```json
{
  "mcpServers": {
    "directus-local": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-fetch",
        "http://localhost:8055/mcp"
      ],
      "env": {
        "HEADERS": "{\"Authorization\": \"Bearer YOUR_TOKEN_HERE\"}"
      }
    }
  }
}
```

**Important**: Replace `YOUR_TOKEN_HERE` with the token from Step 3.

### Step 5: Test Connection

Restart Claude Code, then ask:

```
Can you tell me about my Directus schema?
```

Expected: List of collections (cars, dealerships, users, etc.)

---

## 🎯 Common Tasks

### Explore Schema

```
Q: What collections exist?
Q: Show me fields in the cars collection
Q: What relationships connect cars to dealerships?
```

### Create Test Data

```
Q: Create a test car:
- VIN: TEST123
- Make: Tesla
- Model: Model 3
- Year: 2024
- Status: available
```

### Analyze Data

```
Q: How many cars are available vs sold?
Q: Which dealership has the most cars?
Q: Show me all cars from 2024
```

### Prototype Schema

```
Q: Add a new field 'last_service_date' to cars (date type)
Q: Create a maintenance_logs collection with fields for date, type, and cost
Q: Link maintenance_logs to cars with a M2O relationship
```

---

## ⚙️ Configuration Options

### Use Environment Variable (Recommended)

Instead of hardcoding token in `.mcp.json`:

```bash
# Add to ~/.bashrc or ~/.zshrc
export DIRECTUS_MCP_TOKEN="your_token_here"
```

Then in `.mcp.json`:

```json
{
  "mcpServers": {
    "directus-local": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-fetch", "http://localhost:8055/mcp"],
      "env": {
        "HEADERS": "{\"Authorization\": \"Bearer ${DIRECTUS_MCP_TOKEN}\"}"
      }
    }
  }
}
```

### Multiple Environments

```json
{
  "mcpServers": {
    "directus-local": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-fetch", "http://localhost:8055/mcp"],
      "env": {
        "HEADERS": "{\"Authorization\": \"Bearer ${DIRECTUS_LOCAL_TOKEN}\"}"
      }
    },
    "directus-staging": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-fetch", "https://staging.directapp.no/mcp"],
      "env": {
        "HEADERS": "{\"Authorization\": \"Bearer ${DIRECTUS_STAGING_TOKEN}\"}"
      }
    }
  }
}
```

---

## 🔒 Security Checklist

**Before Using in Production:**

- [ ] Create dedicated MCP user (not admin)
- [ ] Set minimal permissions on role
- [ ] Disable delete operations
- [ ] Store token in environment variable
- [ ] Never commit token to git
- [ ] Enable global delete protection
- [ ] Review all AI suggestions before approving
- [ ] Monitor activity logs regularly

**Dev Setup (Quick Start):**

- [ ] Admin user is OK for local dev
- [ ] Token in .mcp.json is OK (add to .gitignore)
- [ ] Manual review before approving operations

---

## 🛠️ Troubleshooting

### "Cannot connect to MCP server"

```bash
# 1. Check Directus is running
curl http://localhost:8055/server/health

# 2. Verify MCP is enabled
# Settings → AI → MCP Server = ON

# 3. Test token manually
curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:8055/mcp

# 4. Check .mcp.json syntax (valid JSON)
cat .mcp.json | jq .

# 5. Restart Claude Code
```

### "Permission denied"

```bash
# Check user role has permissions:
# Settings → Access Control → [Role] → Collections
# Enable: Create, Read, Update (Delete optional)
```

### "No collections found"

```bash
# Verify schema exists
# Settings → Data Model → Collections
# Should see: cars, dealerships, users, etc.
```

---

## 📚 Examples for DirectApp

### 1. Schema Exploration

```
"Show me the complete schema for the cars collection including all fields and their types"

"What relationships exist between cars, dealerships, and users?"

"List all collections and their primary uses"
```

### 2. Test Data Creation

```
"Create 3 test dealerships:
- Oslo Motors (Oslo)
- Bergen Auto (Bergen)
- Trondheim Wheels (Trondheim)"

"Create 5 test cars with random data, assigned to different dealerships"
```

### 3. Data Analysis

```
"Count all cars grouped by status"

"Show me the average price per make"

"Which dealerships have no cars assigned?"
```

### 4. Prototyping Features

```
"I want to add a service history feature. Create:
1. maintenance_logs collection
2. Fields: service_date, service_type, cost, notes
3. M2O relationship to cars
4. Display template for the collection"
```

### 5. Workflow Testing

```
"Create a flow that triggers when a car is marked as sold and:
1. Sets sold_date to today
2. Sends notification to dealership manager
3. Updates inventory count"
```

---

## 🎓 Best Practices

### DO ✅

- Start with schema exploration (read-only)
- Use for prototyping new features
- Generate test data quickly
- Analyze data patterns
- Review every AI suggestion before approval
- Use for learning Directus concepts

### DON'T ❌

- Auto-approve operations
- Use for bulk data migrations (>100 items)
- Modify production data
- Share tokens
- Commit tokens to git
- Trust unexpected AI suggestions blindly

---

## 🔗 More Information

**Full Guide**: `.claude/docs/DIRECTUS_MCP_SERVER.md`
**Official Docs**: https://directus.io/docs/guides/ai/mcp
**Security**: https://directus.io/docs/guides/ai/mcp/security

---

## ✅ Setup Checklist

Quick validation before first use:

- [ ] Directus running at http://localhost:8055
- [ ] Admin login works (admin@example.com / admin)
- [ ] MCP enabled in Settings → AI
- [ ] MCP user created with token
- [ ] .mcp.json configured with token
- [ ] Claude Code restarted
- [ ] Test query successful ("What collections exist?")

**Status**: Ready to use! 🎉

---

**Last Updated**: 2025-10-21
**Directus Version**: 11.12.0 ✅
**MCP Support**: Full
