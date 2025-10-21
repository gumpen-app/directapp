# Directus MCP Server - Development Guide

**Official Documentation**: https://directus.io/docs/guides/ai/mcp
**Status**: Beta (Requires Directus v11.12+)
**Last Updated**: 2025-10-21

---

## Overview

The Directus Model Context Protocol (MCP) server enables AI assistants (Claude, ChatGPT, Cursor) to directly interact with your Directus instance for content management, schema operations, and workflow automation.

### Key Benefits

- **Direct Database Access**: No middleware, no data copying
- **Permission-Based**: Uses existing Directus RBAC
- **Audit Trail**: Complete activity logging
- **Multi-Tool Support**: Works with Claude Code, Claude Desktop, ChatGPT, Cursor, Raycast

---

## Setup for Development

### 1. Enable MCP in Directus

```bash
# Login as admin
# Navigate to: Settings → AI → Model Context Protocol
# Toggle: MCP Server = ON
# Save settings

# Server available at:
# https://your-directus-url.com/mcp
```

For local development:
```
http://localhost:8055/mcp
```

### 2. Create Dedicated MCP User

**Best Practice**: Use dedicated user (not admin) with specific role permissions.

```bash
# Via Directus Admin UI:
# 1. User Directory → Create User
# 2. Configure:
#    - First Name: "MCP"
#    - Last Name: "Client"
#    - Email: mcp@localhost
#    - Role: [Create custom role - see below]
# 3. Open user profile → Token section
# 4. Generate token → Copy for later
# 5. Save user
```

### 3. Configure Role Permissions

**For Content Development** (Recommended):
- Collections: Create, Read, Update
- Files: Create, Read, Update
- Delete: **DISABLED** (safety)
- Admin Access: **DISABLED**

**For Schema Development** (Use with caution):
- Collections: Full CRUD
- Fields: Full CRUD
- Relations: Full CRUD
- Flows: Full CRUD
- Admin Access: Limited

**For Analysis Only**:
- Collections: Read only
- Files: Read only

### 4. Configure Claude Code (.mcp.json)

Add to your `.mcp.json` configuration:

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
        "HEADERS": "{\"Authorization\": \"Bearer YOUR_ACCESS_TOKEN_HERE\"}"
      }
    },
    "directus-staging": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-fetch",
        "https://staging.your-domain.com/mcp"
      ],
      "env": {
        "HEADERS": "{\"Authorization\": \"Bearer YOUR_STAGING_TOKEN_HERE\"}"
      }
    }
  }
}
```

**Security**: Never commit tokens to git. Use environment variables:

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
        "HEADERS": "{\"Authorization\": \"Bearer ${DIRECTUS_MCP_TOKEN}\"}"
      }
    }
  }
}
```

Then set in your shell:
```bash
export DIRECTUS_MCP_TOKEN="your_token_here"
```

### 5. Verify Connection

Test with Claude Code:
```
"Can you tell me about my Directus schema?"
```

Expected response: List of collections, fields, and relationships.

---

## Available Capabilities

### Content Management

**Creating Items**:
```
"Create a new dealership with name 'Oslo Motors' and location 'Oslo, Norway'"
```

**Updating Items**:
```
"Update the car with VIN ABC123 to set status as 'available'"
```

**Relationships**:
```
"Assign the car with ID 5 to dealership 'Oslo Motors'"
```

### Asset Management

**File Organization**:
```
"Organize all PDF files into a folder called 'Documents'"
```

**Metadata**:
```
"Add alt text to all car images: 'Car photo - [make] [model]'"
```

### Schema Operations (Admin Role Required)

**Creating Collections**:
```
"Create a collection called 'maintenance_records' with fields:
- car_id (M2O to cars)
- service_date (date)
- service_type (dropdown: oil_change, tire_rotation, inspection)
- notes (textarea)
- cost (decimal)"
```

**Setting Up Relationships**:
```
"Create a Many-to-Many relationship between cars and features"
```

**Building Flows**:
```
"Create a flow that sends a notification when a car status changes to 'sold'"
```

---

## Use Cases for DirectApp Development

### 1. Schema Prototyping

```
"I need to add a service history feature. Create:
- maintenance_logs collection with fields for date, type, cost, and notes
- Link it to cars with a one-to-many relationship
- Add a display template showing the most recent service"
```

### 2. Data Seeding

```
"Create 5 test cars with:
- Different makes and models
- Random VINs
- Assigned to different dealerships
- Mix of available and sold statuses"
```

### 3. Content Migration

```
"Import this CSV of car data into the cars collection, mapping:
- Column 'Vehicle ID' → field 'vin'
- Column 'Make/Model' → split into 'make' and 'model'
- Column 'Price' → field 'price'"
```

### 4. Workflow Automation

```
"Create a flow that:
1. Triggers when a car is marked as sold
2. Updates the sold_date field
3. Sends a notification to the dealership manager
4. Creates a sale record in the sales collection"
```

