<template>
  <private-view title="Schema Builder">
    <template #headline>
      <v-breadcrumb :items="[{ name: 'Schema Builder', to: '/schema-builder' }]" />
    </template>

    <template #title-outer:prepend>
      <v-button class="header-icon" rounded disabled icon secondary>
        <v-icon name="architecture" />
      </v-button>
    </template>

    <template #actions>
      <v-button
        v-if="currentSchema.collections.length > 0"
        rounded
        icon
        @click="validateSchemaClick"
        :loading="validating"
        v-tooltip="'Validate Schema'"
      >
        <v-icon name="check_circle" />
      </v-button>

      <v-button
        v-if="currentSchema.collections.length > 0"
        rounded
        icon
        @click="exportSchemaClick"
        :loading="exporting"
        v-tooltip="'Export Schema'"
      >
        <v-icon name="download" />
      </v-button>

      <v-button
        v-if="currentSchema.collections.length > 0"
        rounded
        icon
        @click="applySchemaClick"
        :loading="applying"
        :disabled="!isValid"
        v-tooltip="'Apply Schema'"
      >
        <v-icon name="publish" />
      </v-button>

      <v-button rounded icon @click="importSchemaClick" v-tooltip="'Import Schema'">
        <v-icon name="upload" />
      </v-button>

      <v-button rounded icon @click="newCollectionClick" v-tooltip="'New Collection'">
        <v-icon name="add" />
      </v-button>
    </template>

    <template #navigation>
      <navigation-collections :collections="currentSchema.collections" :active="activeCollection" @select="selectCollection" />
    </template>

    <div class="schema-builder">
      <!-- Main Content Area -->
      <div v-if="!activeCollection" class="welcome-screen">
        <div class="welcome-content">
          <v-icon name="architecture" class="welcome-icon" />
          <h2>Welcome to Schema Builder</h2>
          <p>Build comprehensive Directus schemas with field access control, relations, and grouping.</p>

          <div class="quick-actions">
            <v-button large @click="newCollectionClick">
              <v-icon name="add" left />
              Create New Collection
            </v-button>

            <v-button large secondary @click="importSchemaClick">
              <v-icon name="upload" left />
              Import Existing Schema
            </v-button>
          </div>

          <div class="features">
            <div class="feature">
              <v-icon name="security" />
              <h3>Field Access Control</h3>
              <p>Configure permissions at the field level</p>
            </div>

            <div class="feature">
              <v-icon name="account_tree" />
              <h3>Relations</h3>
              <p>Define O2M, M2O, M2M, and M2A relations</p>
            </div>

            <div class="feature">
              <v-icon name="folder" />
              <h3>Grouping</h3>
              <p>Organize fields into logical groups</p>
            </div>

            <div class="feature">
              <v-icon name="verified" />
              <h3>Validation</h3>
              <p>Real-time schema validation and security checks</p>
            </div>
          </div>
        </div>
      </div>

      <!-- Collection Editor -->
      <div v-else class="collection-editor">
        <collection-editor
          :collection="activeCollection"
          @update="updateCollection"
          @delete="deleteCollection"
          @add-field="addField"
          @update-field="updateField"
          @delete-field="deleteField"
          @add-relation="addRelation"
          @add-group="addFieldGroup"
        />
      </div>

      <!-- Validation Results Panel -->
      <v-drawer
        v-model="showValidationResults"
        title="Validation Results"
        icon="check_circle"
        :sidebar-label="validationSummary"
      >
        <div class="validation-results">
          <div v-if="validationResult.valid" class="success-message">
            <v-icon name="check_circle" large color="var(--success)" />
            <h3>Schema is valid!</h3>
            <p>No errors or warnings found.</p>
          </div>

          <div v-else class="validation-issues">
            <div v-if="validationResult.errors.length > 0" class="errors-section">
              <h3>
                <v-icon name="error" color="var(--danger)" />
                Errors ({{ validationResult.errors.length }})
              </h3>

              <div v-for="(error, index) in validationResult.errors" :key="`error-${index}`" class="issue-item error">
                <div class="issue-header">
                  <span class="collection-name">{{ error.collection }}</span>
                  <span v-if="error.field" class="field-name">{{ error.field }}</span>
                  <code class="error-code">{{ error.code }}</code>
                </div>
                <p class="issue-message">{{ error.message }}</p>
              </div>
            </div>

            <div v-if="validationResult.warnings.length > 0" class="warnings-section">
              <h3>
                <v-icon name="warning" color="var(--warning)" />
                Warnings ({{ validationResult.warnings.length }})
              </h3>

              <div v-for="(warning, index) in validationResult.warnings" :key="`warning-${index}`" class="issue-item warning">
                <div class="issue-header">
                  <span class="collection-name">{{ warning.collection }}</span>
                  <span v-if="warning.field" class="field-name">{{ warning.field }}</span>
                  <code class="warning-code">{{ warning.code }}</code>
                </div>
                <p class="issue-message">{{ warning.message }}</p>
              </div>
            </div>
          </div>
        </div>
      </v-drawer>

      <!-- New Collection Dialog -->
      <v-dialog v-model="showNewCollectionDialog" @esc="showNewCollectionDialog = false">
        <v-card>
          <v-card-title>Create New Collection</v-card-title>

          <v-card-text>
            <v-input
              v-model="newCollection.collection"
              placeholder="collection_name"
              autofocus
              @keyup.enter="createCollection"
            >
              <template #prepend>
                <v-icon name="label" />
              </template>
            </v-input>

            <v-input v-model="newCollection.displayName" placeholder="Display Name (optional)">
              <template #prepend>
                <v-icon name="title" />
              </template>
            </v-input>

            <v-checkbox v-model="newCollection.singleton" label="Singleton" />
            <v-checkbox v-model="newCollection.hidden" label="Hidden" />
            <v-checkbox v-model="newCollection.accountability" label="Enable Accountability" />
          </v-card-text>

          <v-card-actions>
            <v-button secondary @click="showNewCollectionDialog = false">Cancel</v-button>
            <v-button @click="createCollection" :disabled="!newCollection.collection">Create</v-button>
          </v-card-actions>
        </v-card>
      </v-dialog>

      <!-- Import Schema Dialog -->
      <v-dialog v-model="showImportDialog" @esc="showImportDialog = false">
        <v-card>
          <v-card-title>Import Schema</v-card-title>

          <v-card-text>
            <v-textarea
              v-model="importContent"
              placeholder="Paste your schema JSON here..."
              rows="20"
              font-family="monospace"
            />
          </v-card-text>

          <v-card-actions>
            <v-button secondary @click="showImportDialog = false">Cancel</v-button>
            <v-button @click="importSchema" :disabled="!importContent">Import</v-button>
          </v-card-actions>
        </v-card>
      </v-dialog>

      <!-- Export Schema Dialog -->
      <v-dialog v-model="showExportDialog" @esc="showExportDialog = false">
        <v-card>
          <v-card-title>Export Schema</v-card-title>

          <v-card-text>
            <div class="export-options">
              <v-checkbox v-model="exportOptions.includePermissions" label="Include Permissions" />
              <v-checkbox v-model="exportOptions.includeRelations" label="Include Relations" />
              <v-checkbox v-model="exportOptions.includeSystemFields" label="Include System Fields" />

              <v-select
                v-model="exportOptions.format"
                :items="[
                  { text: 'JSON', value: 'json' },
                  { text: 'YAML', value: 'yaml' },
                  { text: 'SQL', value: 'sql' },
                ]"
                placeholder="Export Format"
              />
            </div>

            <v-textarea
              v-if="exportedContent"
              :model-value="exportedContent"
              readonly
              rows="20"
              font-family="monospace"
            />
          </v-card-text>

          <v-card-actions>
            <v-button secondary @click="showExportDialog = false">Close</v-button>
            <v-button v-if="exportedContent" @click="downloadExport">Download</v-button>
            <v-button v-else @click="generateExport" :loading="exporting">Generate</v-button>
          </v-card-actions>
        </v-card>
      </v-dialog>
    </div>
  </private-view>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';
