# Extension Development Checklist

Quick reference for starting collection UX and extension development work.

---

## 🚀 Pre-Development Setup

### Environment Check
- [ ] Docker dev environment running (`pnpm dev`)
- [ ] Access Directus at http://localhost:8055
- [ ] Admin login works (admin@example.com / admin)
- [ ] Extensions hot-reload enabled (check logs for "AUTO_RELOAD: true")

### Pattern Review
- [ ] Read `.claude/memory/patterns/context7/PATTERN_SUMMARY.md`
- [ ] Review specific pattern file for your extension type
- [ ] Note TOP 3 HIGH-priority recommendations
- [ ] Review anti-patterns to avoid

### MCP Server Status
```bash
# Verify all MCP servers are active
# directapp-dev, directapp-pilot, context7, github, local-fs
```

---

## 🎨 Interface Development (Custom Field Inputs)

### Before You Start
- [ ] Review `interfaces-pattern.json` (4.8KB)
- [ ] Check existing example: `directus-extension-vehicle-lookup-button/`
- [ ] Understand field type compatibility

### Critical Requirements (⚠️ Must Do)
1. **MUST emit 'input' event** when value changes
   ```js
   emit('input', newValue);
   ```
2. **MUST declare all compatible field types**
   ```js
   types: ['string', 'text', 'json']
   ```
3. **MUST use Vue 3 Composition API**
   ```vue
   <script setup>
   const props = defineProps(['value']);
   const emit = defineEmits(['input']);
   </script>
   ```

### Development Steps
- [ ] Scaffold: `npx create-directus-extension@latest` → Choose "interface"
- [ ] Review generated `index.js` and `interface.vue`
- [ ] Use Directus components (VButton, VInput, VNotice) - no imports needed
- [ ] Add collaborative editing support (data-collection, data-field, data-primary-key)
- [ ] Implement v-model pattern with computed property
- [ ] Test in Docker dev environment
- [ ] Type check: `pnpm extensions:type-check`

### Testing Checklist
- [ ] Field saves correctly when changed
- [ ] Interface appears for declared field types
- [ ] Validation works (if implemented)
- [ ] Loading states show properly
- [ ] Error states display correctly
- [ ] Responsive on mobile/tablet/desktop

---

## 📊 Panel Development (Dashboard Widgets)

### Before You Start
- [ ] Review `panels-pattern.json` (5.9KB)
- [ ] Understand useApi composable for data fetching
- [ ] Check permission requirements

### Critical Requirements (⚠️ Must Do)
1. **MUST set minimum dimensions**
   ```js
   minWidth: 12,
   minHeight: 8
   ```
2. **MUST check permissions before rendering**
   ```js
   if (!hasPermission) return null;
   ```
3. **MUST handle loading/error states**
   ```vue
   <div v-if="loading">Loading...</div>
   <div v-if="error">{{ error }}</div>
   ```

### Development Steps
- [ ] Scaffold: `npx create-directus-extension@latest` → Choose "panel"
- [ ] Set panel dimensions in `index.js`
- [ ] Use `useApi()` for data fetching
- [ ] Use `useStores()` for accessing Directus state
- [ ] Implement loading/error/empty states
- [ ] Test responsive layout (panels resize)
- [ ] Add to dashboard and verify

---

## 🎣 Hook Development (Event Handling & Validation)

### Before You Start
- [ ] Review `hooks-pattern.json` (3.5KB)
- [ ] Check existing example: `directus-extension-workflow-guard/`
- [ ] Understand filter vs action hooks

### Critical Requirements (⚠️ Must Do)
1. **FILTER hooks MUST return payload**
   ```js
   return payload; // Don't forget!
   ```
2. **Choose correct hook type**
   - Filter = BEFORE (blocking, can modify data)
   - Action = AFTER (non-blocking, side effects only)
3. **ALWAYS use services (not raw DB)**
   ```js
   const itemsService = new ItemsService('collection', { schema, accountability });
   ```

### Development Steps
- [ ] Scaffold: `npx create-directus-extension@latest` → Choose "hook"
- [ ] Choose hook type and scope (e.g., `items.create`, `items.update`)
- [ ] Implement validation/transformation logic
- [ ] Wrap async operations in try-catch
- [ ] Return payload (filter hooks)
- [ ] Test with Directus logs
- [ ] Verify workflow behavior

### Hook Types Quick Reference
```js
// FILTER (blocking - modify data before save)
filter('items.create', async (payload, meta, context) => {
  // Validate/transform payload
  return payload; // MUST return
});

// ACTION (non-blocking - side effects after save)
action('items.create', async ({ payload, key }, context) => {
  // Send notification, trigger webhook, etc.
  // No return needed
});
```

---

## 🌐 Endpoint Development (Custom API Routes)

### Before You Start
- [ ] Review `endpoints-pattern.json` (6.2KB)
- [ ] Check existing example: `directus-extension-vehicle-lookup/`
- [ ] Understand Express-style routing

### Critical Requirements (⚠️ Must Do)
1. **ALWAYS validate authentication**
   ```js
   if (!req.accountability?.user) {
     return res.status(401).send({ error: 'Unauthorized' });
   }
   ```
2. **USE services (not raw DB queries)**
   ```js
   const itemsService = new ItemsService('cars', { schema, accountability: req.accountability });
   ```
3. **WRAP async in try-catch**
   ```js
   try {
     const result = await someAsyncOperation();
   } catch (error) {
     return res.status(500).send({ error: error.message });
   }
   ```

