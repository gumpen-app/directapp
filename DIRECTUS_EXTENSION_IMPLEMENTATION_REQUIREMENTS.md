# DIRECTUS EXTENSION IMPLEMENTATION REQUIREMENTS SPECIFICATION

## Executive Summary

- **Total extension types to cover**: 9
- **Extension types with examples**: 4 (interfaces, hooks, endpoints, operations)
- **Extension types requiring fallback patterns**: 5 (modules, panels, layouts, displays, bundles)
- **Current codebase anti-patterns**: 1 (disabled extensions with .disabled suffix)
- **Infrastructure maturity**: Advanced (TypeScript, monorepo structure, shared tsconfig)
- **Build system**: Directus Extensions SDK v16.0.2
- **Primary language**: TypeScript 5.3.3+
- **Framework**: Vue 3.4.15+ (for UI components)

---

## Extension Type Requirements

### 1. Interfaces

**Purpose**: Custom input components for data entry in the Directus App

**Foolproof Definition**: Component that:
- Integrates on first deployment without errors
- Follows all Vue 3 Composition API patterns
- Passes TypeScript type checking
- Emits data correctly to parent form
- Handles both configuration mode and item edit mode
- Provides clear user feedback for all states

**Discovered Pattern**: `/extensions/directus-extension-vehicle-lookup-button`

**Required Files**:
```
directus-extension-{name}/
├── package.json
├── tsconfig.json
├── src/
│   ├── index.ts
│   └── interface.vue
```

**Required package.json Structure**:
```json
{
  "name": "directapp-interface-{name}",
  "version": "1.0.0",
  "type": "module",
  "directus:extension": {
    "type": "interface",
    "path": "dist/index.js",
    "source": "src/index.ts",
    "host": "^11.12.0"
  },
  "scripts": {
    "build": "directus-extension build",
    "dev": "directus-extension build --watch",
    "clean": "rm -rf dist",
    "type-check": "tsc --noEmit"
  },
  "devDependencies": {
    "@directus/extensions-sdk": "^16.0.2",
    "typescript": "^5.3.3",
    "vue": "^3.4.15"
  }
}
```

**Required Exports (src/index.ts)**:
```typescript
import { defineInterface } from '@directus/extensions-sdk';
import InterfaceComponent from './interface.vue';

export default defineInterface({
  id: 'unique-interface-id',
  name: 'Human Readable Name',
  description: 'Clear description of what this interface does',
  icon: 'material_icon_name',
  component: InterfaceComponent,
  options: [ /* field configuration options */ ],
  types: ['string', 'text', 'json', 'alias'], // Supported field types
});
```

**Type Imports**:
```typescript
// index.ts
import { defineInterface } from '@directus/extensions-sdk';

// interface.vue
import { ref, computed, watch } from 'vue';
import { useApi } from '@directus/extensions-sdk';
```

**Context Usage (Props in interface.vue)**:
```typescript
interface Props {
  value?: any;                           // Current field value
  collection: string;                    // Collection name
  field: string;                         // Field name
  primaryKey: string | number;           // Item ID
  values: Record<string, any>;           // ALL item values (critical!)

  // All configuration options defined in index.ts options array
  [configOption: string]: any;
}

// Emit to update field value
const emit = defineEmits(['input']);
emit('input', newValue);

// Emit object to update multiple fields at once
emit('input', {
  field1: value1,
  field2: value2,
});
```

**Critical Patterns**:
1. **Detect Configuration Mode**: Check if `props.collection === 'directus_fields'`
2. **Access Other Field Values**: Use `props.values[fieldName]` to read other fields
3. **Use computed() for Reactive Values**: Never access props directly in watch callbacks
4. **Debounce User Input**: For API calls, use minimum 1000ms debounce
5. **Provide Loading States**: Always show loading, error, success states
6. **Handle Empty States**: Check if values exist before accessing
7. **Validate Input**: Provide validation before expensive operations
8. **Use useApi()**: For Directus API calls: `const api = useApi()`

**Error Handling Approach**:
```typescript
const error = ref<string | null>(null);
const loading = ref(false);

async function performAction() {
  error.value = null;
  loading.value = true;

  try {
    // Perform action
    const result = await api.get('/endpoint');
    // Handle success
  } catch (err: any) {
    error.value = err.message || 'An error occurred';
    console.error('Action failed:', err);
  } finally {
    loading.value = false;
  }
}
```

**Logging Strategy**: Use console.log for development, no production logs (Directus handles logging)

**Configuration Approach**:
- Define options in `defineInterface({ options: [...] })`
- Access via props with TypeScript types
- Environment variables accessed via endpoint calls (not directly in interface)

**Success Criteria**:
- [ ] TypeScript compiles without errors: `npm run type-check`
- [ ] Builds successfully: `npm run build`
- [ ] Interface appears in field configuration dropdown
- [ ] Can be added to a collection without errors
- [ ] Emits data correctly (check via browser console)
- [ ] Handles both new items and existing items
- [ ] Loading states are visible and clear
- [ ] Error messages are user-friendly
- [ ] Configuration mode doesn't break (when adding field)

**Validation Method**:
```bash
cd extensions/directus-extension-{name}
npm run type-check
npm run build
# Deploy to Directus
# Test in UI: Add field, configure, save item, verify data
```

**Risk Level if Violated**: **HIGH**
- Broken interface can prevent editing items in collection
- Type errors can cause runtime crashes
- Incorrect emit() can corrupt data
- Missing config mode check breaks field configuration

---

### 2. Hooks

**Purpose**: Server-side event listeners that validate, modify, or react to data changes

**Foolproof Definition**: Hook that:
- Never throws unintended exceptions (only for validation failures)
- Accesses database safely with proper context
- Logs all actions for audit trail
- Separates concerns: filters for validation, actions for side-effects
- Handles errors gracefully without blocking operations
- Respects user permissions and accountability

**Discovered Pattern**: `/extensions/directus-extension-workflow-guard`

**Required Files**:
```
directus-extension-{name}/
├── package.json
├── tsconfig.json
├── src/
│   ├── index.ts
│   └── (optional config files)
```

**Required package.json Structure**:
```json
{
  "name": "directapp-hook-{name}",
  "version": "1.0.0",
  "type": "module",
  "directus:extension": {
    "type": "hook",
    "path": "dist/index.js",
    "source": "src/index.ts",
    "host": "^11.12.0"
  },
  "scripts": {
    "build": "directus-extension build",
    "dev": "directus-extension build --watch",
    "clean": "rm -rf dist",
    "type-check": "tsc --noEmit"
  },
  "devDependencies": {
    "@directus/extensions-sdk": "^16.0.2",
    "typescript": "^5.3.3"
  }
}
```

**Required Exports (src/index.ts)**:
```typescript
import { defineHook } from '@directus/extensions-sdk';

export default defineHook(({ filter, action }, { services, logger, exceptions }) => {
  const { ItemsService } = services;
  const { ForbiddenException, InvalidPayloadException } = exceptions;

  // Filter = validation (can block operation)
  filter('collection.items.create', async (payload, meta, context) => {
    // Validate
    // Modify payload
    // Throw exception to prevent operation
    return payload;
  });

  // Action = side effects (cannot block operation)
  action('collection.items.create', async (meta, context) => {
    // Log
    // Send notifications
    // Update related data
    // Never throw exceptions here
  });
});
```

**Type Imports**:
```typescript
import { defineHook } from '@directus/extensions-sdk';
```

**Context Usage**:
```typescript
// Access database
const service = new ItemsService('collection_name', {
  schema: await context.database.schema,
  accountability: context.accountability,
});

// Read current item (in update/delete hooks)
const currentItem = await service.readOne(meta.keys[0]);

// Read with relations
const item = await service.readOne(id, {
  fields: ['*', 'relation.*', 'deep.relation.*'],
});

// Query items
const items = await service.readByQuery({
  filter: { status: { _eq: 'active' } },
  limit: 10,
});

// Create/Update/Delete
await service.createOne(data);
await service.updateOne(id, data);
await service.deleteOne(id);

// Access user info
const userId = context.accountability?.user;
const userRole = context.accountability?.role;

// Throw exceptions (only in filters!)
throw new InvalidPayloadException('Error message');
throw new ForbiddenException('Not allowed');
```

**Critical Patterns**:
1. **Use filters for validation**: Block operations by throwing exceptions
2. **Use actions for side-effects**: Logging, notifications, cleanup
3. **Access current item first**: Always read current state before validation
4. **Check if field is changing**: `if (!newValue || newValue === oldValue) return payload;`
5. **Return modified payload**: Filters must return the payload (modified or not)
6. **Never throw in actions**: Actions should never block operations
7. **Use accountability for user context**: Check permissions, auto-fill user fields
8. **Log everything**: Use logger.info, logger.warn, logger.error extensively

**Error Handling Approach**:
```typescript
// In filters (validation)
filter('collection.items.update', async (payload, meta, context) => {
  try {
    // Validation logic
    if (invalid) {
      throw new InvalidPayloadException('Clear error message');
    }
    return payload;
  } catch (error: any) {
    logger.error(`Validation error: ${error.message}`, { payload, meta });
    throw error; // Re-throw to block operation
  }
});

// In actions (side-effects)
action('collection.items.update', async (meta, context) => {
  try {
    // Side effect logic
  } catch (error: any) {
    logger.error(`Action failed: ${error.message}`);
    // Don't throw - just log
  }
});
```

**Logging Strategy**:
```typescript
logger.info('Operation description', { key: 'value', data });
logger.warn('Warning message', { context });
logger.error('Error message', { error: error.stack, payload, meta });
```

**Configuration Approach**:
- Environment variables via `context.env` (not available - use services)
- Store configuration in database collection
- Import configuration from separate files

