<template>
  <div class="validation-rules-form">
    <v-notice type="info">
      Define validation rules for this field. Rules use Directus filter syntax.
    </v-notice>

    <div v-if="rules.length > 0" class="rules-list">
      <div v-for="(rule, index) in rules" :key="index" class="rule-item">
        <v-select
          v-model="rule.operator"
          :items="validationOperators"
          placeholder="Select operator"
        />

        <v-input
          v-model="rule.value"
          placeholder="Value"
        />

        <v-icon name="delete" clickable @click="removeRule(index)" />
      </div>
    </div>

    <v-button secondary @click="addRule">
      <v-icon name="add" left />
      Add Rule
    </v-button>

    <!-- Common Validation Presets -->
    <div class="validation-presets">
      <h4>Quick Presets</h4>

      <div class="preset-buttons">
        <v-button small secondary @click="applyEmailValidation">Email</v-button>
        <v-button small secondary @click="applyURLValidation">URL</v-button>
        <v-button small secondary @click="applyPhoneValidation">Phone</v-button>
        <v-button small secondary @click="applyMinLengthValidation">Min Length</v-button>
        <v-button small secondary @click="applyMaxLengthValidation">Max Length</v-button>
        <v-button small secondary @click="applyNumericRangeValidation">Numeric Range</v-button>
      </div>
    </div>

    <!-- Advanced: Custom Filter Object -->
    <v-details summary="Advanced: Custom Filter Object">
      <v-textarea
        v-model="customFilterJSON"
        placeholder='{"_regex": "^[A-Z0-9]+$"}'
        rows="6"
        font-family="monospace"
        @blur="parseCustomFilter"
      />

      <v-notice v-if="parseError" type="danger">
        {{ parseError }}
      </v-notice>
    </v-details>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue';

const props = defineProps<{
  modelValue: Record<string, any> | null | undefined;
}>();

const emit = defineEmits<{
  'update:modelValue': [value: Record<string, any> | null];
}>();

interface ValidationRule {
  operator: string;
  value: string;
}

const rules = ref<ValidationRule[]>([]);
const customFilterJSON = ref('');
const parseError = ref('');

const validationOperators = [
  { text: 'Equals', value: '_eq' },
  { text: 'Not Equals', value: '_neq' },
  { text: 'Less Than', value: '_lt' },
  { text: 'Less Than or Equal', value: '_lte' },
  { text: 'Greater Than', value: '_gt' },
  { text: 'Greater Than or Equal', value: '_gte' },
  { text: 'In', value: '_in' },
  { text: 'Not In', value: '_nin' },
  { text: 'Contains', value: '_contains' },
  { text: 'Starts With', value: '_starts_with' },
  { text: 'Ends With', value: '_ends_with' },
  { text: 'Regex', value: '_regex' },
  { text: 'Is Null', value: '_null' },
  { text: 'Is Not Null', value: '_nnull' },
  { text: 'Is Empty', value: '_empty' },
  { text: 'Is Not Empty', value: '_nempty' },
];

// Initialize from modelValue
watch(
  () => props.modelValue,
  (newValue) => {
    if (newValue) {
      customFilterJSON.value = JSON.stringify(newValue, null, 2);
      parseRulesFromFilter(newValue);
    } else {
      rules.value = [];
      customFilterJSON.value = '';
    }
  },
  { immediate: true, deep: true }
);

// Emit changes
watch(
  rules,
  () => {
    updateModelValue();
  },
  { deep: true }
);

function parseRulesFromFilter(filter: Record<string, any>) {
  rules.value = [];

  for (const [operator, value] of Object.entries(filter)) {
    if (operator.startsWith('_')) {
      rules.value.push({
        operator,
        value: typeof value === 'object' ? JSON.stringify(value) : String(value),
      });
    }
  }
}

function updateModelValue() {
  if (rules.value.length === 0) {
    emit('update:modelValue', null);
    customFilterJSON.value = '';
    return;
  }

  const filter: Record<string, any> = {};

  for (const rule of rules.value) {
    if (rule.operator && rule.value) {
      try {
        // Try to parse value as JSON for complex values
        filter[rule.operator] = JSON.parse(rule.value);
      } catch {
        // If not JSON, use as string
        filter[rule.operator] = rule.value;
      }
    }
  }

  emit('update:modelValue', filter);
  customFilterJSON.value = JSON.stringify(filter, null, 2);
}

function addRule() {
  rules.value.push({
    operator: '_eq',
    value: '',
  });
}

function removeRule(index: number) {
  rules.value.splice(index, 1);
}

function parseCustomFilter() {
  parseError.value = '';

  if (!customFilterJSON.value.trim()) {
    emit('update:modelValue', null);
    rules.value = [];
    return;
  }

  try {
    const parsed = JSON.parse(customFilterJSON.value);
    emit('update:modelValue', parsed);
    parseRulesFromFilter(parsed);
  } catch (error: any) {
    parseError.value = `Invalid JSON: ${error.message}`;
  }
}

// Preset validation functions
function applyEmailValidation() {
  rules.value = [
    {
      operator: '_regex',
      value: '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$',
    },
  ];
}

function applyURLValidation() {
  rules.value = [
    {
      operator: '_regex',
      value: '^https?:\\/\\/(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b([-a-zA-Z0-9()@:%_\\+.~#?&//=]*)$',
    },
  ];
}

function applyPhoneValidation() {
  rules.value = [
    {
      operator: '_regex',
      value: '^[+]?[(]?[0-9]{3}[)]?[-\\s\\.]?[0-9]{3}[-\\s\\.]?[0-9]{4,6}$',
    },
  ];
}

function applyMinLengthValidation() {
  const length = prompt('Enter minimum length:', '3');
  if (length) {
    rules.value = [
      {
        operator: '_gte',
        value: length,
      },
    ];
  }
}

function applyMaxLengthValidation() {
  const length = prompt('Enter maximum length:', '255');
  if (length) {
    rules.value = [
      {
        operator: '_lte',
        value: length,
      },
    ];
  }
}

function applyNumericRangeValidation() {
  const min = prompt('Enter minimum value:', '0');
  const max = prompt('Enter maximum value:', '100');

  if (min && max) {
    rules.value = [
      {
        operator: '_gte',
        value: min,
      },
      {
        operator: '_lte',
        value: max,
      },
    ];
  }
}
</script>

<style scoped>
.validation-rules-form {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.rules-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.rule-item {
  display: grid;
  grid-template-columns: 200px 1fr auto;
  gap: 8px;
  align-items: center;
}

.validation-presets {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid var(--border-normal);
}

.validation-presets h4 {
  margin: 0 0 12px;
  font-size: 14px;
  font-weight: 600;
}

.preset-buttons {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}
</style>
