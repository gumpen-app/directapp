<template>
  <div class="field-form">
    <!-- Basic Information -->
    <div class="form-section">
      <h3>Basic Information</h3>

      <v-input
        v-model="localField.field"
        label="Field Name"
        placeholder="field_name"
        :disabled="isEditing"
        @update:model-value="syncMetaField"
      />

      <v-select
        v-model="localField.type"
        label="Field Type"
        :items="fieldTypes"
        required
      />

      <v-select
        v-model="localField.meta.interface"
        label="Interface"
        :items="getInterfacesForType(localField.type)"
        placeholder="Select interface"
      />

      <v-textarea
        v-model="localField.meta.note"
        label="Note"
        placeholder="Optional field description"
        rows="3"
      />
    </div>

    <!-- Schema Configuration -->
    <div class="form-section">
      <h3>Schema Configuration</h3>

      <v-checkbox v-model="localField.schema.is_primary_key" label="Primary Key" />
      <v-checkbox v-model="localField.schema.is_unique" label="Unique" />
      <v-checkbox v-model="localField.schema.is_nullable" label="Nullable" />
      <v-checkbox v-model="localField.schema.has_auto_increment" label="Auto Increment" :disabled="localField.type !== 'integer'" />

      <v-input
        v-if="localField.type === 'string'"
        v-model.number="localField.schema.max_length"
        type="number"
        label="Max Length"
        placeholder="255"
      />

      <v-input
        v-if="localField.type === 'decimal' || localField.type === 'float'"
        v-model.number="localField.schema.numeric_precision"
        type="number"
        label="Numeric Precision"
        placeholder="10"
      />

      <v-input
        v-if="localField.type === 'decimal'"
        v-model.number="localField.schema.numeric_scale"
        type="number"
        label="Numeric Scale"
        placeholder="2"
      />

      <v-input
        v-model="localField.schema.default_value"
        label="Default Value"
        placeholder="Default value"
      />

      <v-textarea
        v-model="localField.schema.comment"
        label="Database Comment"
        placeholder="Optional SQL comment"
        rows="2"
      />
    </div>

    <!-- Display Options -->
    <div class="form-section">
      <h3>Display Options</h3>

      <v-checkbox v-model="localField.meta.required" label="Required" />
      <v-checkbox v-model="localField.meta.readonly" label="Read-only" />
      <v-checkbox v-model="localField.meta.hidden" label="Hidden" />

      <v-select
        v-model="localField.meta.width"
        label="Width"
        :items="[
          { text: 'Half', value: 'half' },
          { text: 'Half (Left)', value: 'half-left' },
          { text: 'Half (Right)', value: 'half-right' },
          { text: 'Full', value: 'full' },
          { text: 'Fill', value: 'fill' },
        ]"
        placeholder="Auto"
      />

      <v-input
        v-model.number="localField.meta.sort"
        type="number"
        label="Sort Order"
        placeholder="Auto"
      />

      <v-input
        v-model="localField.meta.group"
        label="Field Group"
        placeholder="Group name"
      />
    </div>

    <!-- Interface Options -->
    <div v-if="localField.meta.interface" class="form-section">
      <h3>Interface Options</h3>

      <interface-options-form
        v-model="localField.meta.options"
        :interface-type="localField.meta.interface"
        :field-type="localField.type"
      />
    </div>

    <!-- Validation Rules -->
    <div class="form-section">
      <h3>Validation Rules</h3>

      <validation-rules-form v-model="localField.meta.validation" />

      <v-input
        v-model="localField.meta.validation_message"
        label="Validation Message"
        placeholder="Custom validation error message"
      />
    </div>

    <!-- Foreign Key (for relations) -->
    <div v-if="showForeignKey" class="form-section">
      <h3>Foreign Key</h3>

      <v-input
        v-model="localField.schema.foreign_key_table"
        label="Foreign Table"
        placeholder="related_collection"
      />

      <v-input
        v-model="localField.schema.foreign_key_column"
        label="Foreign Column"
        placeholder="id"
      />

      <v-select
        v-model="localField.schema.on_update"
        label="On Update"
        :items="[
          { text: 'No Action', value: 'NO ACTION' },
          { text: 'Cascade', value: 'CASCADE' },
          { text: 'Set NULL', value: 'SET NULL' },
          { text: 'Set Default', value: 'SET DEFAULT' },
          { text: 'Restrict', value: 'RESTRICT' },
        ]"
      />

      <v-select
        v-model="localField.schema.on_delete"
        label="On Delete"
        :items="[
          { text: 'No Action', value: 'NO ACTION' },
          { text: 'Cascade', value: 'CASCADE' },
          { text: 'Set NULL', value: 'SET NULL' },
          { text: 'Set Default', value: 'SET DEFAULT' },
          { text: 'Restrict', value: 'RESTRICT' },
        ]"
      />
    </div>

    <!-- Conditions -->
    <div class="form-section">
      <h3>Conditional Display</h3>

      <v-notice type="info">
        Configure when this field should be visible or editable based on other field values.
      </v-notice>

      <!-- TODO: Implement conditions builder -->
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue';
import type { FieldSchema } from '../types/schema';
import InterfaceOptionsForm from './InterfaceOptionsForm.vue';
import ValidationRulesForm from './ValidationRulesForm.vue';