**Success Criteria**:
- [ ] TypeScript compiles without errors
- [ ] Builds successfully
- [ ] Hook registers without errors (check logs on startup)
- [ ] Filters properly validate and throw clear exceptions
- [ ] Actions execute but never block operations
- [ ] All operations are logged
- [ ] Database queries use proper context and accountability
- [ ] No unhandled promise rejections

**Validation Method**:
```bash
cd extensions/directus-extension-{name}
npm run type-check
npm run build
# Deploy to Directus
# Check logs: docker-compose logs -f directus
# Test operations: Create, Update, Delete items
# Verify validation rules work
# Verify side-effects execute
```

**Risk Level if Violated**: **CRITICAL**
- Incorrect filter can block all operations on collection
- Thrown exceptions in actions crash Directus
- Missing accountability check exposes data
- Incorrect service context causes permission bypasses
- Missing try-catch in filters can crash entire hook system

---

### 3. Endpoints

**Purpose**: Custom REST API routes for external integrations and custom business logic

**Foolproof Definition**: Endpoint that:
- Uses async/await for all handlers
- Returns proper HTTP status codes
- Validates all input parameters
- Handles errors without crashing
- Checks environment variable availability
- Logs all requests and errors
- Uses ItemsService for database queries
- Returns consistent JSON response format

**Discovered Pattern**: `/extensions/directus-extension-vehicle-lookup`

**Required Files**:
```
directus-extension-{name}/
├── package.json
├── tsconfig.json
├── src/
│   ├── index.ts
│   └── (optional utility files)
```

**Required package.json Structure**:
```json
{
  "name": "directapp-endpoint-{name}",
  "version": "1.0.0",
  "type": "module",
  "directus:extension": {
    "type": "endpoint",
    "path": "dist/index.js",
    "source": "src/index.ts",
    "host": "^11.12.0"
  },
  "scripts": {
    "build": "directus-extension build",
    "dev": "directus-extension build --watch",
    "clean": "rm -rf dist",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "axios": "^1.6.5" // or other HTTP client if needed
  },
  "devDependencies": {
    "@directus/extensions-sdk": "^16.0.2",
    "typescript": "^5.3.3"
  }
}
```

**Required Exports (src/index.ts)**:
```typescript
import { defineEndpoint } from '@directus/extensions-sdk';

export default defineEndpoint({
  id: 'unique-endpoint-id',
  handler: (router, context) => {
    const { env, logger, services } = context;
    const { ItemsService } = services;

    router.get('/path/:param', async (req, res) => {
      try {
        // Handler logic
        res.json({ success: true, data });
      } catch (error: any) {
        logger.error(`Error: ${error.message}`);
        res.status(500).json({ error: 'Error message' });
      }
    });
  },
});
```

**Type Imports**:
```typescript
import { defineEndpoint } from '@directus/extensions-sdk';
import axios from 'axios'; // or other libraries
```

**Context Usage**:
```typescript
// Access environment variables
const apiKey = env.API_KEY_NAME;
if (!apiKey) {
  return res.status(503).json({ error: 'Service not configured' });
}

// Access request parameters
const { param } = req.params;  // URL params
const { query } = req.query;   // Query string
const { body } = req.body;     // POST body

// Validate parameters
if (!param || param.length < 2) {
  return res.status(400).json({ error: 'Invalid parameter' });
}

// Use ItemsService for database
const service = new ItemsService('collection', {
  schema: req.schema,
  accountability: req.accountability,
});

const items = await service.readByQuery({
  filter: { status: { _eq: 'active' } },
});

// Return responses
res.json({ success: true, data });                    // 200
res.status(400).json({ error: 'Bad request' });       // 400
res.status(404).json({ error: 'Not found' });         // 404
res.status(500).json({ error: 'Server error' });      // 500
res.status(503).json({ error: 'Service unavailable' }); // 503
```

**Critical Patterns**:
1. **Use async/await**: All handlers must be async
2. **Validate input early**: Return 400 for invalid input before processing
3. **Check env variables**: Return 503 if required config missing
4. **Use try-catch**: Wrap all handler logic in try-catch
5. **Return JSON**: Always use res.json() for consistency
6. **Log everything**: Log requests, successes, failures
7. **Proper status codes**: Use correct HTTP codes for each scenario
8. **Timeout external requests**: Set timeout for HTTP requests

**Error Handling Approach**:
```typescript
router.get('/path/:param', async (req, res) => {
  try {
    const { param } = req.params;

    // Input validation
    if (!param) {
      return res.status(400).json({ error: 'Missing parameter' });
    }

    // Config validation
    const apiKey = env.API_KEY;
    if (!apiKey) {
      logger.warn('API_KEY not configured');
      return res.status(503).json({ error: 'Service not configured' });
    }

    // Operation
    logger.info(`Processing request: ${param}`);
    const result = await externalApi.call(param);

    // Success
    logger.info(`Request successful: ${param}`);
    return res.json({ success: true, data: result });

  } catch (error: any) {
    logger.error(`Request failed: ${error.message}`);

    // Handle specific errors
    if (error.response?.status === 404) {
      return res.status(404).json({ error: 'Resource not found' });
    }

    if (error.response?.status === 401) {
      return res.status(503).json({ error: 'Authentication failed' });
    }

    // Generic error
    return res.status(500).json({
      error: 'Request failed',
      message: error.message
    });
  }
});
```

**Logging Strategy**:
```typescript
logger.info(`Request received: ${req.params.id}`);
logger.info(`Operation successful`, { data });
logger.warn(`Warning: ${condition}`);
logger.error(`Operation failed: ${error.message}`, { error: error.stack });
```

**Configuration Approach**:
- Environment variables via `env.VARIABLE_NAME`
- Always check availability before use
- Return 503 if required config missing
- Document all required env variables

**Success Criteria**:
- [ ] TypeScript compiles without errors
- [ ] Builds successfully
- [ ] Endpoint accessible at correct path
- [ ] Returns JSON for all responses
- [ ] Proper status codes for all scenarios
- [ ] Input validation works
- [ ] Error handling prevents crashes
- [ ] Logging shows in Directus logs
- [ ] External API integration works (if applicable)

**Validation Method**:
```bash
cd extensions/directus-extension-{name}
npm run type-check
npm run build
# Deploy to Directus
# Test endpoints:
curl http://localhost:8055/endpoint-id/path/param
curl -X POST http://localhost:8055/endpoint-id/path -d '{"key":"value"}'
# Check logs: docker-compose logs -f directus
```

**Risk Level if Violated**: **HIGH**
- Unhandled errors crash Directus
- Missing input validation exposes vulnerabilities
- Incorrect status codes break client integrations
- Missing env checks cause runtime failures
- Improper ItemsService usage bypasses permissions

---

### 4. Operations

**Purpose**: Custom flow operations for workflow automation and business logic

**Foolproof Definition**: Operation that:
- Validates required options at start of handler
- Checks environment variable availability
- Uses external SDKs correctly (versioned dependencies)
- Returns data for next operations in flow
- Throws errors to stop flow execution on failure
- Logs all operations for debugging
- Handles async operations properly

**Discovered Pattern**: `/extensions/operations/directus-extension-send-email.disabled`

**Required Files**:
```
operations/directus-extension-{name}/
├── package.json
├── tsconfig.json
├── src/
│   ├── index.ts
│   └── app.ts (optional: UI configuration)
```

**Required package.json Structure**:
```json
{
  "name": "directapp-operation-{name}",
  "version": "1.0.0",
  "type": "module",
  "directus:extension": {
    "type": "operation",
    "path": "dist/index.js",
    "source": "src/index.ts",
    "host": "^11.12.0"
  },
  "scripts": {
    "build": "directus-extension build",
    "dev": "directus-extension build --watch",
    "clean": "rm -rf dist",
    "type-check": "tsc --noEmit"
  },
  "dependencies": {
    "external-sdk": "^1.0.0" // External integrations
  },
  "devDependencies": {
    "@directus/extensions-sdk": "^16.0.2",
    "typescript": "^5.3.3"
  }
}
```

**Required Exports (src/index.ts)**:
```typescript
import { defineOperationApi } from '@directus/extensions-sdk';

export default {
  id: 'unique-operation-id',
  handler: defineOperationApi<OptionsType>({
    id: 'unique-operation-id',
    handler: async (options, { env, logger, accountability }) => {
      try {
        // Validate required options
        if (!options.requiredField) {
          throw new Error('Missing required field: requiredField');
        }

        // Check environment
        const apiKey = env.API_KEY;
        if (!apiKey) {
          throw new Error('API_KEY not configured');
        }

        // Perform operation
        logger.info('Operation starting');
        const result = await externalService.call(options);
        logger.info('Operation completed');

        // Return data for next operations
        return {
          success: true,
          data: result,
          timestamp: new Date().toISOString(),
        };

      } catch (error: any) {
        logger.error(`Operation failed: ${error.message}`);
        throw error; // Stop flow execution
      }
    },
  }),
};
```

**Type Imports**:
```typescript
import { defineOperationApi, defineOperationApp } from '@directus/extensions-sdk';

// Define options type
interface OptionsType {
  requiredField: string;
  optionalField?: string;
}
```

**Context Usage**:
```typescript
// Access options (configured in flow)
const { requiredField, optionalField } = options;

// Access environment variables
const apiKey = env.API_KEY_NAME;

// Access user context
const userId = accountability?.user;
const userRole = accountability?.role;

// Log operations
logger.info('Starting operation', { options });
logger.error('Operation failed', { error: error.stack });

// Return data for next operations
return {
  key1: value1,
  key2: value2,
  operationKey: 'access this data in next operations',
};

// Throw to stop flow
throw new Error('Operation cannot continue');
```

