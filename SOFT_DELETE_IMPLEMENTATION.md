# Soft Delete Implementation Guide

**Context**: Removed hard DELETE permission on cars collection (Issue #1)
**Solution**: Implement soft delete using status field

---

## Implementation Plan

### 1. Use Existing Status Field

The `cars` collection already has a `status` field. Add an "archived" status value:

**In Directus UI:**
1. Go to **Settings → Data Model → Cars Collection**
2. Find the `status` field
3. Add "archived" to the allowed values (if not already present)

### 2. Create Archive Action (Optional Interface)

**Option A: Use Status Update**
Users can manually set status to "archived" via the update permission they already have.

**Option B: Create Custom Interface/Display**
Create a custom button/action that:
- Sets `status = "archived"`
- Sets `archived_at = NOW()` (add this field if desired)
- Shows confirmation dialog

### 3. Add Archived Filters to Permissions

Update all **READ** permissions on cars to exclude archived by default:

```json
{
  "permissions": {
    "_and": [
      {"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}},
      {"status": {"_neq": "archived"}}  // ← Add this
    ]
  }
}
```

### 4. Create "View Archived" Permission (Optional)

For admin/manager roles, create a separate READ permission:

```json
{
  "permissions": {
    "_and": [
      {"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}},
      {"status": {"_eq": "archived"}}
    ]
  },
  "fields": ["*"]  // Read-only for archived items
}
```

### 5. Prevent Editing Archived Cars

Add validation rule to UPDATE permissions:

```json
{
  "permissions": {
    "_and": [
      {"dealership_id": {"_eq": "$CURRENT_USER.dealership_id"}},
      {"status": {"_neq": "archived"}}  // Can't edit archived
    ]
  }
}
```

---

## Example Workflow

### Archiving a Car
1. User clicks "Archive" (or sets status to "archived")
2. Status changes to "archived"
3. Car disappears from default views
4. Car is preserved in database (can be restored)

### Viewing Archived Cars
1. Admin goes to special "Archived Cars" view
2. Can see read-only archived cars
3. Can restore by changing status back

---

## Related Issues

This implementation supports:
- **Issue #16**: Auto-archive delivered cars
- **Issue #6**: Workflow status management

---

## Testing Checklist

- [ ] User can change car status to "archived"
- [ ] Archived cars don't appear in default car list
- [ ] User cannot edit archived cars
- [ ] User cannot delete archived cars (permission removed)
- [ ] Admin can view archived cars in separate view
- [ ] Archived cars can be restored by admin

---

**Created**: 2025-10-19
**Related**: Issue #1, Issue #16
