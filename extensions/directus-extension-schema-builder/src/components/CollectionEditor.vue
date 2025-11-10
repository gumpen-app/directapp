<template>
  <div class="collection-editor">
    <!-- Collection Header -->
    <div class="collection-header">
      <div class="collection-info">
        <v-icon :name="collection.meta.icon || 'box'" large />
        <div>
          <h1>{{ collection.collection }}</h1>
          <p class="collection-meta">
            {{ collection.fields.length }} fields
            <span v-if="collection.meta.singleton"> • Singleton</span>
            <span v-if="collection.meta.hidden"> • Hidden</span>
          </p>
        </div>
      </div>

      <v-menu show-arrow placement="bottom-end">
        <template #activator="{ toggle }">
          <v-button rounded icon @click="toggle">
            <v-icon name="more_vert" />
          </v-button>
        </template>

        <v-list>
          <v-list-item clickable @click="editCollectionMeta">
            <v-list-item-icon><v-icon name="edit" /></v-list-item-icon>
            <v-list-item-content>Edit Collection Settings</v-list-item-content>
          </v-list-item>

          <v-divider />

          <v-list-item clickable @click="deleteCollectionConfirm">
            <v-list-item-icon><v-icon name="delete" color="var(--danger)" /></v-list-item-icon>
            <v-list-item-content>Delete Collection</v-list-item-content>
          </v-list-item>
        </v-list>
      </v-menu>
    </div>

    <!-- Tabs -->
    <v-tabs v-model="activeTab" :items="tabs" />

    <!-- Fields Tab -->
    <div v-if="activeTab === 'fields'" class="tab-content">
      <div class="content-header">
        <h2>Fields</h2>
        <v-button @click="showAddFieldDialog = true">
          <v-icon name="add" left />
          Add Field
        </v-button>
      </div>

      <v-table
        v-if="collection.fields.length > 0"
        :headers="fieldTableHeaders"
        :items="collection.fields"
        show-resize
      >
        <template #[`item.field`]="{ item }">
          <div class="field-name-cell">
            <v-icon v-if="item.schema?.is_primary_key" name="key" small v-tooltip="'Primary Key'" />
            <v-icon v-if="item.schema?.is_unique" name="fingerprint" small v-tooltip="'Unique'" />
            <span>{{ item.field }}</span>
          </div>
        </template>

        <template #[`item.type`]="{ item }">
          <code>{{ item.type }}</code>
        </template>

        <template #[`item.interface`]="{ item }">
          {{ item.meta?.interface || '—' }}
        </template>

        <template #[`item.required`]="{ item }">
          <v-icon v-if="item.meta?.required" name="check" />
          <span v-else>—</span>
        </template>

        <template #[`item.readonly`]="{ item }">
          <v-icon v-if="item.meta?.readonly" name="check" />
          <span v-else>—</span>
        </template>

        <template #[`item.hidden`]="{ item }">
          <v-icon v-if="item.meta?.hidden" name="check" />
          <span v-else>—</span>
        </template>

        <template #[`item.actions`]="{ item }">
          <v-menu show-arrow placement="bottom-end">
            <template #activator="{ toggle }">
              <v-icon name="more_vert" clickable @click="toggle" />
            </template>

            <v-list>
              <v-list-item clickable @click="editField(item)">
                <v-list-item-icon><v-icon name="edit" /></v-list-item-icon>
                <v-list-item-content>Edit Field</v-list-item-content>
              </v-list-item>

              <v-list-item clickable @click="duplicateField(item)">
                <v-list-item-icon><v-icon name="content_copy" /></v-list-item-icon>
                <v-list-item-content>Duplicate Field</v-list-item-content>
              </v-list-item>

              <v-divider />

              <v-list-item clickable @click="deleteFieldConfirm(item)">
                <v-list-item-icon><v-icon name="delete" color="var(--danger)" /></v-list-item-icon>
                <v-list-item-content>Delete Field</v-list-item-content>
              </v-list-item>
            </v-list>
          </v-menu>
        </template>
      </v-table>

      <v-notice v-else type="info">
        No fields defined yet. Click "Add Field" to create your first field.
      </v-notice>
    </div>

    <!-- Relations Tab -->
    <div v-if="activeTab === 'relations'" class="tab-content">
      <div class="content-header">
        <h2>Relations</h2>
        <v-button @click="showAddRelationDialog = true">
          <v-icon name="add" left />
          Add Relation
        </v-button>
      </div>

      <v-notice type="info">
        Relations are created automatically based on field configuration with foreign keys.
        Use the "Add Relation" button to define Many-to-Many or Many-to-Any relations.
      </v-notice>
    </div>

    <!-- Groups Tab -->
    <div v-if="activeTab === 'groups'" class="tab-content">
      <div class="content-header">
        <h2>Field Groups</h2>
        <v-button @click="showAddGroupDialog = true">
          <v-icon name="add" left />
          Add Group
        </v-button>
      </div>

      <v-notice type="info">
        Field groups help organize related fields together in the item detail view.
      </v-notice>
    </div>

    <!-- Permissions Tab -->
    <div v-if="activeTab === 'permissions'" class="tab-content">
      <div class="content-header">
        <h2>Field-Level Permissions</h2>
      </div>

      <v-notice type="warning">
        Field-level permissions will be configured when applying the schema.
        Define which roles can access which fields.
      </v-notice>
    </div>

    <!-- Settings Tab -->
    <div v-if="activeTab === 'settings'" class="tab-content">
      <div class="content-header">
        <h2>Collection Settings</h2>
      </div>

      <div class="settings-form">
        <v-input v-model="localCollection.collection" label="Collection Name" disabled />

        <v-select
          v-model="localCollection.meta.icon"
          label="Icon"
          :items="iconOptions"
          placeholder="Select an icon"
        />

        <v-input v-model="localCollection.meta.note" label="Note" placeholder="Optional description" />

        <v-checkbox v-model="localCollection.meta.singleton" label="Singleton Collection" />
        <v-checkbox v-model="localCollection.meta.hidden" label="Hidden from Navigation" />
        <v-checkbox v-model="localCollection.meta.archive_app_filter" label="Archive App Filter" />
        <v-checkbox v-model="localCollection.meta.versioning" label="Enable Versioning" />

        <v-select
          v-model="localCollection.meta.accountability"
          label="Accountability"
          :items="[
            { text: 'All Activity', value: 'all' },
            { text: 'Activity Only', value: 'activity' },
            { text: 'None', value: null },
          ]"
        />

        <v-input v-model="localCollection.meta.archive_field" label="Archive Field" placeholder="status" />
        <v-input v-model="localCollection.meta.archive_value" label="Archive Value" placeholder="archived" />
        <v-input v-model="localCollection.meta.unarchive_value" label="Unarchive Value" placeholder="draft" />

        <v-input v-model="localCollection.meta.sort_field" label="Sort Field" placeholder="sort" />

        <div class="form-actions">
          <v-button @click="saveCollectionSettings">Save Settings</v-button>
        </div>
      </div>
    </div>

    <!-- Add Field Dialog -->
    <v-dialog v-model="showAddFieldDialog" @esc="showAddFieldDialog = false">
      <v-card>
        <v-card-title>Add Field</v-card-title>

        <v-card-text>
          <field-form v-model="newField" :collection="collection.collection" />
        </v-card-text>

        <v-card-actions>
          <v-button secondary @click="showAddFieldDialog = false">Cancel</v-button>
          <v-button @click="addFieldConfirm" :disabled="!newField.field || !newField.type">Add Field</v-button>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- Edit Field Dialog -->
    <v-dialog v-model="showEditFieldDialog" @esc="showEditFieldDialog = false">
      <v-card>
        <v-card-title>Edit Field</v-card-title>

        <v-card-text>
          <field-form v-model="editingField" :collection="collection.collection" />
        </v-card-text>

        <v-card-actions>
          <v-button secondary @click="showEditFieldDialog = false">Cancel</v-button>
          <v-button @click="saveFieldEdits">Save Changes</v-button>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue';