**Critical Patterns**:
1. **Validate options first**: Check all required fields before processing
2. **Check environment availability**: Verify env variables before use
3. **Use typed options**: Define TypeScript interface for options
4. **Return structured data**: Always return object with predictable structure
5. **Throw to stop flow**: Only throw when flow should not continue
6. **Log everything**: Log start, success, failure
7. **Handle async properly**: Always await external calls
8. **Version external dependencies**: Pin SDK versions in package.json

**Error Handling Approach**:
```typescript
handler: async (options, { env, logger, accountability }) => {
  try {
    // Validation
    if (!options.to) {
      throw new Error('Missing required field: to');
    }

    if (!options.subject) {
      throw new Error('Missing required field: subject');
    }

    // Environment check
    const apiKey = env.API_KEY;
    if (!apiKey) {
      throw new Error('API_KEY not configured');
    }

    // Operation
    logger.info('Starting operation', {
      to: options.to,
      subject: options.subject
    });

    const result = await externalService.call({
      apiKey,
      data: options,
    });

    logger.info('Operation successful', {
      id: result.id,
      status: result.status
    });

    return {
      success: true,
      id: result.id,
      timestamp: new Date().toISOString(),
    };

  } catch (error: any) {
    logger.error(`Operation failed: ${error.message}`, {
      error: error.stack,
      options,
    });
    throw error; // Stop flow
  }
}
```

**Logging Strategy**:
```typescript
logger.info('Operation description', { key: 'value' });
logger.warn('Warning message');
logger.error('Error message', { error: error.stack, context });
```

**Configuration Approach**:
- Define options in operation configuration UI (app.ts)
- Access via options parameter
- Environment variables via env parameter
- Document all required options and env variables

**Success Criteria**:
- [ ] TypeScript compiles without errors
- [ ] Builds successfully
- [ ] Operation appears in flow operation dropdown
- [ ] Can be configured in flow builder
- [ ] Validates options correctly
- [ ] Executes successfully in flow
- [ ] Returns data for next operations
- [ ] Throws errors to stop flow when needed
- [ ] Logs show in Directus logs

**Validation Method**:
```bash
cd extensions/operations/directus-extension-{name}
npm run type-check
npm run build
# Deploy to Directus
# Create flow with operation
# Configure operation with test data
# Execute flow
# Check logs: docker-compose logs -f directus
# Verify next operations receive data
```

**Risk Level if Violated**: **HIGH**
- Missing validation causes flow failures
- Unhandled errors crash flow execution
- Incorrect return data breaks flow chain
- Missing env checks cause runtime failures
- Improper error handling makes debugging impossible

---

### 5. Modules

**Purpose**: Full-page administrative interfaces in the Directus App navigation

**Foolproof Definition**: Module that:
- Renders without errors in Directus App
- Uses Vue 3 Composition API correctly
- Integrates with Directus router
- Handles permissions and accountability
- Provides clear navigation and user feedback
- Uses Directus UI components for consistency

**Discovered Pattern**: **NONE** (No custom modules in codebase)

**Fallback Pattern**: Official Directus Documentation + Community Examples

**Required Files**:
```
directus-extension-{name}/
├── package.json
├── tsconfig.json
├── src/
│   ├── index.ts
│   ├── module.vue
│   └── routes.ts (optional: sub-routes)
```

**Required package.json Structure**:
```json
{
  "name": "directapp-module-{name}",
  "version": "1.0.0",
  "type": "module",
  "directus:extension": {
    "type": "module",
    "path": "dist/index.js",
    "source": "src/index.ts",
    "host": "^11.12.0"
  },
  "scripts": {
    "build": "directus-extension build",
    "dev": "directus-extension build --watch",
    "clean": "rm -rf dist",
    "type-check": "tsc --noEmit"
  },
  "devDependencies": {
    "@directus/extensions-sdk": "^16.0.2",
    "typescript": "^5.3.3",
    "vue": "^3.4.15",
    "vue-router": "^4.2.5"
  }
}
```

**Required Exports (src/index.ts)**:
```typescript
import { defineModule } from '@directus/extensions-sdk';
import ModuleComponent from './module.vue';

export default defineModule({
  id: 'unique-module-id',
  name: 'Module Name',
  icon: 'material_icon',
  routes: [
    {
      path: '',
      component: ModuleComponent,
    },
  ],
});
```

**Type Imports**:
```typescript
import { defineModule } from '@directus/extensions-sdk';
import { useApi, useStores } from '@directus/extensions-sdk';
import { ref, computed } from 'vue';
```

**Context Usage (module.vue)**:
```typescript
import { useApi, useStores } from '@directus/extensions-sdk';

const api = useApi();
const { useUserStore, usePermissionsStore } = useStores();
const userStore = useUserStore();
const permissionsStore = usePermissionsStore();

// Check permissions
const canAccess = computed(() => {
  return permissionsStore.hasPermission('collection', 'read');
});

// Access user info
const currentUser = computed(() => userStore.currentUser);

// API calls
const data = await api.get('/items/collection');
```

**Error Handling Approach**:
```typescript
const error = ref<string | null>(null);
const loading = ref(false);

async function loadData() {
  error.value = null;
  loading.value = true;

  try {
    const response = await api.get('/items/collection');
    // Handle data
  } catch (err: any) {
    error.value = err.message;
    console.error('Failed to load:', err);
  } finally {
    loading.value = false;
  }
}
```

**Logging Strategy**: Use console.log for development, useNotifications for user feedback

**Configuration Approach**:
- Module-level settings in module definition
- Runtime config via API calls to settings collection

**Success Criteria**:
- [ ] TypeScript compiles without errors
- [ ] Builds successfully
- [ ] Module appears in navigation
- [ ] Routes work correctly
- [ ] Permissions are checked
- [ ] API calls work
- [ ] Loading/error states are clear
- [ ] Uses Directus UI components

**Validation Method**:
```bash
cd extensions/directus-extension-{name}
npm run type-check
npm run build
# Deploy to Directus
# Check navigation for module icon
# Click module, verify it loads
# Test all routes and functionality
```

**Risk Level if Violated**: **MEDIUM**
- Broken module prevents access to functionality
- Missing permission checks expose data
- Router errors break navigation
- Missing error handling crashes app

---

### 6. Panels

**Purpose**: Dashboard widgets for the Insights module

**Foolproof Definition**: Panel that:
- Renders data visualization correctly
- Fetches data efficiently (with caching if needed)
- Handles loading and error states
- Provides configuration options
- Updates in real-time if needed
- Uses consistent styling with Directus

**Discovered Pattern**: **NONE** (No custom panels in codebase)

**Fallback Pattern**: Official Directus Documentation + Community Examples

**Required Files**:
```
directus-extension-{name}/
├── package.json
├── tsconfig.json
├── src/
│   ├── index.ts
│   └── panel.vue
```

**Required package.json Structure**:
```json
{
  "name": "directapp-panel-{name}",
  "version": "1.0.0",
  "type": "module",
  "directus:extension": {
    "type": "panel",
    "path": "dist/index.js",
    "source": "src/index.ts",
    "host": "^11.12.0"
  },
  "scripts": {
    "build": "directus-extension build",
    "dev": "directus-extension build --watch",
    "clean": "rm -rf dist",
    "type-check": "tsc --noEmit"
  },
  "devDependencies": {
    "@directus/extensions-sdk": "^16.0.2",
    "typescript": "^5.3.3",
    "vue": "^3.4.15"
  }
}
```

**Required Exports (src/index.ts)**:
```typescript
import { definePanel } from '@directus/extensions-sdk';
import PanelComponent from './panel.vue';

export default definePanel({
  id: 'unique-panel-id',
  name: 'Panel Name',
  description: 'Panel description',
  icon: 'material_icon',
  component: PanelComponent,
  options: [
    {
      field: 'collection',
      name: 'Collection',
      type: 'string',
      meta: {
        interface: 'system-collection',
        width: 'half',
      },
    },
    // More options...
  ],
  minWidth: 12,
  minHeight: 8,
});
```

**Type Imports**:
```typescript
import { definePanel } from '@directus/extensions-sdk';
import { useApi } from '@directus/extensions-sdk';
import { ref, computed, watch } from 'vue';
```

**Context Usage (panel.vue)**:
```typescript
interface Props {
  showHeader: boolean;
  // Configuration options
  [option: string]: any;
}

const props = defineProps<Props>();
const api = useApi();

// Fetch data based on props
watch(() => props.collection, async (newCollection) => {
  await fetchData(newCollection);
}, { immediate: true });
```

**Error Handling Approach**:
```typescript
const error = ref<string | null>(null);
const loading = ref(false);

async function fetchData() {
  error.value = null;
  loading.value = true;

  try {
    const response = await api.get('/items/collection', {
      params: { limit: 10 },
    });
    // Process data
  } catch (err: any) {
    error.value = 'Failed to load data';
  } finally {
    loading.value = false;
  }
}
```

**Logging Strategy**: Console for development, minimal in production

**Configuration Approach**:
- Define options in definePanel({ options: [...] })
- Access via props
- Update data when options change

**Success Criteria**:
- [ ] TypeScript compiles without errors
- [ ] Builds successfully
- [ ] Panel appears in Insights panel list
- [ ] Can be added to dashboard
- [ ] Configuration options work
- [ ] Data loads correctly
- [ ] Responsive to container size
- [ ] Loading/error states are clear

**Validation Method**:
```bash
cd extensions/directus-extension-{name}
npm run type-check
npm run build
# Deploy to Directus
# Go to Insights
# Add panel to dashboard
# Configure panel
# Verify data displays correctly
```

**Risk Level if Violated**: **LOW**
- Broken panel only affects dashboard
- Users can remove broken panel
- Doesn't affect core functionality

---

### 7. Layouts

**Purpose**: Custom collection browse layouts (alternative to table/cards/etc)

