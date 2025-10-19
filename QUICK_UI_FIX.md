# Quick UI Display Fix

## Problem
Many fields in Directus UI were showing UUIDs instead of readable names because the schema was created via SQL migrations.

## Solution Applied

Configured display templates for all relationship fields via Directus API:

### Fixed Fields:
- ✅ `dealership.parent_dealership_id` → Shows "490 - Gumpens Auto AS"
- ✅ `dealership.prep_center_id` → Shows "499 - Gumpen Skade og Bilpleie"
- ✅ `cars.dealership_id` → Shows dealership name
- ✅ `cars.prep_center_id` → Shows prep center name
- ✅ `resource_sharing.provider_dealership_id` → Shows provider name
- ✅ `resource_sharing.consumer_dealership_id` → Shows consumer name
- ✅ `resource_sharing.resource_type_id` → Shows "Mekanisk klargjøring"
- ✅ `directus_users.dealership_id` → Shows dealership name

### How to Apply:
```bash
./fix_ui_displays.sh
```

### Refresh Required:
After running the script, refresh your browser to see the changes.

## Next Steps (Issue #22)

For complete UI configuration:
- Field translations (Norwegian)
- More dropdowns for enums
- Conditional visibility
- Tab layouts
- Field grouping

See Issue #22 for full UI configuration.