import type { CollectionSchema, FieldSchema } from '../types/schema';
import FieldForm from './FieldForm.vue';

const props = defineProps<{
  collection: CollectionSchema;
}>();

const emit = defineEmits<{
  update: [updates: Partial<CollectionSchema>];
  delete: [];
  'add-field': [field: FieldSchema];
  'update-field': [fieldName: string, updates: Partial<FieldSchema>];
  'delete-field': [fieldName: string];
  'add-relation': [relation: any];
  'add-group': [group: any];
}>();

const activeTab = ref('fields');
const tabs = [
  { text: 'Fields', value: 'fields' },
  { text: 'Relations', value: 'relations' },
  { text: 'Groups', value: 'groups' },
  { text: 'Permissions', value: 'permissions' },
  { text: 'Settings', value: 'settings' },
];

const localCollection = ref({ ...props.collection });

watch(
  () => props.collection,
  (newCollection) => {
    localCollection.value = { ...newCollection };
  },
  { deep: true }
);

const fieldTableHeaders = [
  { text: 'Field', value: 'field', width: 200 },
  { text: 'Type', value: 'type', width: 150 },
  { text: 'Interface', value: 'interface', width: 150 },
  { text: 'Required', value: 'required', width: 100 },
  { text: 'Readonly', value: 'readonly', width: 100 },
  { text: 'Hidden', value: 'hidden', width: 100 },
  { text: 'Actions', value: 'actions', width: 80, align: 'right' },
];