**Foolproof Definition**: Layout that:
- Renders collection items correctly
- Supports selection, filtering, sorting
- Handles large datasets efficiently
- Provides consistent interaction patterns
- Integrates with Directus layout system
- Supports all standard layout features

**Discovered Pattern**: **NONE** (No custom layouts in codebase)

**Fallback Pattern**: Official Directus Documentation + Community Examples

**Required Files**:
```
directus-extension-{name}/
├── package.json
├── tsconfig.json
├── src/
│   ├── index.ts
│   ├── layout.vue
│   ├── options.vue (layout configuration)
│   └── sidebar.vue (optional: layout sidebar)
```

**Required package.json Structure**:
```json
{
  "name": "directapp-layout-{name}",
  "version": "1.0.0",
  "type": "module",
  "directus:extension": {
    "type": "layout",
    "path": "dist/index.js",
    "source": "src/index.ts",
    "host": "^11.12.0"
  },
  "scripts": {
    "build": "directus-extension build",
    "dev": "directus-extension build --watch",
    "clean": "rm -rf dist",
    "type-check": "tsc --noEmit"
  },
  "devDependencies": {
    "@directus/extensions-sdk": "^16.0.2",
    "typescript": "^5.3.3",
    "vue": "^3.4.15"
  }
}
```

**Required Exports (src/index.ts)**:
```typescript
import { defineLayout } from '@directus/extensions-sdk';
import LayoutComponent from './layout.vue';
import OptionsComponent from './options.vue';

export default defineLayout({
  id: 'unique-layout-id',
  name: 'Layout Name',
  icon: 'material_icon',
  component: LayoutComponent,
  slots: {
    options: OptionsComponent,
    sidebar: SidebarComponent, // Optional
    actions: ActionsComponent, // Optional
  },
});
```

**Type Imports**:
```typescript
import { defineLayout } from '@directus/extensions-sdk';
import { useCollection, useItems } from '@directus/extensions-sdk';
import { ref, computed } from 'vue';
```

**Context Usage (layout.vue)**:
```typescript
interface Props {
  collection: string;
  selection: (string | number)[];
  layoutOptions: Record<string, any>;
  layoutQuery: {
    fields: string[];
    sort: string[];
    page: number;
    limit: number;
  };
  filter: Record<string, any>;
  search: string;
}

const props = defineProps<Props>();
const emit = defineEmits(['update:selection', 'update:layoutOptions', 'update:layoutQuery']);

// Use composables
const { items, loading, error } = useItems(ref(props.collection), {
  fields: computed(() => props.layoutQuery.fields),
  sort: computed(() => props.layoutQuery.sort),
  filter: computed(() => props.filter),
  search: computed(() => props.search),
  page: computed(() => props.layoutQuery.page),
  limit: computed(() => props.layoutQuery.limit),
});

// Handle selection
function toggleSelection(itemId: string | number) {
  const newSelection = [...props.selection];
  const index = newSelection.indexOf(itemId);

  if (index >= 0) {
    newSelection.splice(index, 1);
  } else {
    newSelection.push(itemId);
  }

  emit('update:selection', newSelection);
}
```

**Error Handling Approach**:
```typescript
// Error handling via composables
const { items, loading, error } = useItems(collection);

// Display error in template
<template>
  <div v-if="error" class="error">{{ error.message }}</div>
  <div v-else-if="loading">Loading...</div>
  <div v-else>
    <!-- Render items -->
  </div>
</template>
```

**Logging Strategy**: Minimal logging, rely on Vue devtools

**Configuration Approach**:
- Layout options via options.vue component
- Emit 'update:layoutOptions' to persist settings
- Access via props.layoutOptions

**Success Criteria**:
- [ ] TypeScript compiles without errors
- [ ] Builds successfully
- [ ] Layout appears in layout dropdown
- [ ] Items render correctly
- [ ] Selection works
- [ ] Sorting/filtering works
- [ ] Pagination works
- [ ] Performance is acceptable for large datasets

**Validation Method**:
```bash
cd extensions/directus-extension-{name}
npm run type-check
npm run build
# Deploy to Directus
# Open collection
# Switch to custom layout
# Test selection, sorting, filtering
# Test with large dataset
```

**Risk Level if Violated**: **MEDIUM**
- Broken layout affects collection browsing
- Performance issues impact user experience
- Selection bugs can prevent bulk operations

---

### 8. Displays

**Purpose**: Custom read-only field displays in collection browse layouts

**Foolproof Definition**: Display that:
- Renders field value correctly
- Handles null/undefined values
- Performs efficiently (no heavy computation)
- Uses consistent styling
- Supports configuration options
- Works in all layouts

**Discovered Pattern**: **NONE** (No custom displays in codebase)

**Fallback Pattern**: Official Directus Documentation + Community Examples

**Required Files**:
```
directus-extension-{name}/
├── package.json
├── tsconfig.json
├── src/
│   ├── index.ts
│   └── display.vue
```

**Required package.json Structure**:
```json
{
  "name": "directapp-display-{name}",
  "version": "1.0.0",
  "type": "module",
  "directus:extension": {
    "type": "display",
    "path": "dist/index.js",
    "source": "src/index.ts",
    "host": "^11.12.0"
  },
  "scripts": {
    "build": "directus-extension build",
    "dev": "directus-extension build --watch",
    "clean": "rm -rf dist",
    "type-check": "tsc --noEmit"
  },
  "devDependencies": {
    "@directus/extensions-sdk": "^16.0.2",
    "typescript": "^5.3.3",
    "vue": "^3.4.15"
  }
}
```

**Required Exports (src/index.ts)**:
```typescript
import { defineDisplay } from '@directus/extensions-sdk';
import DisplayComponent from './display.vue';

export default defineDisplay({
  id: 'unique-display-id',
  name: 'Display Name',
  description: 'Display description',
  icon: 'material_icon',
  component: DisplayComponent,
  options: [
    {
      field: 'format',
      name: 'Format',
      type: 'string',
      meta: {
        interface: 'select-dropdown',
        options: {
          choices: [
            { text: 'Option 1', value: 'option1' },
            { text: 'Option 2', value: 'option2' },
          ],
        },
      },
    },
  ],
  types: ['string', 'text', 'json'], // Supported field types
});
```

**Type Imports**:
```typescript
import { defineDisplay } from '@directus/extensions-sdk';
import { computed } from 'vue';
```

**Context Usage (display.vue)**:
```typescript
interface Props {
  value: any;                      // Field value
  collection: string;              // Collection name
  field: string;                   // Field name
  type: string;                    // Field type
  // Configuration options
  [option: string]: any;
}

const props = defineProps<Props>();

// Computed display value
const displayValue = computed(() => {
  if (!props.value) return '—'; // Handle null/undefined

  // Format value
  return formatValue(props.value, props.format);
});
```

**Error Handling Approach**:
```typescript
// Handle all value types gracefully
const displayValue = computed(() => {
  try {
    if (props.value === null || props.value === undefined) {
      return '—';
    }

    if (typeof props.value === 'object') {
      return JSON.stringify(props.value);
    }

    return String(props.value);
  } catch (error) {
    console.error('Display error:', error);
    return '—';
  }
});
```

**Logging Strategy**: Minimal to none, displays should be lightweight

**Configuration Approach**:
- Options in defineDisplay({ options: [...] })
- Access via props
- Keep options simple and performant

**Success Criteria**:
- [ ] TypeScript compiles without errors
- [ ] Builds successfully
- [ ] Display appears in display dropdown
- [ ] Renders values correctly
- [ ] Handles null/undefined gracefully
- [ ] Performs efficiently in large tables
- [ ] Configuration options work

**Validation Method**:
```bash
cd extensions/directus-extension-{name}
npm run type-check
npm run build
# Deploy to Directus
# Go to collection settings
# Configure field to use display
# Verify display in table layout
# Test with various values (null, text, numbers, etc)
```

**Risk Level if Violated**: **LOW**
- Broken display only affects field rendering
- Users can switch to different display
- Doesn't affect data integrity

---

### 9. Bundles

**Purpose**: Package multiple extensions together for distribution

**Foolproof Definition**: Bundle that:
- Packages related extensions logically
- Maintains independent extension functionality
- Builds without conflicts
- Provides clear installation instructions
- Uses consistent versioning
- Documents all included extensions

**Discovered Pattern**: **NONE** (Empty bundles directory in codebase)

**Fallback Pattern**: Official Directus Documentation

**Required Files**:
```
directus-extension-{name}-bundle/
├── package.json
├── tsconfig.json
├── src/
│   ├── index.ts
│   ├── interface-1/
│   │   ├── index.ts
│   │   └── interface.vue
│   ├── endpoint-1/
│   │   └── index.ts
│   └── hook-1/
│       └── index.ts
```

**Required package.json Structure**:
```json
{
  "name": "directapp-bundle-{name}",
  "version": "1.0.0",
  "type": "module",
  "directus:extension": {
    "type": "bundle",
    "path": "dist/index.js",
    "source": "src/index.ts",
    "host": "^11.12.0",
    "entries": [
      {
        "type": "interface",
        "name": "interface-name",
        "source": "src/interface-1/index.ts"
      },
      {
        "type": "endpoint",
        "name": "endpoint-name",
        "source": "src/endpoint-1/index.ts"
      },
      {
        "type": "hook",
        "name": "hook-name",
        "source": "src/hook-1/index.ts"
      }
    ]
  },
  "scripts": {
    "build": "directus-extension build",
    "dev": "directus-extension build --watch",
    "clean": "rm -rf dist",
    "type-check": "tsc --noEmit"
  },
  "devDependencies": {
    "@directus/extensions-sdk": "^16.0.2",
    "typescript": "^5.3.3",
    "vue": "^3.4.15"
  }
}
```