import { useApi, useStores } from '@directus/extensions-sdk';
import NavigationCollections from './components/NavigationCollections.vue';
import CollectionEditor from './components/CollectionEditor.vue';
import type { SchemaBuilderProject, CollectionSchema, FieldSchema } from './types/schema';

const api = useApi();
const { useNotificationsStore } = useStores();
const notificationsStore = useNotificationsStore();

// State
const currentSchema = ref<SchemaBuilderProject>({
  name: 'Untitled Schema',
  collections: [],
});

const activeCollection = ref<CollectionSchema | null>(null);
const validating = ref(false);
const applying = ref(false);
const exporting = ref(false);
const isValid = ref(false);

const showValidationResults = ref(false);
const validationResult = ref<any>({
  valid: true,
  errors: [],
  warnings: [],
});

const showNewCollectionDialog = ref(false);
const newCollection = ref({
  collection: '',
  displayName: '',
  singleton: false,
  hidden: false,
  accountability: true,
});

const showImportDialog = ref(false);
const importContent = ref('');

const showExportDialog = ref(false);
const exportOptions = ref({
  includePermissions: true,
  includeRelations: true,
  includeSystemFields: false,
  format: 'json',
});
const exportedContent = ref('');

// Computed
const validationSummary = computed(() => {
  if (validationResult.value.valid) {
    return 'Valid';
  }

  const errors = validationResult.value.errors.length;
  const warnings = validationResult.value.warnings.length;
  return `${errors} Error${errors !== 1 ? 's' : ''}, ${warnings} Warning${warnings !== 1 ? 's' : ''}`;
});