const props = defineProps<{
  modelValue: Partial<FieldSchema>;
  collection: string;
  isEditing?: boolean;
}>();

const emit = defineEmits<{
  'update:modelValue': [value: Partial<FieldSchema>];
}>();

const localField = ref<Partial<FieldSchema>>({ ...props.modelValue });

watch(
  () => props.modelValue,
  (newValue) => {
    localField.value = { ...newValue };
  },
  { deep: true }
);

watch(
  localField,
  (newValue) => {
    emit('update:modelValue', newValue);
  },
  { deep: true }
);

const fieldTypes = [
  { text: 'String (VARCHAR)', value: 'string' },
  { text: 'Text', value: 'text' },
  { text: 'Integer', value: 'integer' },
  { text: 'Big Integer', value: 'bigInteger' },
  { text: 'Float', value: 'float' },
  { text: 'Decimal', value: 'decimal' },
  { text: 'Boolean', value: 'boolean' },
  { text: 'Date', value: 'date' },
  { text: 'Time', value: 'time' },
  { text: 'Date & Time', value: 'dateTime' },
  { text: 'Timestamp', value: 'timestamp' },
  { text: 'JSON', value: 'json' },
  { text: 'CSV', value: 'csv' },
  { text: 'UUID', value: 'uuid' },
  { text: 'Hash', value: 'hash' },
  { text: 'Binary', value: 'binary' },
  { text: 'Alias (no database)', value: 'alias' },
];

const showForeignKey = computed(() => {
  return localField.value.meta?.interface?.includes('many-to-one') ||
    localField.value.meta?.interface?.includes('m2o') ||
    localField.value.schema?.foreign_key_table;
});

function syncMetaField() {
  if (localField.value.meta && localField.value.field) {
    localField.value.meta.field = localField.value.field;
  }
}

function getInterfacesForType(type: string | undefined) {
  const interfaceMap: Record<string, any[]> = {
    string: [
      { text: 'Input', value: 'input' },
      { text: 'Select Dropdown', value: 'select-dropdown' },
      { text: 'Select Dropdown (Multiple)', value: 'select-dropdown-m2m' },
      { text: 'Radio Buttons', value: 'select-radio' },
      { text: 'Checkboxes', value: 'select-checkbox-tree' },
      { text: 'Input Hash', value: 'input-hash' },
      { text: 'Slug', value: 'input-slug' },
      { text: 'Color Picker', value: 'select-color' },
    ],
    text: [
      { text: 'Textarea', value: 'input-multiline' },
      { text: 'Rich Text (WYSIWYG)', value: 'input-rich-text-html' },
      { text: 'Markdown', value: 'input-rich-text-md' },
      { text: 'Code Editor', value: 'input-code' },
    ],
    integer: [
      { text: 'Input', value: 'input' },
      { text: 'Slider', value: 'slider' },
      { text: 'Rating', value: 'select-icon' },
    ],
    bigInteger: [
      { text: 'Input', value: 'input' },
    ],
    float: [
      { text: 'Input', value: 'input' },
      { text: 'Slider', value: 'slider' },
    ],
    decimal: [
      { text: 'Input', value: 'input' },
    ],
    boolean: [
      { text: 'Toggle', value: 'boolean' },
      { text: 'Checkbox', value: 'checkbox' },
    ],
    date: [
      { text: 'Date Picker', value: 'datetime' },
    ],
    time: [
      { text: 'Time Picker', value: 'datetime' },
    ],
    dateTime: [
      { text: 'Date & Time Picker', value: 'datetime' },
    ],
    timestamp: [
      { text: 'Timestamp', value: 'datetime' },
    ],
    json: [
      { text: 'JSON Editor', value: 'input-code' },
      { text: 'Key-Value Pairs', value: 'input-key-value' },
      { text: 'Tags', value: 'tags' },
      { text: 'List', value: 'list' },
    ],
    csv: [
      { text: 'Tags', value: 'tags' },
      { text: 'Checkboxes', value: 'select-multiple-checkbox' },
    ],
    uuid: [
      { text: 'Input', value: 'input' },
      { text: 'UUID', value: 'input-hash' },
    ],
    hash: [
      { text: 'Input Hash', value: 'input-hash' },
    ],
    alias: [
      { text: 'Presentation', value: 'presentation' },
      { text: 'Divider', value: 'presentation-divider' },
      { text: 'Notice', value: 'presentation-notice' },
    ],
  };

  return interfaceMap[type || 'string'] || [{ text: 'Input', value: 'input' }];
}
</script>

<style scoped>
.field-form {
  display: flex;
  flex-direction: column;
  gap: 32px;
}

.form-section {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.form-section h3 {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  padding-bottom: 8px;
  border-bottom: 1px solid var(--border-normal);
}
</style>