**Required Exports (src/index.ts)**:
```typescript
import { defineBundle } from '@directus/extensions-sdk';

export default defineBundle({
  id: 'bundle-id',
  name: 'Bundle Name',
});
```

**Type Imports**:
```typescript
import { defineBundle } from '@directus/extensions-sdk';
```

**Context Usage**: Same as individual extensions, context passed to each extension separately

**Error Handling Approach**: Each extension handles its own errors independently

**Logging Strategy**: Each extension logs independently

**Configuration Approach**:
- Configure each extension independently
- Bundle-level documentation for setup
- Shared dependencies in bundle package.json

**Success Criteria**:
- [ ] TypeScript compiles without errors
- [ ] Builds successfully
- [ ] All extensions in bundle work independently
- [ ] No conflicts between extensions
- [ ] Installation documentation is clear
- [ ] Version management is consistent

**Validation Method**:
```bash
cd extensions/directus-extension-{name}-bundle
npm run type-check
npm run build
# Deploy to Directus
# Verify all extensions appear
# Test each extension independently
# Verify no conflicts
```

**Risk Level if Violated**: **MEDIUM**
- Bundle conflicts can break multiple extensions
- Poor documentation makes installation difficult
- Version mismatches cause compatibility issues

---

## Anti-Pattern Prevention

### Patterns to Follow

#### 1. TypeScript Strict Mode
**Description**: Enable strict TypeScript checking for all extensions

**Why Critical**:
- Catches errors at compile time
- Prevents runtime type errors
- Improves code maintainability
- Ensures type safety across extension boundaries

**How to Validate**:
```bash
npm run type-check
# Must pass with no errors
```

**Example Code**:
```typescript
// tsconfig.json
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true
  }
}

// Good: Explicit types
interface Props {
  value: string | null;
  collection: string;
}

// Bad: Any types
interface Props {
  value: any;
  collection: any;
}
```

#### 2. Comprehensive Error Handling
**Description**: Every async operation must have try-catch with logging

**Why Critical**:
- Prevents extension crashes
- Enables debugging in production
- Provides user feedback
- Maintains system stability

**How to Validate**:
- Search for `async` without `try-catch`
- Check all API calls have error handlers
- Verify all errors are logged

**Example Code**:
```typescript
// Good: Comprehensive error handling
async function fetchData() {
  try {
    const response = await api.get('/endpoint');
    logger.info('Data fetched successfully');
    return response.data;
  } catch (error: any) {
    logger.error(`Failed to fetch: ${error.message}`, { error: error.stack });
    throw new Error('Failed to fetch data');
  }
}

// Bad: No error handling
async function fetchData() {
  const response = await api.get('/endpoint');
  return response.data;
}
```

#### 3. Explicit Logging
**Description**: Log all significant operations with context

**Why Critical**:
- Enables debugging in production
- Provides audit trail
- Helps diagnose issues quickly
- Documents execution flow

**How to Validate**:
- Check logger.info for all operations
- Verify logger.error for all failures
- Ensure context data is included

**Example Code**:
```typescript
// Good: Explicit logging
logger.info('Starting workflow transition', {
  carId: meta.keys[0],
  oldStatus,
  newStatus
});

// Operation...

logger.info('Workflow transition completed', {
  carId: meta.keys[0],
  timestamp: new Date().toISOString()
});

// Bad: No logging
// Just do the operation silently
```

#### 4. Input Validation
**Description**: Validate all input parameters before processing

**Why Critical**:
- Prevents invalid data processing
- Provides clear error messages
- Improves security
- Reduces debugging time

**How to Validate**:
- Check all handlers validate parameters
- Verify clear error messages
- Test with invalid input

**Example Code**:
```typescript
// Good: Input validation
if (!param || param.length < 2) {
  return res.status(400).json({
    error: 'Invalid parameter',
    message: 'Parameter must be at least 2 characters'
  });
}

// Bad: No validation
const result = await process(param);
```

#### 5. Environment Variable Checks
**Description**: Check environment variables availability before use

**Why Critical**:
- Prevents runtime failures
- Provides clear error messages
- Enables graceful degradation
- Helps with configuration debugging

**How to Validate**:
- Check all env variable usage
- Verify availability checks
- Test with missing variables

**Example Code**:
```typescript
// Good: Check availability
const apiKey = env.API_KEY;
if (!apiKey) {
  logger.warn('API_KEY not configured');
  return res.status(503).json({
    error: 'Service not configured'
  });
}

// Bad: Direct usage
const result = await api.call(env.API_KEY);
```

#### 6. Service-Based Database Access
**Description**: Always use ItemsService for database operations

**Why Critical**:
- Respects user permissions
- Handles relations correctly
- Provides consistent API
- Ensures data integrity

**How to Validate**:
- Check no raw database queries
- Verify ItemsService usage
- Test with different user permissions

**Example Code**:
```typescript
// Good: ItemsService
const service = new ItemsService('collection', {
  schema: await context.database.schema,
  accountability: context.accountability,
});
const items = await service.readByQuery({ filter, limit });

// Bad: Raw database query
const items = await context.database.raw('SELECT * FROM collection');
```

#### 7. Separation of Concerns (Hooks)
**Description**: Use filters for validation, actions for side-effects

**Why Critical**:
- Prevents blocking side-effects
- Enables proper error handling
- Improves debugging
- Maintains data consistency

**How to Validate**:
- Check filters only validate and modify payload
- Verify actions never throw errors
- Test validation and side-effects separately

**Example Code**:
```typescript
// Good: Separated concerns
filter('collection.items.update', async (payload, meta, context) => {
  // Validation only
  if (invalid) throw new InvalidPayloadException('Error');
  return payload;
});

action('collection.items.update', async (meta, context) => {
  try {
    // Side-effects only
    await sendNotification();
  } catch (error) {
    logger.error('Notification failed');
    // Don't throw
  }
});

// Bad: Mixed concerns
filter('collection.items.update', async (payload, meta, context) => {
  if (invalid) throw new Error('Error');
  await sendNotification(); // Side-effect in filter!
  return payload;
});
```

#### 8. Proper HTTP Status Codes (Endpoints)
**Description**: Return correct HTTP status codes for all scenarios

**Why Critical**:
- Enables proper client error handling
- Follows REST conventions
- Improves API usability
- Enables monitoring and alerting

**How to Validate**:
- Check all response paths have status codes
- Verify codes match scenarios
- Test client integration

**Example Code**:
```typescript
// Good: Proper status codes
if (!param) return res.status(400).json({ error: 'Bad request' });
if (!found) return res.status(404).json({ error: 'Not found' });
if (!configured) return res.status(503).json({ error: 'Service unavailable' });
return res.status(200).json({ success: true, data });

// Bad: Generic 200 for everything
return res.json({ error: 'Something failed' });
```

---

### Patterns to Avoid

#### 1. Disabled Extensions with Suffix
**Pattern**: Disabling extensions by adding `.disabled` suffix to directory name

**Why Harmful**:
- Clutters extension directory
- Breaks version control patterns
- Makes true inventory unclear
- Confuses deployment process
- Wastes build resources

**How to Detect**:
```bash
find extensions -name "*.disabled" -type d
```

**Remediation**:
1. Move disabled extensions to `extensions/.disabled/` directory
2. Or delete completely and rely on git history
3. Update deployment scripts to ignore `.disabled/` directory
4. Document disabled extensions in README with reason

**Example**:
```bash
# Bad
extensions/
├── directus-extension-send-email.disabled/
├── directus-extension-parse-order-pdf.disabled/

# Good
extensions/
├── .disabled/
│   ├── directus-extension-send-email/  # Reason: Using built-in mail
│   ├── directus-extension-parse-order-pdf/  # Reason: Feature postponed
```

#### 2. Missing Type Definitions
**Pattern**: Using `any` type or missing type annotations

**Why Harmful**:
- Defeats purpose of TypeScript
- Causes runtime errors
- Makes refactoring dangerous
- Reduces code quality

**How to Detect**:
```bash
grep -r ": any" src/
grep -r "as any" src/
```

**Remediation**:
1. Define proper interfaces for all data structures
2. Use strict TypeScript settings
3. Add return type annotations to functions
4. Enable `noImplicitAny` in tsconfig

**Example**:
```typescript
// Bad: Any types
function processData(data: any): any {
  return data.value;
}

// Good: Explicit types
interface InputData {
  value: string;
  timestamp: string;
}

function processData(data: InputData): string {
  return data.value;
}
```

#### 3. Unhandled Promise Rejections
**Pattern**: Async operations without try-catch

**Why Harmful**:
- Crashes extension
- Loses error context
- Makes debugging impossible
- Affects other extensions

**How to Detect**:
```bash
# Search for async without try
grep -A 5 "async function" src/ | grep -v "try"
```

**Remediation**:
1. Add try-catch to all async functions
2. Log all errors with context
3. Provide fallback values
4. Test error scenarios

**Example**:
```typescript
// Bad: No error handling
async function fetchData() {
  const response = await api.get('/endpoint');
  return response.data;
}

// Good: Proper error handling
async function fetchData() {
  try {
    const response = await api.get('/endpoint');
    return response.data;
  } catch (error: any) {
    logger.error(`Fetch failed: ${error.message}`);
    return null; // Fallback value
  }
}
```

#### 4. Direct Database Queries
**Pattern**: Using `context.database` for raw queries

**Why Harmful**:
- Bypasses permissions
- No validation
- No automatic relations
- SQL injection risk

**How to Detect**:
```bash
grep -r "context.database.raw" src/
grep -r "context.database.select" src/
```

**Remediation**:
1. Replace with ItemsService
2. Use proper context and accountability
3. Test with different user permissions
4. Review all database access

