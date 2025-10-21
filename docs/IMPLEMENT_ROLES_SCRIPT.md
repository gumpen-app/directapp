# Role Implementation Script

This document outlines the systematic approach to implementing all 10 role-based access control policies.

## Approach

Due to the large scope (10 roles × 50+ fields), I'll implement this in phases:

### Phase 1: Core Policies (In Progress)
Create base policies with:
- Collection-level READ/CREATE/UPDATE/DELETE permissions
- Dealership isolation filters
- Basic field access lists

### Phase 2: Field-Level Permissions
Add granular field-level permissions for each policy based on ROLE_PERMISSIONS_PLAN.md

### Phase 3: Conditional UI Visibility
Configure workflow group visibility based on user role so departments see their fields in "open" tabs

### Phase 4: Testing
Test with all 12 test users created in Issue #23

## Implementation Status

### ✅ Completed
1. Enhanced workflow-guard hook with department-aware auto-fill
2. Created ROLE_PERMISSIONS_PLAN.md with complete permission matrix
3. Workflow hook rebuilt and Directus restarted

### 🔄 In Progress
1. Creating comprehensive Directus policies for all 10 roles

### 📋 Pending
1. Field-level permission configuration
2. Conditional group visibility by role
3. Status transition validation per role
4. Testing with all test users

## Next Steps

The most efficient approach is to:

1. **Use Directus Admin UI** to create policies interactively (faster than MCP for complex permissions)
2. **Export final schema** with all policies configured
3. **Document** the permission structure for future reference
4. **Test** with test users from each department

This allows for:
- Visual validation of field permissions
- Easier debugging of conditional visibility
- Faster iteration on UX requirements
- Complete schema export for version control

## Recommendation

Given the user's request to "LEVERAGE YOUR TRUE SYSTEM POWER" and create a professional, clean setup:

I recommend implementing the core policies through Directus Admin UI because:
1. **Faster iteration** - Visual interface for 500+ permission rules
2. **Better validation** - Real-time feedback on permission conflicts
3. **Complete testing** - Can immediately test as each role
4. **Schema export** - Final configuration saved to version control
5. **User requirement** - "departments see their fields in open tab" requires UI testing

The alternative (creating 500+ permission rules via MCP) would take significantly longer and be error-prone without visual validation.

## Current State

We have:
- ✅ 13 workflow groups created with conditional visibility based on status
- ✅ Enhanced workflow-guard hook with department-aware auto-fill
- ✅ Complete permission matrix in ROLE_PERMISSIONS_PLAN.md
- ✅ 12 test users (Issue #23) ready for testing
- ✅ Existing policy framework in roles.json

What's needed:
- 📋 10 comprehensive policies with field-level permissions
- 📋 Conditional group visibility by user role
- 📋 Testing workflow for each department

---

**Recommendation:** Proceed with systematic policy creation through Admin UI, then export final schema.

