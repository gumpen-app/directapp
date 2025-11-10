import { defineEndpoint } from '@directus/extensions-sdk';
import { validateSchema } from './services/validator.js';
import { generateSchema } from './services/generator.js';
import { applySchema } from './services/applicator.js';

export default defineEndpoint({
  id: 'schema-builder',
  handler: (router, context) => {
    const { logger, services, exceptions } = context;
    const { ItemsService, CollectionsService, FieldsService, RelationsService, PermissionsService } = services;
    const { ForbiddenException, InvalidPayloadException, ServiceUnavailableException } = exceptions;

    /**
     * Validate a schema configuration
     * POST /schema-builder/validate
     */
    router.post('/validate', async (req, res) => {
      try {
        const { schema } = req.body;

        if (!schema) {
          return res.status(400).json({
            error: 'Missing required field: schema',
          });
        }

        logger.info('Validating schema', { collections: schema.collections?.length || 0 });

        const validationResult = await validateSchema(schema, {
          services,
          schema: req.schema,
          accountability: req.accountability,
        });

        logger.info('Schema validation completed', {
          valid: validationResult.valid,
          errors: validationResult.errors.length,
          warnings: validationResult.warnings.length,
        });

        return res.json({
          success: true,
          data: validationResult,
        });
      } catch (error: any) {
        logger.error(`Schema validation failed: ${error.message}`, {
          error: error.stack,
        });

        return res.status(500).json({
          error: 'Validation failed',
          message: error.message,
        });
      }
    });

    /**
     * Generate schema SQL/migration
     * POST /schema-builder/generate
     */
    router.post('/generate', async (req, res) => {
      try {
        const { schema, options } = req.body;

        if (!schema) {
          return res.status(400).json({
            error: 'Missing required field: schema',
          });
        }

        logger.info('Generating schema', {
          collections: schema.collections?.length || 0,
          options,
        });

        const generated = await generateSchema(schema, options || {}, {
          services,
          schema: req.schema,
          accountability: req.accountability,
        });

        logger.info('Schema generation completed');

        return res.json({
          success: true,
          data: generated,
        });
      } catch (error: any) {
        logger.error(`Schema generation failed: ${error.message}`, {
          error: error.stack,
        });

        return res.status(500).json({
          error: 'Generation failed',
          message: error.message,
        });
      }
    });

    /**
     * Apply schema to Directus (create collections, fields, relations)
     * POST /schema-builder/apply
     */
    router.post('/apply', async (req, res) => {
      try {
        const { schema, options } = req.body;

        if (!schema) {
          return res.status(400).json({
            error: 'Missing required field: schema',
          });
        }

        // Check if user has admin permissions
        const accountability = req.accountability;
        if (!accountability || accountability.admin !== true) {
          logger.warn('Non-admin user attempted to apply schema', {
            user: accountability?.user,
          });
          return res.status(403).json({
            error: 'Forbidden',
            message: 'Only administrators can apply schemas',
          });
        }

        logger.info('Applying schema', {
          collections: schema.collections?.length || 0,
          user: accountability.user,
        });

        // Validate first
        const validationResult = await validateSchema(schema, {
          services,
          schema: req.schema,
          accountability: req.accountability,
        });

        if (!validationResult.valid) {
          logger.warn('Schema validation failed before apply', {
            errors: validationResult.errors,
          });

          return res.status(400).json({
            error: 'Schema validation failed',
            data: validationResult,
          });
        }

        // Apply schema
        const result = await applySchema(schema, options || {}, {
          services,
          schema: req.schema,
          database: context.database,
          accountability: req.accountability,
          logger,
        });

        logger.info('Schema applied successfully', {
          collections_created: result.collections_created,
          fields_created: result.fields_created,
          relations_created: result.relations_created,
          permissions_created: result.permissions_created,
        });

        return res.json({
          success: true,
          data: result,
        });
      } catch (error: any) {
        logger.error(`Schema application failed: ${error.message}`, {
          error: error.stack,
        });

        return res.status(500).json({
          error: 'Application failed',
          message: error.message,
        });
      }
    });

    /**
     * Export existing schema
     * GET /schema-builder/export
     */
    router.get('/export', async (req, res) => {
      try {
        const { collections: collectionsQuery, includePermissions, includeRelations } = req.query;

        logger.info('Exporting schema', {
          collections: collectionsQuery,
          includePermissions,
          includeRelations,
        });

        const collectionsService = new CollectionsService({
          schema: req.schema,
          accountability: req.accountability,
        });

        const fieldsService = new FieldsService({
          schema: req.schema,
          accountability: req.accountability,
        });

        const relationsService = new RelationsService({
          schema: req.schema,
          accountability: req.accountability,
        });

        // Get collections
        let collections = await collectionsService.readByQuery({});

        // Filter if specific collections requested
        if (collectionsQuery && typeof collectionsQuery === 'string') {
          const requestedCollections = collectionsQuery.split(',');
          collections = collections.filter((c: any) =>
            requestedCollections.includes(c.collection)
          );
        }

        const exportedSchema: any = {
          version: 1,
          collections: [],
        };

        // Export each collection with fields
        for (const collection of collections) {
          const fields = await fieldsService.readAll(collection.collection);

          exportedSchema.collections.push({
            collection: collection.collection,
            meta: collection.meta,
            schema: collection.schema,
            fields: fields,
          });
        }

        // Include relations if requested
        if (includeRelations === 'true') {
          const relations = await relationsService.readAll();
          exportedSchema.relations = relations;
        }

        // Include permissions if requested
        if (includePermissions === 'true') {
          const permissionsService = new PermissionsService({
            schema: req.schema,
            accountability: req.accountability,
          });

          const permissions = await permissionsService.readByQuery({});
          exportedSchema.permissions = permissions;
        }

        logger.info('Schema exported successfully', {
          collections: exportedSchema.collections.length,
        });

        return res.json({
          success: true,
          data: exportedSchema,
        });
      } catch (error: any) {
        logger.error(`Schema export failed: ${error.message}`, {
          error: error.stack,
        });

        return res.status(500).json({
          error: 'Export failed',
          message: error.message,
        });
      }
    });

    /**
     * Save schema project (for later editing)
     * POST /schema-builder/projects
     */
    router.post('/projects', async (req, res) => {
      try {
        const { name, description, schema } = req.body;

        if (!name || !schema) {
          return res.status(400).json({
            error: 'Missing required fields: name, schema',
          });
        }

        logger.info('Saving schema project', { name });

        const projectsService = new ItemsService('directus_schema_projects', {
          schema: req.schema,
          accountability: req.accountability,
        });

        const project = await projectsService.createOne({
          name,
          description,
          schema: JSON.stringify(schema),
          user_created: req.accountability?.user,
        });

        logger.info('Schema project saved', { id: project });

        return res.json({
          success: true,
          data: { id: project },
        });
      } catch (error: any) {
        logger.error(`Failed to save schema project: ${error.message}`, {
          error: error.stack,
        });

        if (error.message.includes('does not exist')) {
          return res.status(503).json({
            error: 'Collection not configured',
            message: 'The directus_schema_projects collection does not exist. Please create it first.',
          });
        }

        return res.status(500).json({
          error: 'Save failed',
          message: error.message,
        });
      }
    });

    /**
     * Get schema projects
     * GET /schema-builder/projects
     */
    router.get('/projects', async (req, res) => {
      try {
        logger.info('Fetching schema projects');

        const projectsService = new ItemsService('directus_schema_projects', {
          schema: req.schema,
          accountability: req.accountability,
        });

        const projects = await projectsService.readByQuery({
          sort: ['-date_created'],
          limit: 100,
        });

        return res.json({
          success: true,
          data: projects,
        });
      } catch (error: any) {
        logger.error(`Failed to fetch schema projects: ${error.message}`);

        if (error.message.includes('does not exist')) {
          return res.status(503).json({
            error: 'Collection not configured',
            message: 'The directus_schema_projects collection does not exist.',
          });
        }

        return res.status(500).json({
          error: 'Fetch failed',
          message: error.message,
        });
      }
    });

    logger.info('Schema Builder API endpoint registered');
  },
});