**Example**:
```typescript
// Bad: Raw database query
const items = await context.database.raw(
  'SELECT * FROM cars WHERE status = ?',
  ['active']
);

// Good: ItemsService
const service = new ItemsService('cars', {
  schema: await context.database.schema,
  accountability: context.accountability,
});
const items = await service.readByQuery({
  filter: { status: { _eq: 'active' } }
});
```

#### 5. Silent Failures
**Pattern**: Catching errors without logging

**Why Harmful**:
- Makes debugging impossible
- Hides underlying issues
- Accumulates technical debt
- Degrades user experience silently

**How to Detect**:
```bash
grep -A 2 "catch" src/ | grep -v "logger"
```

**Remediation**:
1. Log all caught errors
2. Include error stack trace
3. Add context data
4. Monitor error rates

**Example**:
```typescript
// Bad: Silent failure
try {
  await operation();
} catch (error) {
  // Nothing - error disappears
}

// Good: Logged failure
try {
  await operation();
} catch (error: any) {
  logger.error(`Operation failed: ${error.message}`, {
    error: error.stack,
    context: contextData,
  });
  throw error; // Or handle gracefully with fallback
}
```

#### 6. Hardcoded Configuration
**Pattern**: Hardcoding URLs, API keys, or settings

**Why Harmful**:
- Security risk (exposed secrets)
- Environment-specific code
- Difficult to change
- No flexibility

**How to Detect**:
```bash
grep -r "https://" src/
grep -r "api_key = " src/
```

**Remediation**:
1. Move to environment variables
2. Check availability before use
3. Document required variables
4. Use configuration collection

**Example**:
```typescript
// Bad: Hardcoded
const API_URL = 'https://api.example.com';
const API_KEY = 'sk_live_123456';

// Good: Environment variables
const apiUrl = env.API_URL;
const apiKey = env.API_KEY;

if (!apiUrl || !apiKey) {
  throw new Error('API_URL and API_KEY must be configured');
}
```

#### 7. Missing Loading States (UI)
**Pattern**: No loading indicator for async operations

**Why Harmful**:
- Poor user experience
- Appears broken or frozen
- Users click multiple times
- No feedback on progress

**How to Detect**:
- Manual UI testing
- Check for loading refs in components
- Verify loading states in templates

**Remediation**:
1. Add loading ref for all async operations
2. Show loading indicator in UI
3. Disable interactive elements during loading
4. Show progress for long operations

**Example**:
```vue
<!-- Bad: No loading state -->
<template>
  <button @click="fetchData">Fetch</button>
  <div>{{ data }}</div>
</template>

<!-- Good: Loading state -->
<template>
  <button @click="fetchData" :disabled="loading">
    {{ loading ? 'Loading...' : 'Fetch' }}
  </button>
  <v-progress-circular v-if="loading" />
  <div v-else>{{ data }}</div>
</template>

<script setup>
const loading = ref(false);

async function fetchData() {
  loading.value = true;
  try {
    // Fetch...
  } finally {
    loading.value = false;
  }
}
</script>
```

---

## Infrastructure Requirements

### Build System

**Tool**: Directus Extensions SDK
**Version**: ^16.0.2
**Commands**:
```bash
npm run build          # Build extension for production
npm run dev            # Build and watch for changes
npm run clean          # Remove dist directory
npm run type-check     # TypeScript type checking
```

**Configuration** (package.json):
```json
{
  "type": "module",
  "directus:extension": {
    "type": "interface|hook|endpoint|operation|module|panel|layout|display|bundle",
    "path": "dist/index.js",
    "source": "src/index.ts",
    "host": "^11.12.0"
  },
  "scripts": {
    "build": "directus-extension build",
    "dev": "directus-extension build --watch",
    "clean": "rm -rf dist",
    "type-check": "tsc --noEmit"
  }
}
```

**Required in all extensions**: Yes
**Validation**: `npm run build` must succeed without errors

---

### TypeScript Configuration

**Version**: ^5.3.3
**Base Config**: `tsconfig.base.json` (shared across all extensions)

**Base Configuration** (`tsconfig.base.json`):
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "node",
    "strict": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "resolveJsonModule": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "noEmit": false,
    "isolatedModules": true,
    "allowSyntheticDefaultImports": true,
    "forceConsistentCasingInFileNames": true
  }
}
```

**Extension-Specific Config** (`tsconfig.json`):
```json
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "outDir": "./dist",
    "rootDir": "./src",
    "jsx": "preserve",  // For Vue components
    "lib": ["ES2022", "DOM"]  // For UI extensions
  },
  "include": ["src/**/*"]
}
```

**Required in all extensions**: Yes
**Validation**: `npm run type-check` must pass

---

### Development Environment

**Node.js**: v18+ (LTS)
**Package Manager**: npm
**IDE**: VS Code (recommended) with extensions:
- ESLint
- Vetur or Volar (for Vue)
- TypeScript Vue Plugin

**Local Development Setup**:
```bash
# In extension directory
npm install
npm run dev  # Watch mode

# In Directus root
docker-compose up  # Start Directus with hot reload
```

**Environment Variables** (`.env`):
```bash
# Required for specific extensions
STATENS_VEGVESEN_TOKEN=your_token_here
RESEND_API_KEY=your_key_here
EMAIL_FROM=noreply@yourdomain.com
```

**Hot Reload**: Supported via `npm run dev` + Directus watch mode

**Required**: Yes, all developers must use consistent environment

---

### Testing Requirements

**Strategy**: Manual testing + TypeScript type checking

**Pre-Deployment Checklist**:
1. [ ] `npm run type-check` passes
2. [ ] `npm run build` succeeds
3. [ ] Extension loads in Directus without errors
4. [ ] All features work as expected
5. [ ] Error scenarios handled gracefully
6. [ ] Logging shows correct information
7. [ ] Performance is acceptable
8. [ ] No console errors in browser (UI extensions)

**Test Scenarios per Extension Type**:

**Interfaces**:
- Add field to collection
- Configure options
- Save item with field
- Edit existing item
- Verify data in API response
- Test with null/empty values
- Test validation rules

**Hooks**:
- Create item (check filters and actions)
- Update item (check validation)
- Delete item (check prevention)
- Try invalid transitions (should fail)
- Check logs for all operations
- Test with different user permissions

**Endpoints**:
- Call with valid parameters
- Call with invalid parameters
- Call with missing parameters
- Call when service unavailable
- Check response format
- Verify status codes
- Check logs

**Operations**:
- Add to flow
- Configure options
- Execute flow
- Verify output data
- Test error scenarios
- Check logs
- Verify next operations receive data

**Testing Tools**:
- Browser DevTools (for UI extensions)
- Postman/cURL (for endpoints)
- Directus logs (`docker-compose logs -f directus`)
- Vue DevTools (for UI extensions)

**Required**: Yes, all extensions must pass checklist

---

### Deployment Requirements

**Target**: Docker container (Directus)
**Deployment Method**: Copy to extensions directory + restart

**Directory Structure**:
```
/directus/extensions/
├── directus-extension-{name}/
│   ├── dist/
│   │   └── index.js
│   └── package.json
```

**Deployment Process**:
```bash
# 1. Build extension
cd extensions/directus-extension-{name}
npm run build

# 2. Copy to Directus (if not using volume mount)
docker cp dist/ directus:/directus/extensions/directus-extension-{name}/

# 3. Restart Directus
docker-compose restart directus

# 4. Verify in logs
docker-compose logs -f directus | grep "extension"
```

**Volume Mount** (development):
```yaml
# docker-compose.yml
services:
  directus:
    volumes:
      - ./extensions:/directus/extensions
```

**Environment Variables**:
- Configured in `.env` file
- Mounted into Docker container
- Documented in extension README

**Rollback Strategy**:
1. Remove extension directory
2. Restart Directus
3. Or: Deploy previous version

**Health Checks**:
- Directus startup logs show extension loaded
- Extension appears in UI (if applicable)
- Functionality works as expected
- No errors in logs

**Required**: Yes, documented deployment process for each extension

---

## Pattern Compliance Matrix

| Extension Type | Required Pattern Elements | Discovered Example | Fallback Pattern | Validation Method | Risk Level |
|---|---|---|---|---|---|
| **Interfaces** | defineInterface, Vue 3 component, props.values access, emit('input'), config mode detection, useApi composable | `/extensions/directus-extension-vehicle-lookup-button` | N/A | `npm run type-check && npm run build`, UI testing, verify emit data | **HIGH** |
| **Hooks** | defineHook, filter vs action separation, ItemsService usage, accountability context, comprehensive logging, exception throwing (filters only) | `/extensions/directus-extension-workflow-guard` | N/A | `npm run type-check && npm run build`, test CRUD operations, check logs, verify validations | **CRITICAL** |
| **Endpoints** | defineEndpoint, async handlers, proper HTTP codes, input validation, env checks, try-catch, ItemsService, JSON responses | `/extensions/directus-extension-vehicle-lookup` | N/A | `npm run type-check && npm run build`, cURL testing, check status codes, verify logs | **HIGH** |
| **Operations** | defineOperationApi, options validation, env checks, external SDK usage, return data structure, error throwing, comprehensive logging | `/extensions/operations/directus-extension-send-email.disabled` | N/A | `npm run type-check && npm run build`, flow execution, verify output data, check logs | **HIGH** |
| **Modules** | defineModule, Vue 3 components, router integration, useApi, useStores, permission checks, navigation | None | Official Directus docs + community examples | `npm run type-check && npm run build`, UI navigation, test routes, verify permissions | **MEDIUM** |
| **Panels** | definePanel, Vue 3 component, options configuration, useApi, data fetching, responsive sizing, loading states | None | Official Directus docs + community examples | `npm run type-check && npm run build`, add to dashboard, configure, verify data display | **LOW** |
| **Layouts** | defineLayout, Vue 3 components, useCollection, useItems, selection handling, sorting/filtering, pagination | None | Official Directus docs + community examples | `npm run type-check && npm run build`, test in collection, verify selection/sorting/filtering | **MEDIUM** |
| **Displays** | defineDisplay, Vue 3 component, value formatting, null handling, performance (no heavy computation) | None | Official Directus docs + community examples | `npm run type-check && npm run build`, test in table layout, verify various value types | **LOW** |
| **Bundles** | defineBundle, multiple extensions packaged, independent functionality, shared dependencies, clear documentation | None (empty directory) | Official Directus docs | `npm run type-check && npm run build`, test each extension, verify no conflicts | **MEDIUM** |

---

## Implementation Decision Pre-Commitment

### For Each Extension Type:

---

### Interfaces

**Directory Structure**:
```
/extensions/directus-extension-{kebab-case-name}/
├── package.json
├── tsconfig.json
├── README.md
├── src/
│   ├── index.ts
│   └── interface.vue
└── dist/ (generated)
```

**File Naming Convention**:
- Package: `directapp-interface-{name}`
- Main component: `interface.vue`
- Entry point: `index.ts`
- ID: `{kebab-case-name}` (no prefix)

**Export Structure** (index.ts):
```typescript
import { defineInterface } from '@directus/extensions-sdk';
import InterfaceComponent from './interface.vue';

