# Directus Schema Builder - Module Extension

**Visual schema builder for Directus with comprehensive field access control, relations, and grouping**

## Features

- 📐 **Visual Schema Design** - Build collections and fields with an intuitive drag-and-drop interface
- 🔒 **Field-Level Access Control** - Configure permissions at the field level for granular security
- 🔗 **Relation Management** - Define O2M, M2O, M2M, and M2A relations visually
- 📁 **Field Grouping** - Organize fields into logical groups for better UX
- ✅ **Real-time Validation** - Validate schemas against Directus standards before applying
- 📤 **Export/Import** - Export schemas as JSON, YAML, or SQL migrations
- 🎯 **Interface Configuration** - Configure all Directus interfaces with their options
- 🛡️ **Security Checks** - Built-in validation for security best practices

## Installation

1. Copy this extension to your Directus extensions directory:
   ```bash
   cp -r directus-extension-schema-builder /path/to/directus/extensions/
   ```

2. Install dependencies:
   ```bash
   cd /path/to/directus/extensions/directus-extension-schema-builder
   npm install
   ```

3. Build the extension:
   ```bash
   npm run build
   ```

4. Restart Directus:
   ```bash
   docker-compose restart directus
   # or
   pm2 restart directus
   ```

5. The Schema Builder will appear in your Directus navigation menu with an "Architecture" icon.

## Requirements

- **Directus**: v11.12.0 or higher
- **Node.js**: v18 or higher
- **Admin Access**: Required to apply schemas

## Usage

### Creating a New Collection

1. Open **Schema Builder** from the navigation menu
2. Click **"New Collection"** button
3. Enter collection name (lowercase, underscores only)
4. Configure collection settings:
   - Display name
   - Icon
   - Singleton mode
   - Accountability settings
5. Click **"Create"**

### Adding Fields

1. Select a collection from the navigation
2. Go to the **"Fields"** tab
3. Click **"Add Field"**
4. Configure field properties:
   - **Basic Information**: Field name, type, interface
   - **Schema Configuration**: Primary key, unique, nullable, constraints
   - **Display Options**: Required, readonly, hidden, width, sort order
   - **Interface Options**: Specific options for the selected interface
   - **Validation Rules**: Min/max length, regex patterns, custom rules
   - **Foreign Keys**: For relation fields
5. Click **"Add Field"**

### Configuring Relations

Relations are automatically created based on foreign key field configuration. For Many-to-Many relations:

1. Go to the **"Relations"** tab
2. Click **"Add Relation"**
3. Configure relation type and settings
4. Click **"Create"**

### Organizing with Field Groups

1. Go to the **"Groups"** tab
2. Click **"Add Group"**
3. Enter group name and configure:
   - Header icon
   - Header color
   - Default state (open/closed)
4. Assign fields to the group in the field editor

### Validation

Before applying a schema:

1. Click the **"Validate Schema"** button (check icon)
2. Review any errors or warnings
3. Fix issues before applying

### Exporting Schemas

1. Click the **"Export Schema"** button (download icon)
2. Configure export options:
   - Include permissions
   - Include relations
   - Include system fields
   - Format (JSON, YAML, SQL)
3. Click **"Generate"**
4. Download or copy the generated schema

### Importing Schemas

1. Click the **"Import Schema"** button (upload icon)
2. Paste your schema JSON
3. Click **"Import"**
4. Review and validate the imported schema

### Applying Schemas

1. Validate your schema first
2. Click the **"Apply Schema"** button (publish icon)
3. Confirm the operation
4. The schema will be applied to your Directus instance

## Field Types

The schema builder supports all Directus field types:

- **Text**: `string`, `text`
- **Numbers**: `integer`, `bigInteger`, `float`, `decimal`
- **Dates**: `date`, `time`, `dateTime`, `timestamp`
- **Other**: `boolean`, `json`, `csv`, `uuid`, `hash`, `binary`, `alias`

## Interface Configuration

Configure interface-specific options for:

- **Input**: Placeholder, icons, trimming, masking
- **Select Dropdown**: Choices, allow other values
- **Rich Text**: Toolbar configuration, image upload
- **Slider**: Min/max values, step interval
- **Date/Time**: Format, 24-hour mode, min/max
- **Tags**: Presets, lowercase, alphabetize
- **File/Image**: Default folder, cropping
- **And more...**

## Validation Rules

Define validation rules using Directus filter syntax:

### Quick Presets

- **Email**: RFC-compliant email validation
- **URL**: HTTP/HTTPS URL validation
- **Phone**: International phone number format
- **Min/Max Length**: String length constraints
- **Numeric Range**: Min/max value constraints

