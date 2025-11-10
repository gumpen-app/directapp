/**
 * Schema Applicator Service
 * Applies schema to Directus (creates collections, fields, relations, permissions)
 */

interface ApplyOptions {
  skipExisting?: boolean;
  dryRun?: boolean;
}

interface ApplyContext {
  services: any;
  schema: any;
  database: any;
  accountability: any;
  logger: any;
}

interface ApplyResult {
  success: boolean;
  collections_created: number;
  fields_created: number;
  relations_created: number;
  permissions_created: number;
  errors: string[];
}

export async function applySchema(
  schema: any,
  options: ApplyOptions,
  context: ApplyContext
): Promise<ApplyResult> {
  const { skipExisting = true, dryRun = false } = options;
  const { services, logger } = context;

  const result: ApplyResult = {
    success: true,
    collections_created: 0,
    fields_created: 0,
    relations_created: 0,
    permissions_created: 0,
    errors: [],
  };

  try {
    const { CollectionsService, FieldsService, RelationsService, PermissionsService } = services;

    const collectionsService = new CollectionsService({
      schema: context.schema,
      accountability: context.accountability,
    });

    const fieldsService = new FieldsService({
      schema: context.schema,
      accountability: context.accountability,
    });

    // Get existing collections
    const existingCollections = await collectionsService.readByQuery({});
    const existingCollectionNames = existingCollections.map((c: any) => c.collection);

    // Apply collections and fields
    for (const collection of schema.collections) {
      const collectionExists = existingCollectionNames.includes(collection.collection);

      if (collectionExists && skipExisting) {
        logger.info(`Skipping existing collection: ${collection.collection}`);
        continue;
      }

      if (dryRun) {
        logger.info(`[DRY RUN] Would create/update collection: ${collection.collection}`);
        result.collections_created++;
        result.fields_created += collection.fields.length;
        continue;
      }

      try {
        if (!collectionExists) {
          // Create collection
          logger.info(`Creating collection: ${collection.collection}`);

          await collectionsService.createOne({
            collection: collection.collection,
            meta: collection.meta,
            schema: collection.schema,
            fields: collection.fields.map((field: any) => ({
              field: field.field,
              type: field.type,
              schema: field.schema,
              meta: field.meta,
            })),
          });

          result.collections_created++;
          result.fields_created += collection.fields.length;
        } else {
          // Update existing collection
          logger.info(`Updating collection: ${collection.collection}`);

          // Update collection meta
          await collectionsService.updateOne(collection.collection, {
            meta: collection.meta,
          });

          // Get existing fields
          const existingFields = await fieldsService.readAll(collection.collection);
          const existingFieldNames = existingFields.map((f: any) => f.field);

          // Add new fields
          for (const field of collection.fields) {
            if (!existingFieldNames.includes(field.field)) {
              logger.info(`Creating field: ${collection.collection}.${field.field}`);

              await fieldsService.createField(collection.collection, {
                field: field.field,
                type: field.type,
                schema: field.schema,
                meta: field.meta,
              });

              result.fields_created++;
            } else {
              // Update existing field
              logger.info(`Updating field: ${collection.collection}.${field.field}`);

              await fieldsService.updateField(collection.collection, field.field, {
                type: field.type,
                schema: field.schema,
                meta: field.meta,
              });
            }
          }
        }
      } catch (error: any) {
        logger.error(`Failed to apply collection ${collection.collection}: ${error.message}`);
        result.errors.push(`Collection ${collection.collection}: ${error.message}`);
        result.success = false;
      }
    }

    // Apply relations
    if (schema.relations && Array.isArray(schema.relations)) {
      const relationsService = new RelationsService({
        schema: context.schema,
        accountability: context.accountability,
      });

      for (const relation of schema.relations) {
        if (dryRun) {
          logger.info(`[DRY RUN] Would create relation: ${relation.collection}.${relation.field}`);
          result.relations_created++;
          continue;
        }

        try {
          logger.info(`Creating relation: ${relation.collection}.${relation.field}`);

          await relationsService.createOne({
            collection: relation.collection,
            field: relation.field,
            related_collection: relation.related_collection,
            meta: relation.meta,
            schema: relation.schema,
          });

          result.relations_created++;
        } catch (error: any) {
          // Relation might already exist
          logger.warn(`Failed to create relation ${relation.collection}.${relation.field}: ${error.message}`);
        }
      }
    }

    // Apply permissions
    if (schema.permissions && Array.isArray(schema.permissions)) {
      const permissionsService = new PermissionsService({
        schema: context.schema,
        accountability: context.accountability,
      });

      for (const permission of schema.permissions) {
        if (dryRun) {
          logger.info(`[DRY RUN] Would create permission: ${permission.collection} (${permission.action})`);
          result.permissions_created++;
          continue;
        }

        try {
          logger.info(`Creating permission: ${permission.collection} (${permission.action})`);

          await permissionsService.createOne({
            collection: permission.collection,
            role: permission.role,
            action: permission.action,
            permissions: permission.permissions,
            validation: permission.validation,
            presets: permission.presets,
            fields: permission.fields,
          });

          result.permissions_created++;
        } catch (error: any) {
          logger.warn(`Failed to create permission for ${permission.collection}: ${error.message}`);
        }
      }
    }

    logger.info('Schema application completed', {
      collections_created: result.collections_created,
      fields_created: result.fields_created,
      relations_created: result.relations_created,
      permissions_created: result.permissions_created,
      errors: result.errors.length,
    });
  } catch (error: any) {
    logger.error(`Schema application failed: ${error.message}`, {
      error: error.stack,
    });

    result.success = false;
    result.errors.push(error.message);
  }

  return result;
}