export default defineInterface({
  id: 'unique-id',
  name: 'Display Name',
  description: 'Clear description',
  icon: 'material_icon',
  component: InterfaceComponent,
  options: [...],
  types: ['string', 'text', 'json', 'alias'],
});
```

**Type Imports**:
```typescript
// index.ts
import { defineInterface } from '@directus/extensions-sdk';

// interface.vue
import { ref, computed, watch } from 'vue';
import { useApi } from '@directus/extensions-sdk';
```

**Context Usage Patterns**:
```typescript
// Props interface
interface Props {
  value?: any;
  collection: string;
  field: string;
  primaryKey: string | number;
  values: Record<string, any>;
  [configOption: string]: any;
}

// Detect config mode
const isConfigMode = computed(() => props.collection === 'directus_fields');

// Access other fields
const otherFieldValue = computed(() => props.values?.[fieldName]);

// Emit single value
emit('input', newValue);

// Emit multiple fields
emit('input', { field1: value1, field2: value2 });
```

**Error Handling Pattern**:
```typescript
const error = ref<string | null>(null);
const loading = ref(false);

async function action() {
  error.value = null;
  loading.value = true;
  try {
    // Action
  } catch (err: any) {
    error.value = err.message;
    console.error('Action failed:', err);
  } finally {
    loading.value = false;
  }
}
```

**Logging Strategy**: console.log/error for development

**Configuration Approach**: Via options array in defineInterface, accessed via props

---

### Hooks

**Directory Structure**:
```
/extensions/directus-extension-{kebab-case-name}/
├── package.json
├── tsconfig.json
├── README.md
├── src/
│   ├── index.ts
│   └── (config files if needed)
└── dist/ (generated)
```

**File Naming Convention**:
- Package: `directapp-hook-{name}`
- Entry point: `index.ts`
- ID: `{kebab-case-name}` (no prefix)

**Export Structure** (index.ts):
```typescript
import { defineHook } from '@directus/extensions-sdk';

export default defineHook(({ filter, action }, { services, logger, exceptions }) => {
  const { ItemsService } = services;
  const { ForbiddenException, InvalidPayloadException } = exceptions;

  filter('collection.items.event', async (payload, meta, context) => {
    // Validation, modification
    return payload;
  });

  action('collection.items.event', async (meta, context) => {
    // Side-effects only
  });
});
```

**Type Imports**:
```typescript
import { defineHook } from '@directus/extensions-sdk';
```

**Context Usage Patterns**:
```typescript
// ItemsService
const service = new ItemsService('collection', {
  schema: await context.database.schema,
  accountability: context.accountability,
});

// Read current item
const item = await service.readOne(meta.keys[0]);

// Query
const items = await service.readByQuery({ filter, limit });

// User context
const userId = context.accountability?.user;

// Throw exceptions (filters only)
throw new InvalidPayloadException('Message');
```

**Error Handling Pattern**:
```typescript
// Filters: Re-throw
filter('collection.items.event', async (payload, meta, context) => {
  try {
    // Validation
    return payload;
  } catch (error: any) {
    logger.error(`Validation failed: ${error.message}`);
    throw error;
  }
});

// Actions: Log only
action('collection.items.event', async (meta, context) => {
  try {
    // Side-effect
  } catch (error: any) {
    logger.error(`Action failed: ${error.message}`);
    // Don't throw
  }
});
```

**Logging Strategy**:
```typescript
logger.info('Operation', { context });
logger.warn('Warning');
logger.error('Error', { error: error.stack });
```

**Configuration Approach**: Import from config files or database collection

---

### Endpoints

**Directory Structure**:
```
/extensions/directus-extension-{kebab-case-name}/
├── package.json
├── tsconfig.json
├── README.md
├── src/
│   ├── index.ts
│   └── (utility files)
└── dist/ (generated)
```

**File Naming Convention**:
- Package: `directapp-endpoint-{name}`
- Entry point: `index.ts`
- ID: `{kebab-case-name}` (becomes URL path)

**Export Structure** (index.ts):
```typescript
import { defineEndpoint } from '@directus/extensions-sdk';

export default defineEndpoint({
  id: 'endpoint-id',
  handler: (router, { env, logger, services }) => {
    const { ItemsService } = services;

    router.get('/path/:param', async (req, res) => {
      try {
        // Handler
        res.json({ success: true, data });
      } catch (error: any) {
        logger.error(`Error: ${error.message}`);
        res.status(500).json({ error: 'Message' });
      }
    });
  },
});
```

**Type Imports**:
```typescript
import { defineEndpoint } from '@directus/extensions-sdk';
import axios from 'axios';
```

**Context Usage Patterns**:
```typescript
// Environment
const apiKey = env.API_KEY;
if (!apiKey) {
  return res.status(503).json({ error: 'Not configured' });
}

// Request data
const { param } = req.params;
const { query } = req.query;
const { body } = req.body;

// ItemsService
const service = new ItemsService('collection', {
  schema: req.schema,
  accountability: req.accountability,
});

// Responses
res.json({ success: true, data });
res.status(400).json({ error: 'Bad request' });
res.status(404).json({ error: 'Not found' });
res.status(500).json({ error: 'Server error' });
res.status(503).json({ error: 'Service unavailable' });
```

**Error Handling Pattern**:
```typescript
router.get('/path/:param', async (req, res) => {
  try {
    // Validation
    if (!param) {
      return res.status(400).json({ error: 'Missing param' });
    }

    // Config check
    if (!env.API_KEY) {
      return res.status(503).json({ error: 'Not configured' });
    }

    // Operation
    logger.info(`Request: ${param}`);
    const result = await operation();
    logger.info('Success');

    return res.json({ success: true, data: result });

  } catch (error: any) {
    logger.error(`Failed: ${error.message}`);

    if (error.response?.status === 404) {
      return res.status(404).json({ error: 'Not found' });
    }

    return res.status(500).json({ error: 'Failed' });
  }
});
```

**Logging Strategy**:
```typescript
logger.info(`Request received: ${param}`);
logger.info('Success', { data });
logger.error(`Failed: ${error.message}`, { error: error.stack });
```

**Configuration Approach**: Environment variables, check availability before use

---

### Operations

**Directory Structure**:
```
/extensions/operations/directus-extension-{kebab-case-name}/
├── package.json
├── tsconfig.json
├── README.md
├── src/
│   ├── index.ts
│   └── app.ts (optional)
└── dist/ (generated)
```

**File Naming Convention**:
- Package: `directapp-operation-{name}`
- Entry point: `index.ts`
- UI config: `app.ts`
- ID: `{kebab-case-name}`

**Export Structure** (index.ts):
```typescript
import { defineOperationApi } from '@directus/extensions-sdk';

interface Options {
  field1: string;
  field2?: string;
}

export default {
  id: 'operation-id',
  handler: defineOperationApi<Options>({
    id: 'operation-id',
    handler: async (options, { env, logger, accountability }) => {
      try {
        // Validate
        if (!options.field1) {
          throw new Error('Missing field1');
        }

        // Check env
        if (!env.API_KEY) {
          throw new Error('API_KEY not configured');
        }

        // Execute
        logger.info('Starting');
        const result = await operation();
        logger.info('Completed');

        return { success: true, data: result };

      } catch (error: any) {
        logger.error(`Failed: ${error.message}`);
        throw error;
      }
    },
  }),
};
```

**Type Imports**:
```typescript
import { defineOperationApi, defineOperationApp } from '@directus/extensions-sdk';
```

**Context Usage Patterns**:
```typescript
// Options
const { field1, field2 } = options;

// Environment
const apiKey = env.API_KEY;

// User context
const userId = accountability?.user;

// Return data
return { key: value, result: data };

