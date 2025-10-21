---
description: Sync database schema between environments
argument-hint: [source] [target]
model: claude-sonnet-4-5-20250929
allowed-tools: Bash, Read
---

# /sync-schema - Sync Database Schema

Sync Directus database schema (collections, fields, permissions) between environments.

## What It Does

1. **Export** schema from source environment
2. **Validate** exported schema (JSON)
3. **Apply** schema to target environment
4. **Verify** sync completed successfully

## Usage

```bash
# Sync from local to staging
/sync-schema local staging

# Sync from staging to production
/sync-schema staging production

# Export schema only
/sync-schema export local

# Show schema differences
/sync-schema diff local staging
```

## Environments

- **local** - Local development (http://localhost:8055)
- **staging** - Staging (https://staging-gapp.coms.no)
- **production** - Production (https://gapp.coms.no)

## Common Workflows

### Development → Staging

```bash
# 1. Make schema changes in local Directus
# 2. Export and sync to staging
/sync-schema local staging
```

### Staging → Production

```bash
# 1. Test schema changes in staging
# 2. Sync to production (requires confirmation)
/sync-schema staging production
```

### Compare Schemas

```bash
# Show differences between environments
/sync-schema diff local staging
```

## What Gets Synced

✅ **Included:**
- Collections (tables)
- Fields (columns)
- Relations (foreign keys)
- Permissions (roles, policies)
- Settings
- Flows
- Operations
- Panels
- Presets

❌ **Not Included:**
- Actual data (records)
- Files/uploads
- User accounts
- Tokens

## Authentication

For remote environments (staging/production), you need an admin access token:

```bash
# Set token as environment variable
export DIRECTUS_TOKEN="your-admin-token"

# Then run sync
/sync-schema local staging
```

**Get token from:**
1. Login to Directus admin
2. Settings → Access Tokens
3. Create new token with admin permissions
4. Copy token

## Output Example

```
========================================
Schema Sync: local → staging
========================================

ℹ Exporting schema from local (http://localhost:8055)...
✓ Schema exported: schema/snapshots/local.json

ℹ Applying schema to staging (https://staging-gapp.coms.no)...
✓ Schema applied to staging

✓ Schema sync complete: local → staging
```

## Error Handling

**Missing token:**
```
✗ DIRECTUS_TOKEN environment variable required for remote export
ℹ Get token from: https://staging-gapp.coms.no/admin/settings/access-tokens
```

**Invalid JSON:**
```
✗ Invalid JSON in exported schema
```

**Schema file not found:**
```
✗ Schema not found: schema/snapshots/local.json
ℹ Run: ./scripts/sync-schema.sh export local
```

## Production Safety

When syncing to production:
- Requires manual confirmation
- Shows warning message
- Can be cancelled

```
⚠ You are about to sync schema to PRODUCTION

Type 'yes' to continue: yes
```

## Schema Files

Schemas are saved to: `schema/snapshots/`

```
schema/
└── snapshots/
    ├── local.json       # Local development
    ├── staging.json     # Staging
    └── production.json  # Production
```

## Advanced Usage

### Export Only

```bash
# Export schema without applying
/sync-schema export local
```

Creates: `schema/snapshots/local.json`

### Manual Apply

```bash
# Export from one environment
/sync-schema export staging

# Apply to another (manually)
npx directus schema apply schema/snapshots/staging.json
```

### Compare Before Sync

```bash
# 1. Export both schemas
/sync-schema export local
/sync-schema export staging

# 2. Show diff
/sync-schema diff local staging

# 3. Sync if changes look good
/sync-schema local staging
```

## Integration with CI/CD

Schema sync is automated in CI:
- Exports schema after tests pass
- Applies to staging on main branch push
- Production requires manual trigger

See `.github/workflows/directus-ci.yml`

## Troubleshooting

**Schema export fails:**
- Check Directus is running
- Verify URL is accessible
- Check admin token is valid

**Schema apply fails:**
- Check for schema conflicts
- Verify permissions are correct
- Check database migrations

**Diff shows unexpected changes:**
- Review schema carefully
- Test in staging first
- Consider rollback plan

## Best Practices

1. **Always test in staging first**
   - Never sync directly to production
   - Verify changes work as expected

2. **Export schemas regularly**
   - Commit to git for history
   - Use for rollback if needed

3. **Use descriptive commit messages**
   - Include what schema changed
   - Why the change was made

4. **Review diffs before sync**
   - Check for unexpected changes
   - Verify field types are correct

## See Also

- `/deploy` - Deploy application
- `/check` - Pre-deployment validation
- `scripts/sync-schema.sh` - Schema sync script
- `schema/snapshots/` - Schema snapshot directory
