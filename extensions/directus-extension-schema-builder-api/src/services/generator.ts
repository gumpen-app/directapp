/**
 * Schema Generator Service
 * Generates schema export formats (JSON, YAML, SQL)
 */

interface GenerateOptions {
  includePermissions?: boolean;
  includeRelations?: boolean;
  includeSystemFields?: boolean;
  format?: 'json' | 'yaml' | 'sql';
}

interface GenerateContext {
  services: any;
  schema: any;
  accountability: any;
}

export async function generateSchema(
  schema: any,
  options: GenerateOptions,
  context: GenerateContext
): Promise<any> {
  const {
    includePermissions = true,
    includeRelations = true,
    includeSystemFields = false,
    format = 'json',
  } = options;

  // Clone schema to avoid mutations
  const output: any = {
    version: 1,
    directus: '11.12.0',
    collections: [],
  };

  // Process collections
  for (const collection of schema.collections) {
    const collectionOutput: any = {
      collection: collection.collection,
      meta: collection.meta,
      fields: [],
    };

    if (collection.schema) {
      collectionOutput.schema = collection.schema;
    }

    // Process fields
    for (const field of collection.fields) {
      // Skip system fields if not included
      if (!includeSystemFields && isSystemField(field.field)) {
        continue;
      }

      const fieldOutput: any = {
        field: field.field,
        type: field.type,
        meta: field.meta,
      };

      if (field.schema) {
        fieldOutput.schema = field.schema;
      }

      collectionOutput.fields.push(fieldOutput);
    }

    output.collections.push(collectionOutput);
  }

  // Include relations
  if (includeRelations && schema.relations) {
    output.relations = schema.relations;
  }

  // Include permissions
  if (includePermissions && schema.permissions) {
    output.permissions = schema.permissions;
  }

  // Format output
  if (format === 'json') {
    return {
      format: 'json',
      content: JSON.stringify(output, null, 2),
      filename: `schema-${Date.now()}.json`,
    };
  }

  if (format === 'yaml') {
    return {
      format: 'yaml',
      content: convertToYAML(output),
      filename: `schema-${Date.now()}.yaml`,
    };
  }

  if (format === 'sql') {
    return {
      format: 'sql',
      content: await generateSQL(output, context),
      filename: `schema-${Date.now()}.sql`,
    };
  }

  return output;
}

function isSystemField(fieldName: string): boolean {
  const systemFields = [
    'id',
    'status',
    'sort',
    'user_created',
    'date_created',
    'user_updated',
    'date_updated',
  ];
  return systemFields.includes(fieldName);
}

function convertToYAML(obj: any, indent = 0): string {
  const spaces = '  '.repeat(indent);
  let yaml = '';

  if (Array.isArray(obj)) {
    for (const item of obj) {
      if (typeof item === 'object' && item !== null) {
        yaml += `${spaces}-\n${convertToYAML(item, indent + 1)}`;
      } else {
        yaml += `${spaces}- ${item}\n`;
      }
    }
  } else if (typeof obj === 'object' && obj !== null) {
    for (const [key, value] of Object.entries(obj)) {
      if (Array.isArray(value)) {
        yaml += `${spaces}${key}:\n${convertToYAML(value, indent + 1)}`;
      } else if (typeof value === 'object' && value !== null) {
        yaml += `${spaces}${key}:\n${convertToYAML(value, indent + 1)}`;
      } else {
        const stringValue = typeof value === 'string' ? `"${value}"` : value;
        yaml += `${spaces}${key}: ${stringValue}\n`;
      }
    }
  } else {
    yaml += `${spaces}${obj}\n`;
  }

  return yaml;
}

async function generateSQL(schema: any, context: GenerateContext): Promise<string> {
  let sql = `-- Directus Schema Migration
-- Generated: ${new Date().toISOString()}
-- WARNING: Review this SQL before execution

`;

  // Generate CREATE TABLE statements
  for (const collection of schema.collections) {
    sql += `-- Collection: ${collection.collection}\n`;
    sql += `CREATE TABLE IF NOT EXISTS "${collection.collection}" (\n`;

    const columns: string[] = [];

    for (const field of collection.fields) {
      let columnDef = `  "${field.field}" ${mapTypeToSQL(field.type)}`;

      // Add constraints
      if (field.schema?.is_primary_key) {
        columnDef += ' PRIMARY KEY';
      }

      if (field.schema?.has_auto_increment) {
        columnDef += ' AUTO_INCREMENT';
      }

      if (field.schema?.is_nullable === false) {
        columnDef += ' NOT NULL';
      }

      if (field.schema?.is_unique) {
        columnDef += ' UNIQUE';
      }

      if (field.schema?.default_value !== undefined && field.schema?.default_value !== null) {
        columnDef += ` DEFAULT ${formatDefaultValue(field.schema.default_value, field.type)}`;
      }

      if (field.schema?.comment) {
        columnDef += ` COMMENT '${field.schema.comment.replace(/'/g, "''")}'`;
      }

      columns.push(columnDef);
    }

    sql += columns.join(',\n');
    sql += '\n);\n\n';

    // Add indexes for unique and foreign key fields
    for (const field of collection.fields) {
      if (field.schema?.is_unique && !field.schema?.is_primary_key) {
        sql += `CREATE UNIQUE INDEX "idx_${collection.collection}_${field.field}" ON "${collection.collection}" ("${field.field}");\n`;
      }

      if (field.schema?.foreign_key_table) {
        sql += `CREATE INDEX "idx_${collection.collection}_${field.field}_fk" ON "${collection.collection}" ("${field.field}");\n`;
      }
    }

    sql += '\n';
  }

  // Generate foreign key constraints
  for (const collection of schema.collections) {
    for (const field of collection.fields) {
      if (field.schema?.foreign_key_table && field.schema?.foreign_key_column) {
        sql += `ALTER TABLE "${collection.collection}"
  ADD CONSTRAINT "fk_${collection.collection}_${field.field}"
  FOREIGN KEY ("${field.field}")
  REFERENCES "${field.schema.foreign_key_table}" ("${field.schema.foreign_key_column}")
  ON UPDATE ${field.schema.on_update || 'NO ACTION'}
  ON DELETE ${field.schema.on_delete || 'NO ACTION'};\n\n`;
      }
    }
  }

  sql += '-- End of migration\n';

  return sql;
}

function mapTypeToSQL(type: string): string {
  const typeMap: Record<string, string> = {
    string: 'VARCHAR(255)',
    text: 'TEXT',
    integer: 'INTEGER',
    bigInteger: 'BIGINT',
    float: 'FLOAT',
    decimal: 'DECIMAL(10,2)',
    boolean: 'BOOLEAN',
    date: 'DATE',
    time: 'TIME',
    dateTime: 'DATETIME',
    timestamp: 'TIMESTAMP',
    json: 'JSON',
    uuid: 'UUID',
    hash: 'VARCHAR(255)',
    csv: 'TEXT',
    binary: 'BLOB',
  };

  return typeMap[type] || 'VARCHAR(255)';
}

function formatDefaultValue(value: any, type: string): string {
  if (value === null) return 'NULL';

  if (type === 'boolean') {
    return value ? 'TRUE' : 'FALSE';
  }

  if (type === 'integer' || type === 'bigInteger' || type === 'float' || type === 'decimal') {
    return String(value);
  }

  if (type === 'json') {
    return `'${JSON.stringify(value).replace(/'/g, "''")}'`;
  }

  // String types
  return `'${String(value).replace(/'/g, "''")}'`;
}