### 5. UI Configuration

```
"Configure the cars collection display:
- List view should show: VIN, make, model, year, status, dealership
- Detail view should group fields: Vehicle Info, Pricing, Location
- Add conditional formatting: green for available, red for sold"
```

---

## Security Best Practices

### Development Environment

✅ **DO:**
- Create separate MCP users for dev/staging/production
- Use read-only tokens for analysis/debugging
- Enable delete protection globally
- Review all AI-suggested operations before approval
- Rotate tokens monthly
- Monitor activity logs for unusual patterns

❌ **DON'T:**
- Use admin tokens for routine MCP access
- Enable auto-approval of tool calls
- Commit tokens to version control
- Share tokens across team members
- Use production tokens in development

### Token Management

```bash
# Generate new token
# Directus Admin → User Directory → [MCP User] → Token → Generate

# Store in environment (not in code)
export DIRECTUS_MCP_TOKEN="your_token_here"

# Rotate regularly (monthly recommended)
# 1. Generate new token
# 2. Update environment variable
# 3. Delete old token in Directus
```

### Permission Isolation

**Development** (.env.development):
- MCP User: `mcp-dev@localhost`
- Role: Developer (schema + content)
- Delete: Protected globally

**Staging** (.env.staging):
- MCP User: `mcp-staging@company.com`
- Role: Content Editor (no schema changes)
- Delete: Disabled

**Production** (use with extreme caution):
- MCP User: `mcp-prod@company.com`
- Role: Read-Only Analyst
- Delete: Disabled
- Recommendation: **Avoid MCP in production** unless absolutely necessary

---

## Threat Mitigation

### 1. Data Exposure Risk

**Threat**: AI conversations may be indexed, shared, or used for training.

**Mitigation**:
- Disable conversation training in Claude settings
- Avoid sharing conversation links containing sensitive data
- Use local development data (not production)
- Review AI provider's data policies

### 2. Prompt Injection

**Threat**: Malicious content can manipulate AI to perform unintended actions.

**Mitigation**:
- Manually review all tool calls before approval
- Avoid using web research with MCP active
- Don't browse untrusted content during MCP sessions
- Verify unexpected AI suggestions

### 3. Mixed MCP Servers

**Threat**: Untrusted MCP servers can access Directus data through conversation context.

**Mitigation**:
- Only connect trusted MCP servers
- Separate conversations for different MCP contexts
- Review all active MCP connections regularly

### 4. Auto-Approval Risk

**Threat**: Automatic approval enables unreviewed deletions and modifications.

**Mitigation**:
- **Never enable auto-approval**
- Read each tool call description carefully
- Enable global delete protection
- Set up activity log monitoring

---

## Monitoring & Auditing

### Activity Log Review

Check regularly for:
- ✅ Expected operations during work hours
- ⚠️ Mass deletions or updates
- ⚠️ Unauthorized collection access
- ⚠️ Off-hours activity
- ⚠️ Failed authentication attempts

```bash
# Via Directus Admin UI:
# Settings → Activity Log
# Filter by:
# - User: [MCP User]
# - Action: Create, Update, Delete
# - Date Range: Last 7 days
```

### Monthly Security Checklist

- [ ] Review MCP user permissions
- [ ] Rotate access tokens
- [ ] Audit activity logs
- [ ] Verify delete protection enabled
- [ ] Check for unused MCP users
- [ ] Update role permissions if needed

---

## Integration with DirectApp Workflow

### During Development (/core:work)

```bash
# 1. Start work session
/core:work

# 2. Use MCP for schema exploration
"Show me the current schema for the cars collection"

# 3. Prototype new features
"Add a new field 'inspection_date' to cars collection (date type)"

# 4. Seed test data
"Create 3 test dealerships in Oslo, Bergen, and Trondheim"

# 5. Validate before commit
/core:check
```

### For Data Migration

```bash
# Use MCP for bulk operations
"Import the dealership data from this CSV into the dealerships collection"

# Verify results
"Show me a count of all dealerships grouped by city"

# Commit if satisfied
/core:done
```

### For Workflow Testing

```bash
# Create test flows
"Create a notification flow for when car status changes"

# Test the flow
"Update car VIN ABC123 to status 'sold' and show me the notification"

# Export flow configuration
"Export the notification flow configuration as JSON"
```

---

## Common Tasks & Examples

### 1. Schema Introspection

```
Q: "What collections exist in my Directus instance?"
Q: "Show me all fields in the cars collection"
Q: "What relationships connect cars to dealerships?"
```

### 2. Data Analysis

```
Q: "How many cars are currently available vs sold?"
Q: "Which dealership has the most cars?"
Q: "What's the average price of cars by make?"
```

### 3. Content Creation