### Custom Rules

Use any Directus filter operator:

- `_eq`, `_neq`: Equality checks
- `_lt`, `_lte`, `_gt`, `_gte`: Numeric comparisons
- `_contains`, `_starts_with`, `_ends_with`: String matching
- `_regex`: Regular expression matching
- `_in`, `_nin`: Array membership
- `_null`, `_nnull`, `_empty`, `_nempty`: Null/empty checks

### Example Validation

```json
{
  "_regex": "^[A-Z]{2,3}[0-9]{4,6}$",
  "_gte": 1000,
  "_lte": 999999
}
```

## Security Features

### Built-in Security Checks

- ✅ Reserved collection/field name detection
- ✅ Duplicate field name prevention
- ✅ Primary key validation
- ✅ Foreign key integrity checks
- ✅ Unique constraint validation
- ✅ Nullable/required field consistency
- ✅ Archive field existence validation
- ✅ Sort field existence validation

### Best Practices Enforced

- Collection names: lowercase, underscores, start with letter
- Field names: same rules as collections
- One primary key per collection
- Proper foreign key configuration
- Accountability tracking enabled by default

## Architecture

### Frontend (Vue 3 Module)

- `module.vue`: Main module component
- `NavigationCollections.vue`: Collection navigation sidebar
- `CollectionEditor.vue`: Collection editing interface
- `FieldForm.vue`: Field configuration form
- `InterfaceOptionsForm.vue`: Interface-specific options
- `ValidationRulesForm.vue`: Validation rule builder

### Backend (Endpoint API)

Works in conjunction with the `directus-extension-schema-builder-api` endpoint extension.

See: [Schema Builder API Documentation](../directus-extension-schema-builder-api/README.md)

## API Integration

The module uses the following API endpoints:

- `POST /schema-builder/validate` - Validate schema
- `POST /schema-builder/generate` - Generate export
- `POST /schema-builder/apply` - Apply schema to Directus
- `GET /schema-builder/export` - Export existing schema
- `POST /schema-builder/projects` - Save schema project
- `GET /schema-builder/projects` - Load schema projects

## Development

### Prerequisites

- Node.js v18+
- TypeScript 5.3+
- Vue 3.4+
- Directus Extensions SDK 16.0+

### Setup

```bash
# Install dependencies
npm install

# Development mode (watch)
npm run dev

# Type checking
npm run type-check

# Build for production
npm run build

# Clean build artifacts
npm run clean
```

### Project Structure

```
directus-extension-schema-builder/
├── src/
│   ├── index.ts                      # Module definition
│   ├── module.vue                    # Main module component
│   ├── types/
│   │   └── schema.ts                 # TypeScript type definitions
│   └── components/
│       ├── NavigationCollections.vue
│       ├── CollectionEditor.vue
│       ├── FieldForm.vue
│       ├── InterfaceOptionsForm.vue
│       └── ValidationRulesForm.vue
├── package.json
├── tsconfig.json
└── README.md
```

## TypeScript Types

All schema structures are fully typed. See `src/types/schema.ts` for:

- `SchemaBuilderProject`
- `CollectionSchema`
- `FieldSchema`
- `RelationSchema`
- `PermissionRule`
- And more...

## Troubleshooting

### Extension Not Appearing

1. Check Directus logs for extension loading errors:
   ```bash
   docker-compose logs -f directus | grep extension
   ```

2. Verify build was successful:
   ```bash
   ls -la dist/
   ```

3. Ensure permissions are correct:
   ```bash
   chmod -R 755 .
   ```

### Type Errors

Run type checking to identify issues:
```bash
npm run type-check
```

### Validation Errors

- Ensure collection names are lowercase with underscores only
- Check that all required fields have values
- Verify foreign key references exist
- Confirm no duplicate field names

### Apply Schema Fails

- Validate schema first
- Ensure you have admin permissions
- Check Directus logs for detailed errors
- Verify database connectivity

## Contributing

1. Follow the Directus extension development guidelines
2. Use TypeScript strict mode
3. Add comprehensive error handling
4. Include validation for all user inputs
5. Test with various field types and configurations

## License

Same as the main Directus project (Business Source License 1.1)

## Support

For issues and questions:

1. Check this README
2. Review [Directus Extension Documentation](https://docs.directus.io/extensions/)
3. Check Directus logs for errors
4. Create an issue in the project repository

## Credits

Built for DirectApp - Car Dealership Management System

Developed following Directus Extension Implementation Requirements specification.