// Methods
function selectCollection(collection: CollectionSchema) {
  activeCollection.value = collection;
}

function newCollectionClick() {
  newCollection.value = {
    collection: '',
    displayName: '',
    singleton: false,
    hidden: false,
    accountability: true,
  };
  showNewCollectionDialog.value = true;
}

function createCollection() {
  if (!newCollection.value.collection) return;

  const collection: CollectionSchema = {
    collection: newCollection.value.collection,
    meta: {
      collection: newCollection.value.collection,
      icon: 'box',
      hidden: newCollection.value.hidden,
      singleton: newCollection.value.singleton,
      accountability: newCollection.value.accountability ? 'all' : null,
      collapse: 'open',
      archive_app_filter: true,
      versioning: false,
    },
    fields: [
      {
        field: 'id',
        type: 'integer',
        schema: {
          is_primary_key: true,
          has_auto_increment: true,
          is_nullable: false,
        },
        meta: {
          collection: newCollection.value.collection,
          field: 'id',
          readonly: true,
          hidden: false,
          interface: 'input',
          special: ['uuid'],
        },
      },
    ],
  };

  currentSchema.value.collections.push(collection);
  activeCollection.value = collection;
  showNewCollectionDialog.value = false;

  notificationsStore.add({
    title: 'Collection Created',
    text: `Collection "${newCollection.value.collection}" has been created`,
    type: 'success',
  });
}

function updateCollection(updates: Partial<CollectionSchema>) {
  if (!activeCollection.value) return;

  Object.assign(activeCollection.value, updates);
}

function deleteCollection() {
  if (!activeCollection.value) return;

  const index = currentSchema.value.collections.findIndex(
    (c) => c.collection === activeCollection.value!.collection
  );

  if (index !== -1) {
    currentSchema.value.collections.splice(index, 1);
    activeCollection.value = null;

    notificationsStore.add({
      title: 'Collection Deleted',
      type: 'success',
    });
  }
}

function addField(field: FieldSchema) {
  if (!activeCollection.value) return;

  activeCollection.value.fields.push(field);
}

function updateField(fieldName: string, updates: Partial<FieldSchema>) {
  if (!activeCollection.value) return;

  const field = activeCollection.value.fields.find((f) => f.field === fieldName);
  if (field) {
    Object.assign(field, updates);
  }
}

function deleteField(fieldName: string) {
  if (!activeCollection.value) return;

  const index = activeCollection.value.fields.findIndex((f) => f.field === fieldName);
  if (index !== -1) {
    activeCollection.value.fields.splice(index, 1);
  }
}

function addRelation(relation: any) {
  // TODO: Implement relation adding
  console.log('Add relation:', relation);
}

function addFieldGroup(group: any) {
  // TODO: Implement field group adding
  console.log('Add field group:', group);
}

async function validateSchemaClick() {
  validating.value = true;

  try {
    const response = await api.post('/schema-builder/validate', {
      schema: currentSchema.value,
    });

    validationResult.value = response.data.data;
    isValid.value = validationResult.value.valid;
    showValidationResults.value = true;

    if (validationResult.value.valid) {
      notificationsStore.add({
        title: 'Schema Valid',
        text: 'Your schema passed all validation checks',
        type: 'success',
      });
    } else {
      notificationsStore.add({
        title: 'Validation Issues Found',
        text: `${validationResult.value.errors.length} error(s), ${validationResult.value.warnings.length} warning(s)`,
        type: 'warning',
      });
    }
  } catch (error: any) {
    notificationsStore.add({
      title: 'Validation Failed',
      text: error.message || 'Failed to validate schema',
      type: 'danger',
    });
  } finally {
    validating.value = false;
  }
}

