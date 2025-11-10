/**
 * Schema Builder Type Definitions
 * Comprehensive types for building Directus schemas with field access control
 */

export interface SchemaBuilderProject {
  id?: string;
  name: string;
  description?: string;
  collections: CollectionSchema[];
  created_at?: string;
  updated_at?: string;
  user_created?: string;
}

export interface CollectionSchema {
  collection: string;
  meta: CollectionMeta;
  schema?: CollectionSchemaDefinition;
  fields: FieldSchema[];
}

export interface CollectionMeta {
  collection: string;
  icon?: string;
  note?: string;
  display_template?: string;
  hidden: boolean;
  singleton: boolean;
  translations?: CollectionTranslation[];
  archive_field?: string;
  archive_app_filter: boolean;
  archive_value?: string;
  unarchive_value?: string;
  sort_field?: string;
  accountability?: 'all' | 'activity' | null;
  color?: string;
  item_duplication_fields?: string[];
  sort?: number;
  group?: string;
  collapse: 'open' | 'closed' | 'locked';
  preview_url?: string;
  versioning: boolean;
}

export interface CollectionSchemaDefinition {
  name: string;
  comment?: string;
}

export interface CollectionTranslation {
  language: string;
  translation: string;
  singular: string;
  plural: string;
}

export interface FieldSchema {
  field: string;
  type: FieldType;
  schema?: FieldSchemaDefinition;
  meta: FieldMeta;
}

export interface FieldSchemaDefinition {
  name?: string;
  table?: string;
  data_type?: string;
  default_value?: any;
  max_length?: number | null;
  numeric_precision?: number | null;
  numeric_scale?: number | null;
  is_nullable?: boolean;
  is_unique?: boolean;
  is_primary_key?: boolean;
  is_generated?: boolean;
  generation_expression?: string | null;
  has_auto_increment?: boolean;
  foreign_key_table?: string | null;
  foreign_key_column?: string | null;
  comment?: string | null;
}

export interface FieldMeta {
  id?: number;
  collection: string;
  field: string;
  special?: string[] | null;
  interface?: string | null;
  options?: Record<string, any> | null;
  display?: string | null;
  display_options?: Record<string, any> | null;
  readonly: boolean;
  hidden: boolean;
  sort?: number | null;
  width?: 'half' | 'half-left' | 'half-right' | 'full' | 'fill' | null;
  translations?: FieldTranslation[] | null;
  note?: string | null;
  conditions?: FieldCondition[] | null;
  required?: boolean;
  group?: string | null;
  validation?: FieldValidation | null;
  validation_message?: string | null;
}

export interface FieldTranslation {
  language: string;
  translation: string;
}

export interface FieldCondition {
  name: string;
  rule: Record<string, any>;
  readonly?: boolean;
  hidden?: boolean;
  options?: Record<string, any>;
}

export interface FieldValidation {
  _and?: FieldValidation[];
  _or?: FieldValidation[];
  [key: string]: any;
}

export interface RelationSchema {
  collection: string;
  field: string;
  related_collection?: string;
  meta?: RelationMeta;
  schema?: RelationSchemaDefinition;
}

export interface RelationMeta {
  id?: number;
  many_collection: string;
  many_field: string;
  one_collection?: string;
  one_field?: string;
  one_collection_field?: string;
  one_allowed_collections?: string[];
  junction_field?: string;
  sort_field?: string;
  one_deselect_action: 'nullify' | 'delete';
}

export interface RelationSchemaDefinition {
  constraint_name?: string;
  table: string;
  column: string;
  foreign_key_table: string;
  foreign_key_column: string;
  on_update: 'NO ACTION' | 'CASCADE' | 'SET NULL' | 'SET DEFAULT' | 'RESTRICT';
  on_delete: 'NO ACTION' | 'CASCADE' | 'SET NULL' | 'SET DEFAULT' | 'RESTRICT';
}

export type RelationType = 'o2m' | 'm2o' | 'm2m' | 'm2a';

export interface PermissionRule {
  collection: string;
  role?: string;
  action: 'create' | 'read' | 'update' | 'delete';
  permissions?: Record<string, any> | null;
  validation?: Record<string, any> | null;
  presets?: Record<string, any> | null;
  fields?: string[] | null;
}

export type FieldType =
  | 'alias'
  | 'bigInteger'
  | 'binary'
  | 'boolean'
  | 'csv'
  | 'date'
  | 'dateTime'
  | 'decimal'
  | 'float'
  | 'geometry'
  | 'geometry.Point'
  | 'geometry.LineString'
  | 'geometry.Polygon'
  | 'geometry.MultiPoint'
  | 'geometry.MultiLineString'
  | 'geometry.MultiPolygon'
  | 'hash'
  | 'integer'
  | 'json'
  | 'string'
  | 'text'
  | 'time'
  | 'timestamp'
  | 'uuid';

export interface FieldGroup {
  field: string;
  name: string;
  meta: {
    interface: 'group-detail' | 'group-raw';
    special: ['group'];
    options?: {
      headerIcon?: string;
      headerColor?: string;
      start?: 'open' | 'closed';
    };
  };
}

export interface SchemaValidationResult {
  valid: boolean;
  errors: SchemaValidationError[];
  warnings: SchemaValidationWarning[];
}

export interface SchemaValidationError {
  type: 'error';
  collection: string;
  field?: string;
  message: string;
  code: string;
}

export interface SchemaValidationWarning {
  type: 'warning';
  collection: string;
  field?: string;
  message: string;
  code: string;
}

export interface SchemaExportOptions {
  includePermissions: boolean;
  includeRelations: boolean;
  includeSystemFields: boolean;
  format: 'json' | 'yaml';
}

export interface SchemaImportResult {
  success: boolean;
  collections_created: number;
  fields_created: number;
  relations_created: number;
  permissions_created: number;
  errors: string[];
}