### Development Steps
- [ ] Scaffold: `npx create-directus-extension@latest` → Choose "endpoint"
- [ ] Define routes in `index.js`
- [ ] Implement request handlers
- [ ] Add authentication checks
- [ ] Use ItemsService for permissions
- [ ] Add health check endpoint
- [ ] Test with curl/Postman
- [ ] Document API in code comments

---

## ⚙️ Operation Development (Flow Automation)

### Before You Start
- [ ] Review `operations-pattern.json` (5.1KB)
- [ ] Understand app.js (UI) vs api.js (logic) split
- [ ] Check Flow data chain concept

### Critical Requirements (⚠️ Must Do)
1. **ALWAYS return data** (next operations need it)
   ```js
   return { success: true, result: data };
   ```
2. **USE defineOperationApi** for proper typing
   ```js
   import { defineOperationApi } from '@directus/extensions-sdk';
   ```
3. **HANDLE async operations with try-catch**
   ```js
   try {
     const result = await apiCall();
     return { success: true, data: result };
   } catch (error) {
     throw new Error(`Failed: ${error.message}`);
   }
   ```

### Development Steps
- [ ] Scaffold: `npx create-directus-extension@latest` → Choose "operation"
- [ ] Configure UI in `app.js` (operation options)
- [ ] Implement logic in `api.js` (handler function)
- [ ] Return data for data chain
- [ ] Test in Flows interface
- [ ] Verify error handling
- [ ] Document operation options

---

## 🎯 Collection UX Best Practices

### Schema-First Approach
```bash
# ALWAYS check schema before creating fields
mcp__directapp-dev__schema(keys: ["collection_name"])
```

### Field Configuration
- [ ] Use appropriate field types (string, text, json, etc.)
- [ ] Add field notes for context
- [ ] Configure validation rules
- [ ] Set conditional visibility (conditions)
- [ ] Test with all 9 Norwegian roles

### UI Components
**Always use Directus components** (globally registered, no imports):
- `<VButton>` - Buttons
- `<VInput>` - Text inputs
- `<VSelect>` - Dropdowns
- `<VNotice>` - Alerts/notifications
- `<VIcon>` - Material icons
- `<VForm>` - Forms

### Responsive Design
- [ ] Test on mobile (320px+)
- [ ] Test on tablet (768px+)
- [ ] Test on desktop (1024px+)
- [ ] Use `width: "half"` or `width: "full"` in field meta

---

## 🧪 Testing Workflow

### 1. Development Testing
```bash
# Start dev environment with hot reload
pnpm dev

# Watch extension changes
pnpm extensions:dev

# Type check
pnpm extensions:type-check

# Lint
pnpm extensions:lint
```

### 2. Manual Testing
- [ ] Test in Chrome DevTools (desktop)
- [ ] Test in mobile view (responsive)
- [ ] Test with different user roles
- [ ] Test edge cases (empty data, errors)
- [ ] Test with real data

### 3. Docker Testing
```bash
# Restart Directus to load changes
docker compose restart directus

# Check logs for errors
pnpm dev:logs
```

---

## 📚 Reference Examples

### Interface Examples
- **Basic**: `directus-extension-vehicle-lookup-button/`
- Pattern: `.claude/memory/patterns/context7/interfaces-pattern.json`

### Panel Examples
- Pattern: `.claude/memory/patterns/context7/panels-pattern.json`

### Hook Examples
- **Validation**: `directus-extension-workflow-guard/`
- Pattern: `.claude/memory/patterns/context7/hooks-pattern.json`

### Endpoint Examples
- **API Integration**: `directus-extension-vehicle-lookup/`
- Pattern: `.claude/memory/patterns/context7/endpoints-pattern.json`

### Operation Examples
- Pattern: `.claude/memory/patterns/context7/operations-pattern.json`

---

## 🚨 Common Mistakes to Avoid

### Interfaces
- ❌ Not emitting 'input' event → Data won't save
- ❌ Missing type declarations → Interface won't appear
- ❌ Importing Directus components → Use globally registered

### Panels
- ❌ No minimum dimensions → Layout breaks
- ❌ Missing loading states → Poor UX
- ❌ No permission checks → Security risk

### Hooks
- ❌ Filter hook not returning payload → Data flow breaks
- ❌ Using raw DB queries → Permissions ignored
- ❌ Wrong hook type (filter vs action) → Unexpected behavior

### Endpoints
- ❌ No authentication checks → Security vulnerability
- ❌ Not using ItemsService → Permissions bypassed
- ❌ Missing error handling → Server crashes

### Operations
- ❌ Not returning data → Flow data chain breaks
- ❌ Missing error handling → Flow fails silently
- ❌ No async handling → Promise rejections

---

## 🔗 Quick Links

- **Pattern Summary**: `.claude/memory/patterns/context7/PATTERN_SUMMARY.md`
- **Extension README**: `extensions/README.md`
- **Workflow Config**: `.claude/config/extension-workflow.json`
- **Directus Docs**: https://docs.directus.io/extensions/
- **Context7 Library**: Use `mcp__context7__get-library-docs` for latest docs

---

## 🎓 Learning Resources

### First Extension?
1. Read PATTERN_SUMMARY.md
2. Review relevant pattern JSON file
3. Study existing extension in same category
4. Follow critical requirements checklist
5. Use pattern code examples as templates

### Est. Time Savings
- **First extension**: 8-15 hours saved (with patterns)
- **Subsequent extensions**: 2-4 hours saved each
- **Project lifecycle**: 50-100 hours total saved

---

**Last Updated:** 2025-10-29
**Maintained By:** DirectApp Team
