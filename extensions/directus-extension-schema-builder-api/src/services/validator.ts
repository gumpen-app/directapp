/**
 * Schema Validator Service
 * Validates schema configurations for security and correctness
 */

interface ValidationContext {
  services: any;
  schema: any;
  accountability: any;
}

interface ValidationResult {
  valid: boolean;
  errors: ValidationError[];
  warnings: ValidationWarning[];
}

interface ValidationError {
  type: 'error';
  collection: string;
  field?: string;
  message: string;
  code: string;
}

interface ValidationWarning {
  type: 'warning';
  collection: string;
  field?: string;
  message: string;
  code: string;
}

const RESERVED_NAMES = [
  'directus_activity',
  'directus_collections',
  'directus_fields',
  'directus_files',
  'directus_folders',
  'directus_migrations',
  'directus_permissions',
  'directus_presets',
  'directus_relations',
  'directus_revisions',
  'directus_roles',
  'directus_sessions',
  'directus_settings',
  'directus_users',
  'directus_webhooks',
  'directus_flows',
  'directus_operations',
  'directus_panels',
  'directus_notifications',
  'directus_shares',
  'directus_dashboards',
];

const RESERVED_FIELD_NAMES = ['id', 'sort', 'status', 'user_created', 'date_created', 'user_updated', 'date_updated'];