const iconOptions = [
  { text: 'Box', value: 'box' },
  { text: 'Folder', value: 'folder' },
  { text: 'People', value: 'people' },
  { text: 'Article', value: 'article' },
  { text: 'Settings', value: 'settings' },
  { text: 'Star', value: 'star' },
  { text: 'Shopping Cart', value: 'shopping_cart' },
  { text: 'Event', value: 'event' },
  { text: 'Image', value: 'image' },
  { text: 'Description', value: 'description' },
];

const showAddFieldDialog = ref(false);
const showEditFieldDialog = ref(false);
const showAddRelationDialog = ref(false);
const showAddGroupDialog = ref(false);

const newField = ref<Partial<FieldSchema>>({
  field: '',
  type: 'string',
  meta: {
    collection: props.collection.collection,
    field: '',
    readonly: false,
    hidden: false,
    required: false,
    interface: 'input',
  },
  schema: {
    is_nullable: true,
    is_unique: false,
    is_primary_key: false,
  },
});

const editingField = ref<Partial<FieldSchema>>({});
const editingFieldName = ref('');

function editCollectionMeta() {
  activeTab.value = 'settings';
}

function deleteCollectionConfirm() {
  if (confirm(`Are you sure you want to delete the collection "${props.collection.collection}"?`)) {
    emit('delete');
  }
}

function editField(field: FieldSchema) {
  editingField.value = JSON.parse(JSON.stringify(field));
  editingFieldName.value = field.field;
  showEditFieldDialog.value = true;
}

function duplicateField(field: FieldSchema) {
  const duplicate = JSON.parse(JSON.stringify(field));
  duplicate.field = `${field.field}_copy`;
  if (duplicate.meta) {
    duplicate.meta.field = duplicate.field;
  }
  emit('add-field', duplicate as FieldSchema);
}

function deleteFieldConfirm(field: FieldSchema) {
  if (confirm(`Are you sure you want to delete the field "${field.field}"?`)) {
    emit('delete-field', field.field);
  }
}

function addFieldConfirm() {
  if (!newField.value.field || !newField.value.type) return;

  emit('add-field', newField.value as FieldSchema);
  showAddFieldDialog.value = false;

  // Reset form
  newField.value = {
    field: '',
    type: 'string',
    meta: {
      collection: props.collection.collection,
      field: '',
      readonly: false,
      hidden: false,
      required: false,
      interface: 'input',
    },
    schema: {
      is_nullable: true,
      is_unique: false,
      is_primary_key: false,
    },
  };
}

function saveFieldEdits() {
  if (!editingFieldName.value) return;

  emit('update-field', editingFieldName.value, editingField.value);
  showEditFieldDialog.value = false;
}

function saveCollectionSettings() {
  emit('update', localCollection.value);
}
</script>

<style scoped>
.collection-editor {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.collection-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 24px;
  border-bottom: 1px solid var(--border-normal);
}

.collection-info {
  display: flex;
  align-items: center;
  gap: 16px;
}

.collection-info h1 {
  margin: 0;
  font-size: 24px;
}

.collection-meta {
  margin: 4px 0 0;
  color: var(--foreground-subdued);
  font-size: 14px;
}

.tab-content {
  flex: 1;
  overflow: auto;
  padding: 24px;
}

.content-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 24px;
}

.content-header h2 {
  margin: 0;
  font-size: 20px;
}

.field-name-cell {
  display: flex;
  align-items: center;
  gap: 8px;
}

.settings-form {
  max-width: 600px;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.form-actions {
  padding-top: 20px;
  border-top: 1px solid var(--border-normal);
}
</style>