```
Q: "Create a new car entry:
- VIN: TEST123456
- Make: Tesla
- Model: Model 3
- Year: 2024
- Price: 450000
- Status: available
- Assign to 'Oslo Motors'"
```

### 4. Bulk Updates

```
Q: "Update all cars with status 'pending' to 'available'"
Q: "Add 'certified_pre_owned' tag to all cars older than 2020"
```

### 5. Relationship Management

```
Q: "Show me all cars assigned to 'Oslo Motors'"
Q: "Reassign all cars from 'Bergen Auto' to 'Oslo Motors'"
```

---

## Troubleshooting

### Connection Issues

**Problem**: "Cannot connect to Directus MCP server"

**Solutions**:
1. Verify Directus is running: `curl http://localhost:8055/server/health`
2. Check MCP is enabled: Settings → AI → MCP Server = ON
3. Verify token is valid: Test in Postman/curl
4. Check .mcp.json syntax (valid JSON)
5. Restart Claude Code after config changes

### Permission Denied

**Problem**: "You don't have permission to perform this action"

**Solutions**:
1. Check MCP user role permissions
2. Verify token belongs to correct user
3. Enable required permissions in role settings
4. Check collection-specific permissions

### Unexpected Behavior

**Problem**: AI suggests incorrect or unexpected operations

**Solutions**:
1. **Never auto-approve** - review each suggestion
2. Be specific in your prompts
3. Verify schema before complex operations
4. Start with read-only queries to verify understanding

---

## Performance Considerations

### Optimal Use Cases

✅ **Good for MCP**:
- Schema exploration and documentation
- Prototyping new collections/fields
- Creating test data (small batches)
- Configuring relationships
- Building simple flows
- Analyzing data patterns

⚠️ **Use with Caution**:
- Bulk data operations (>100 items)
- Complex multi-step workflows
- Production data modifications
- Schema changes on live systems

❌ **Not Recommended**:
- Mass data migrations (use scripts)
- Performance-critical operations
- Production deployments
- Financial/critical transactions

---

## Advanced Configuration

### Custom System Prompts

Configure in Directus:
```
Settings → AI → Model Context Protocol → System Prompts
```

Example custom prompt:
```
You are a Directus assistant for the DirectApp vehicle management system.

Collections:
- cars: Vehicle inventory
- dealerships: Car dealership locations
- users: System users

Guidelines:
- Always verify VINs before creating cars
- Use Norwegian address format for dealerships
- Set proper M2O relationships for car assignments
- Follow Norwegian vehicle registration standards
```

### Prompt Collection

Store reusable prompts in a Directus collection:
```
Collection: ai_prompts
Fields:
- name (string): "Create Test Car"
- prompt (text): "Create a test car with random data..."
- category (dropdown): schema, content, analysis
```

### Delete Protection

Enable globally:
```
Settings → AI → Model Context Protocol → Global Delete Protection = ON
```

This prevents all delete operations via MCP, requiring manual deletion through Directus UI.

---

## Integration Checklist

### Initial Setup
- [ ] Directus v11.12+ installed
- [ ] MCP Server enabled in Settings
- [ ] Dedicated MCP user created
- [ ] Custom role with appropriate permissions
- [ ] Access token generated
- [ ] .mcp.json configured (token in env var)
- [ ] Connection tested successfully

### Security Review
- [ ] Token stored securely (not in git)
- [ ] Delete protection enabled
- [ ] Role permissions minimized
- [ ] Auto-approval disabled
- [ ] Activity logging enabled

### Workflow Integration
- [ ] MCP available during /core:work sessions
- [ ] Used for schema exploration
- [ ] Used for test data generation
- [ ] Validated before /core:done commits

---

## Resources

**Official Docs**:
- Main Guide: https://directus.io/docs/guides/ai/mcp
- Installation: https://directus.io/docs/guides/ai/mcp/installation
- Security: https://directus.io/docs/guides/ai/mcp/security

**DirectApp Integration**:
- Workflow: `.claude/RUNBOOK.md`
- Status: `.claude/STATUS.md`
- Commands: `.claude/commands/README.md`

**MCP Protocol**:
- Specification: https://modelcontextprotocol.io
- Claude Integration: https://docs.anthropic.com/en/docs/build-with-claude/mcp

---

## Status in DirectApp

**Current State**: Not yet configured
**Directus Version**: Check with `docker compose -f docker-compose.dev.yml exec directus npx directus --version`
**Required Version**: v11.12+

### Next Steps

1. **Verify Directus version** meets requirements (v11.12+)
2. **Enable MCP** in local dev server settings
3. **Create MCP user** with dev permissions
4. **Configure .mcp.json** with local server
5. **Test connection** with schema query
6. **Document token** in secure location (not git)

---

**Last Updated**: 2025-10-21
**Status**: ⚠️ Documentation Complete, Setup Pending
**Priority**: Medium (enhances development workflow but not critical)