export async function validateSchema(schema: any, context: ValidationContext): Promise<ValidationResult> {
  const errors: ValidationError[] = [];
  const warnings: ValidationWarning[] = [];

  if (!schema.collections || !Array.isArray(schema.collections)) {
    errors.push({
      type: 'error',
      collection: '',
      message: 'Schema must include a collections array',
      code: 'MISSING_COLLECTIONS',
    });
    return { valid: false, errors, warnings };
  }

  for (const collection of schema.collections) {
    // Validate collection name
    if (!collection.collection || typeof collection.collection !== 'string') {
      errors.push({
        type: 'error',
        collection: collection.collection || 'unknown',
        message: 'Collection must have a valid name',
        code: 'INVALID_COLLECTION_NAME',
      });
      continue;
    }

    // Check for reserved names
    if (RESERVED_NAMES.includes(collection.collection)) {
      errors.push({
        type: 'error',
        collection: collection.collection,
        message: `Collection name "${collection.collection}" is reserved for system use`,
        code: 'RESERVED_COLLECTION_NAME',
      });
    }

    // Validate collection name format (lowercase, underscores only)
    if (!/^[a-z][a-z0-9_]*$/.test(collection.collection)) {
      errors.push({
        type: 'error',
        collection: collection.collection,
        message: 'Collection name must start with a letter and contain only lowercase letters, numbers, and underscores',
        code: 'INVALID_NAME_FORMAT',
      });
    }

    // Check if collection already exists
    try {
      const { CollectionsService } = context.services;
      const collectionsService = new CollectionsService({
        schema: context.schema,
        accountability: context.accountability,
      });

      const existingCollections = await collectionsService.readByQuery({});
      const exists = existingCollections.some((c: any) => c.collection === collection.collection);

      if (exists) {
        warnings.push({
          type: 'warning',
          collection: collection.collection,
          message: 'Collection already exists and will be updated',
          code: 'COLLECTION_EXISTS',
        });
      }
    } catch (error) {
      // Ignore errors checking existing collections
    }

    // Validate fields
    if (!collection.fields || !Array.isArray(collection.fields) || collection.fields.length === 0) {
      errors.push({
        type: 'error',
        collection: collection.collection,
        message: 'Collection must have at least one field',
        code: 'MISSING_FIELDS',
      });
      continue;
    }

    const fieldNames = new Set<string>();
    let hasPrimaryKey = false;

    for (const field of collection.fields) {
      // Validate field name
      if (!field.field || typeof field.field !== 'string') {
        errors.push({
          type: 'error',
          collection: collection.collection,
          field: field.field || 'unknown',
          message: 'Field must have a valid name',
          code: 'INVALID_FIELD_NAME',
        });
        continue;
      }

      // Check for duplicate field names
      if (fieldNames.has(field.field)) {
        errors.push({
          type: 'error',
          collection: collection.collection,
          field: field.field,
          message: 'Duplicate field name',
          code: 'DUPLICATE_FIELD',
        });
      }
      fieldNames.add(field.field);

      // Validate field name format
      if (!/^[a-z][a-z0-9_]*$/.test(field.field)) {
        errors.push({
          type: 'error',
          collection: collection.collection,
          field: field.field,
          message: 'Field name must start with a letter and contain only lowercase letters, numbers, and underscores',
          code: 'INVALID_FIELD_NAME_FORMAT',
        });
      }

      // Check for primary key
      if (field.schema?.is_primary_key) {
        if (hasPrimaryKey) {
          errors.push({
            type: 'error',
            collection: collection.collection,
            field: field.field,
            message: 'Collection can only have one primary key',
            code: 'MULTIPLE_PRIMARY_KEYS',
          });
        }
        hasPrimaryKey = true;
      }

      // Validate field type
      if (!field.type) {
        errors.push({
          type: 'error',
          collection: collection.collection,
          field: field.field,
          message: 'Field must have a type',
          code: 'MISSING_FIELD_TYPE',
        });
      }

      // Validate required fields have proper configuration
      if (field.meta?.required && field.schema?.is_nullable !== false) {
        warnings.push({
          type: 'warning',
          collection: collection.collection,
          field: field.field,
          message: 'Required field should have is_nullable set to false in schema',
          code: 'REQUIRED_FIELD_NULLABLE',
        });
      }

      // Validate unique fields
      if (field.schema?.is_unique && field.field !== 'id') {
        // Recommend adding index for unique fields
        warnings.push({
          type: 'warning',
          collection: collection.collection,
          field: field.field,
          message: 'Unique constraint detected - ensure database index is created for performance',
          code: 'UNIQUE_FIELD_INDEX',
        });
      }

      // Validate foreign keys
      if (field.schema?.foreign_key_table) {
        if (!field.schema.foreign_key_column) {
          errors.push({
            type: 'error',
            collection: collection.collection,
            field: field.field,
            message: 'Foreign key must specify both table and column',
            code: 'INCOMPLETE_FOREIGN_KEY',
          });
        }

        // Check if foreign key table exists in schema
        const foreignTableExists = schema.collections.some(
          (c: any) => c.collection === field.schema.foreign_key_table
        );

        if (!foreignTableExists) {
          warnings.push({
            type: 'warning',
            collection: collection.collection,
            field: field.field,
            message: `Foreign key references table "${field.schema.foreign_key_table}" which is not in this schema`,
            code: 'FOREIGN_TABLE_NOT_IN_SCHEMA',
          });
        }
      }

      // Validate interface configuration
      if (field.meta?.interface) {
        const interfaceName = field.meta.interface;

        // Check for common misconfigurations
        if (interfaceName === 'input' && field.type === 'text') {
          warnings.push({
            type: 'warning',
            collection: collection.collection,
            field: field.field,
            message: 'Consider using "input-multiline" interface for text fields',
            code: 'INTERFACE_SUGGESTION',
          });
        }

        if (interfaceName === 'select-dropdown' && !field.meta.options?.choices) {
          errors.push({
            type: 'error',
            collection: collection.collection,
            field: field.field,
            message: 'select-dropdown interface requires choices option',
            code: 'MISSING_INTERFACE_OPTIONS',
          });
        }
      }
    }

    // Ensure collection has a primary key
    if (!hasPrimaryKey) {
      warnings.push({
        type: 'warning',
        collection: collection.collection,
        message: 'Collection does not have a primary key field',
        code: 'MISSING_PRIMARY_KEY',
      });
    }

    // Validate collection meta
    if (collection.meta) {
      // Check for accountability settings
      if (collection.meta.accountability === null) {
        warnings.push({
          type: 'warning',
          collection: collection.collection,
          message: 'Collection has accountability disabled - changes will not be tracked',
          code: 'ACCOUNTABILITY_DISABLED',
        });
      }

      // Validate archive configuration
      if (collection.meta.archive_field) {
        const archiveFieldExists = collection.fields.some(
          (f: any) => f.field === collection.meta.archive_field
        );

        if (!archiveFieldExists) {
          errors.push({
            type: 'error',
            collection: collection.collection,
            message: `Archive field "${collection.meta.archive_field}" does not exist`,
            code: 'MISSING_ARCHIVE_FIELD',
          });
        }
      }

      // Validate sort field
      if (collection.meta.sort_field) {
        const sortFieldExists = collection.fields.some(
          (f: any) => f.field === collection.meta.sort_field
        );

        if (!sortFieldExists) {
          errors.push({
            type: 'error',
            collection: collection.collection,
            message: `Sort field "${collection.meta.sort_field}" does not exist`,
            code: 'MISSING_SORT_FIELD',
          });
        }
      }
    }
  }

  // Validate relations
  if (schema.relations && Array.isArray(schema.relations)) {
    for (const relation of schema.relations) {
      // Validate relation fields exist
      const manyCollectionExists = schema.collections.some(
        (c: any) => c.collection === relation.meta?.many_collection
      );

      if (!manyCollectionExists) {
        errors.push({
          type: 'error',
          collection: relation.meta?.many_collection || 'unknown',
          message: `Relation references non-existent collection "${relation.meta?.many_collection}"`,
          code: 'RELATION_INVALID_COLLECTION',
        });
      }

      if (relation.meta?.one_collection) {
        const oneCollectionExists = schema.collections.some(
          (c: any) => c.collection === relation.meta.one_collection
        );

        if (!oneCollectionExists) {
          errors.push({
            type: 'error',
            collection: relation.meta.one_collection,
            message: `Relation references non-existent collection "${relation.meta.one_collection}"`,
            code: 'RELATION_INVALID_COLLECTION',
          });
        }
      }
    }
  }

  // Validate permissions
  if (schema.permissions && Array.isArray(schema.permissions)) {
    for (const permission of schema.permissions) {
      // Ensure permission references valid collection
      const collectionExists = schema.collections.some(
        (c: any) => c.collection === permission.collection
      );

      if (!collectionExists) {
        warnings.push({
          type: 'warning',
          collection: permission.collection,
          message: `Permission references collection "${permission.collection}" which is not in this schema`,
          code: 'PERMISSION_UNKNOWN_COLLECTION',
        });
      }

      // Validate permission fields exist
      if (permission.fields && Array.isArray(permission.fields)) {
        const collection = schema.collections.find(
          (c: any) => c.collection === permission.collection
        );

        if (collection) {
          for (const fieldName of permission.fields) {
            const fieldExists = collection.fields.some(
              (f: any) => f.field === fieldName
            );

            if (!fieldExists && fieldName !== '*') {
              warnings.push({
                type: 'warning',
                collection: permission.collection,
                field: fieldName,
                message: `Permission references non-existent field "${fieldName}"`,
                code: 'PERMISSION_UNKNOWN_FIELD',
              });
            }
          }
        }
      }
    }
  }

  const valid = errors.length === 0;

  return {
    valid,
    errors,
    warnings,
  };
}