// Throw to stop flow
throw new Error('Cannot continue');
```

**Error Handling Pattern**:
```typescript
handler: async (options, { env, logger, accountability }) => {
  try {
    // Validate options
    if (!options.required) {
      throw new Error('Missing required');
    }

    // Check environment
    if (!env.API_KEY) {
      throw new Error('Not configured');
    }

    // Execute
    logger.info('Starting', { options });
    const result = await operation();
    logger.info('Success', { result });

    return { success: true, result };

  } catch (error: any) {
    logger.error(`Failed: ${error.message}`, { error: error.stack });
    throw error;
  }
}
```

**Logging Strategy**:
```typescript
logger.info('Operation starting', { options });
logger.info('Operation completed', { result });
logger.error('Operation failed', { error: error.stack });
```

**Configuration Approach**: Options typed interface, environment variables for secrets

---

### Modules, Panels, Layouts, Displays, Bundles

**Patterns follow same structure as above with type-specific variations**:
- Directory: `/extensions/directus-extension-{name}/`
- Package: `directapp-{type}-{name}`
- Entry: `src/index.ts`
- Type imports from `@directus/extensions-sdk`
- TypeScript strict mode
- Comprehensive error handling
- Explicit logging
- Configuration via options or environment

---

## Validation Workflow

### Pre-Implementation Validation

1. **Check Pattern Catalog**: Review discovered patterns for extension type
2. **Read Documentation**: Directus docs + this specification
3. **Review Examples**: Study discovered examples in codebase
4. **Plan Structure**: Decide files, exports, types before coding
5. **Create Checklist**: Use extension-specific success criteria

### During-Implementation Validation

1. **Type Check Continuously**: Run `npm run type-check` frequently
2. **Build Often**: Run `npm run build` to catch build errors early
3. **Follow Patterns**: Reference pattern examples while coding
4. **Log Everything**: Add logging as you code, not after
5. **Handle Errors**: Add try-catch as you write async code
6. **Test Incrementally**: Test each feature as it's implemented

### Post-Implementation Validation

1. **Final Type Check**: `npm run type-check` must pass
2. **Final Build**: `npm run build` must succeed
3. **Deploy to Dev**: Test in development Directus instance
4. **Run Test Checklist**: Complete extension-specific success criteria
5. **Check Logs**: Verify all operations are logged correctly
6. **Test Error Scenarios**: Verify error handling works
7. **Performance Test**: Ensure acceptable performance (UI responsiveness, API latency)
8. **Documentation**: Update README with setup and usage
9. **Peer Review**: Code review by another developer
10. **Deploy to Staging**: Final testing before production

---

## Risk Assessment

### High Risk Extension Types

**Hooks (CRITICAL)**:
- **Why Risky**: Can block all CRUD operations if broken
- **Impact**: Data corruption, system unavailability, permission bypasses
- **Mitigation**: Extensive testing, separate filter/action concerns, comprehensive logging
- **Validation**: Test all CRUD operations, different user permissions, edge cases

**Interfaces (HIGH)**:
- **Why Risky**: Can prevent editing items, corrupt data if emit() incorrect
- **Impact**: Users unable to edit collection, incorrect data saved
- **Mitigation**: Type safety, proper emit(), config mode detection, thorough testing
- **Validation**: Test add field, save item, edit item, verify data in API

**Endpoints (HIGH)**:
- **Why Risky**: External API exposure, security vulnerabilities if not validated
- **Impact**: Data exposure, service disruption, security breaches
- **Mitigation**: Input validation, proper status codes, authentication checks
- **Validation**: Test all endpoints with valid/invalid/malicious input

**Operations (HIGH)**:
- **Why Risky**: Can break entire flow chain if broken
- **Impact**: Workflow automation failure, data processing errors
- **Mitigation**: Options validation, env checks, proper error throwing
- **Validation**: Test in flows with various inputs, verify output data

### Medium Risk Extension Types

**Modules (MEDIUM)**:
- **Why Risky**: Full-page UI, routing complexity, permission handling
- **Impact**: Navigation issues, permission bypasses, poor UX
- **Mitigation**: Permission checks, proper routing, error boundaries
- **Validation**: Test navigation, permissions, all routes

**Layouts (MEDIUM)**:
- **Why Risky**: Collection browsing, performance with large datasets, selection handling
- **Impact**: Unable to browse collections, poor performance, broken selection
- **Mitigation**: Efficient data loading, proper selection handling, pagination
- **Validation**: Test with large datasets, verify selection, sorting, filtering

**Bundles (MEDIUM)**:
- **Why Risky**: Multiple extensions, potential conflicts, complex dependencies
- **Impact**: Extension conflicts, deployment issues, hard to debug
- **Mitigation**: Test each extension independently, clear documentation
- **Validation**: Test all bundled extensions, verify no conflicts

### Low Risk Extension Types

**Panels (LOW)**:
- **Why Risky**: Dashboard widgets, isolated functionality
- **Impact**: Dashboard display issues, limited scope
- **Mitigation**: Error boundaries, loading states, graceful fallbacks
- **Validation**: Add to dashboard, test with various configurations

**Displays (LOW)**:
- **Why Risky**: Read-only field rendering, no data modification
- **Impact**: Display issues only, users can switch displays
- **Mitigation**: Handle all value types, performance optimization
- **Validation**: Test with various value types, verify in table layout

---

## Success Metrics

### How to Measure "Foolproof Implementation"

#### 1. Zero-Error Deployment
- **Metric**: Extension loads without errors on first deployment
- **Measurement**: Check Directus startup logs, no error messages
- **Target**: 100% success rate
- **Validation**: `docker-compose logs directus | grep -i error`

#### 2. Type Safety
- **Metric**: TypeScript compiles without errors or warnings
- **Measurement**: `npm run type-check` exit code
- **Target**: 0 errors, 0 warnings
- **Validation**: Run in CI pipeline

#### 3. Functionality Completeness
- **Metric**: All features in success criteria work as expected
- **Measurement**: Manual testing checklist completion
- **Target**: 100% checklist items passing
- **Validation**: Documented test results

#### 4. Error Handling Coverage
- **Metric**: All async operations have try-catch, all errors logged
- **Measurement**: Code review + error scenario testing
- **Target**: 100% async operations protected
- **Validation**: `grep -r "async function" src/ | wc -l` vs try-catch count

#### 5. Logging Completeness
- **Metric**: All significant operations are logged
- **Measurement**: Review logs during operation
- **Target**: All operations visible in logs
- **Validation**: Execute operations, verify log entries

#### 6. Documentation Quality
- **Metric**: README has setup, usage, configuration, troubleshooting
- **Measurement**: New developer can set up from README alone
- **Target**: 100% setup success without assistance
- **Validation**: Onboarding test with new developer

#### 7. Performance Acceptance
- **Metric**: UI interactions responsive (<100ms), API calls reasonable (<2s)
- **Measurement**: Browser DevTools Performance tab, API timing
- **Target**: 95th percentile within limits
- **Validation**: Performance testing with realistic data

#### 8. Pattern Compliance
- **Metric**: All required patterns followed, no anti-patterns detected
- **Measurement**: Code review against compliance matrix
- **Target**: 100% compliance
- **Validation**: Peer review with checklist

#### 9. Integration Success
- **Metric**: Extension works with all Directus features (permissions, relations, etc)
- **Measurement**: Test with different users, permissions, configurations
- **Target**: Works in all standard scenarios
- **Validation**: Comprehensive integration testing

#### 10. Maintenance Readiness
- **Metric**: Another developer can understand and modify code
- **Measurement**: Code review feedback, time to first contribution
- **Target**: New developer productive in <2 hours
- **Validation**: Pair programming session with new developer

---

## Appendix: Quick Reference

### Extension Type Decision Tree

```
Need custom UI for data entry? → Interface
Need to validate/react to data changes? → Hook
Need custom API endpoint? → Endpoint
Need flow automation action? → Operation
Need full-page admin interface? → Module
Need dashboard widget? → Panel
Need custom collection browse view? → Layout
Need custom field display? → Display
Need to package multiple extensions? → Bundle
```

### Common Commands

```bash
# Create extension (from Directus root)
npx create-directus-extension@latest

# Development
cd extensions/directus-extension-{name}
npm install
npm run type-check
npm run dev

# Production build
npm run build

# Deploy (with volume mount)
docker-compose restart directus

# Check logs
docker-compose logs -f directus | grep extension
```

### Required Environment Variables by Extension Type

**Endpoints**:
- API integration: `API_NAME_TOKEN`, `API_NAME_URL`

**Operations**:
- External services: `SERVICE_API_KEY`, `SERVICE_URL`
- Email: `EMAIL_FROM`, `RESEND_API_KEY`

**Hooks**: Usually none (use database for config)

**Interfaces**: None (configuration via options)

### TypeScript Troubleshooting

**Common Errors**:

1. **Cannot find module '@directus/extensions-sdk'**
   - Solution: `npm install @directus/extensions-sdk@^16.0.2 --save-dev`

2. **Cannot find name 'defineInterface'**
   - Solution: Add import: `import { defineInterface } from '@directus/extensions-sdk';`

3. **Property 'values' does not exist on type 'Props'**
   - Solution: Add to Props interface: `values: Record<string, any>;`

4. **Cannot find module './interface.vue'**
   - Solution: Add vue type declaration or ensure file exists

5. **Type 'any' is not assignable to type 'string'**
   - Solution: Add explicit type guards or type assertions

### Extension Development Checklist

Pre-Development:
- [ ] Extension type decided
- [ ] Pattern reviewed (discovered or fallback)
- [ ] Structure planned
- [ ] Types defined

During Development:
- [ ] TypeScript strict mode enabled
- [ ] All async operations have try-catch
- [ ] All operations logged
- [ ] Input validated
- [ ] Environment variables checked
- [ ] Error messages are clear
- [ ] Loading states implemented (UI)
- [ ] Configuration documented

Pre-Deployment:
- [ ] `npm run type-check` passes
- [ ] `npm run build` succeeds
- [ ] README complete
- [ ] Test checklist completed
- [ ] Error scenarios tested
- [ ] Logs verified
- [ ] Performance acceptable
- [ ] Code reviewed

Post-Deployment:
- [ ] Extension loads without errors
- [ ] Functionality works in production
- [ ] Monitoring configured
- [ ] Documentation updated

---

**END OF SPECIFICATION**

This document provides zero-ambiguity requirements for implementing all 9 Directus extension types. All patterns are extracted from the codebase or official documentation. All decisions are pre-made. Follow this specification to ensure foolproof implementation.