function exportSchemaClick() {
  showExportDialog.value = true;
  exportedContent.value = '';
}

async function generateExport() {
  exporting.value = true;

  try {
    const response = await api.post('/schema-builder/generate', {
      schema: currentSchema.value,
      options: exportOptions.value,
    });

    exportedContent.value = response.data.data.content;
  } catch (error: any) {
    notificationsStore.add({
      title: 'Export Failed',
      text: error.message || 'Failed to generate export',
      type: 'danger',
    });
  } finally {
    exporting.value = false;
  }
}

function downloadExport() {
  const blob = new Blob([exportedContent.value], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = `schema-${Date.now()}.${exportOptions.value.format}`;
  a.click();
  URL.revokeObjectURL(url);
}

function importSchemaClick() {
  showImportDialog.value = true;
  importContent.value = '';
}

function importSchema() {
  try {
    const imported = JSON.parse(importContent.value);

    if (imported.collections && Array.isArray(imported.collections)) {
      currentSchema.value = imported;
      showImportDialog.value = false;

      notificationsStore.add({
        title: 'Schema Imported',
        text: `Imported ${imported.collections.length} collection(s)`,
        type: 'success',
      });
    } else {
      throw new Error('Invalid schema format');
    }
  } catch (error: any) {
    notificationsStore.add({
      title: 'Import Failed',
      text: error.message || 'Invalid JSON format',
      type: 'danger',
    });
  }
}

async function applySchemaClick() {
  if (!isValid.value) {
    notificationsStore.add({
      title: 'Cannot Apply',
      text: 'Please validate the schema first and fix any errors',
      type: 'warning',
    });
    return;
  }

  applying.value = true;

  try {
    const response = await api.post('/schema-builder/apply', {
      schema: currentSchema.value,
      options: {
        skipExisting: true,
      },
    });

    const result = response.data.data;

    notificationsStore.add({
      title: 'Schema Applied',
      text: `Created ${result.collections_created} collection(s), ${result.fields_created} field(s)`,
      type: 'success',
    });
  } catch (error: any) {
    notificationsStore.add({
      title: 'Apply Failed',
      text: error.message || 'Failed to apply schema',
      type: 'danger',
    });
  } finally {
    applying.value = false;
  }
}
</script>

<style scoped>
.schema-builder {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.welcome-screen {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 100%;
  padding: 40px;
}

.welcome-content {
  max-width: 800px;
  text-align: center;
}

.welcome-icon {
  font-size: 80px;
  color: var(--primary);
  margin-bottom: 20px;
}

.welcome-content h2 {
  font-size: 32px;
  margin-bottom: 10px;
}

.welcome-content > p {
  color: var(--foreground-subdued);
  margin-bottom: 30px;
}

.quick-actions {
  display: flex;
  gap: 16px;
  justify-content: center;
  margin-bottom: 60px;
}

.features {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 30px;
  margin-top: 40px;
}

.feature {
  text-align: center;
}

.feature .v-icon {
  font-size: 40px;
  color: var(--primary);
  margin-bottom: 10px;
}

.feature h3 {
  font-size: 18px;
  margin-bottom: 8px;
}

.feature p {
  color: var(--foreground-subdued);
  font-size: 14px;
}

.collection-editor {
  flex: 1;
  overflow: auto;
}

.validation-results {
  padding: 20px;
}

.success-message {
  text-align: center;
  padding: 40px;
}

.success-message .v-icon {
  margin-bottom: 20px;
}

.errors-section,
.warnings-section {
  margin-bottom: 30px;
}

.errors-section h3,
.warnings-section h3 {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 16px;
}

.issue-item {
  padding: 16px;
  margin-bottom: 12px;
  border-radius: 4px;
  border-left: 4px solid;
}

.issue-item.error {
  border-left-color: var(--danger);
  background-color: var(--danger-25);
}

.issue-item.warning {
  border-left-color: var(--warning);
  background-color: var(--warning-25);
}

.issue-header {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-bottom: 8px;
}

.collection-name {
  font-weight: 600;
}

.field-name {
  color: var(--foreground-subdued);
}

.error-code,
.warning-code {
  margin-left: auto;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 12px;
  background-color: var(--background-normal);
}

.issue-message {
  color: var(--foreground-normal);
  margin: 0;
}

.export-options {
  display: flex;
  flex-direction: column;
  gap: 16px;
  margin-bottom: 20px;
}
</style>
