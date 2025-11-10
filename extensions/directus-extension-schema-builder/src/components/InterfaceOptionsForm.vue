<template>
  <div class="interface-options-form">
    <!-- Select Dropdown Options -->
    <div v-if="interfaceType === 'select-dropdown' || interfaceType === 'select-radio'" class="options-group">
      <v-notice type="info">
        Define the available choices for this field.
      </v-notice>

      <div v-if="localOptions.choices" class="choices-list">
        <div v-for="(choice, index) in localOptions.choices" :key="index" class="choice-item">
          <v-input
            v-model="choice.text"
            placeholder="Label"
          />
          <v-input
            v-model="choice.value"
            placeholder="Value"
          />
          <v-icon name="delete" clickable @click="removeChoice(index)" />
        </div>
      </div>

      <v-button secondary @click="addChoice">
        <v-icon name="add" left />
        Add Choice
      </v-button>

      <v-checkbox
        v-if="interfaceType === 'select-dropdown'"
        v-model="localOptions.allowOther"
        label="Allow Other Values"
      />
    </div>

    <!-- Input Options -->
    <div v-if="interfaceType === 'input'" class="options-group">
      <v-input
        v-model="localOptions.placeholder"
        label="Placeholder"
        placeholder="Enter placeholder text..."
      />

      <v-input
        v-model="localOptions.iconLeft"
        label="Icon (Left)"
        placeholder="search"
      />

      <v-input
        v-model="localOptions.iconRight"
        label="Icon (Right)"
        placeholder="info"
      />

      <v-checkbox v-model="localOptions.trim" label="Trim Whitespace" />
      <v-checkbox v-model="localOptions.masked" label="Masked Input (Password)" />
      <v-checkbox v-model="localOptions.clear" label="Show Clear Button" />
    </div>

    <!-- Rich Text Options -->
    <div v-if="interfaceType === 'input-rich-text-html' || interfaceType === 'input-rich-text-md'" class="options-group">
      <v-select
        v-model="localOptions.toolbar"
        label="Toolbar"
        :items="[
          { text: 'Full', value: 'full' },
          { text: 'Basic', value: 'basic' },
          { text: 'Minimal', value: 'minimal' },
          { text: 'Custom', value: 'custom' },
        ]"
      />

      <v-checkbox v-model="localOptions.imageToken" label="Enable Image Upload" />
    </div>

    <!-- Slider Options -->
    <div v-if="interfaceType === 'slider'" class="options-group">
      <v-input
        v-model.number="localOptions.minValue"
        type="number"
        label="Minimum Value"
        placeholder="0"
      />

      <v-input
        v-model.number="localOptions.maxValue"
        type="number"
        label="Maximum Value"
        placeholder="100"
      />

      <v-input
        v-model.number="localOptions.stepInterval"
        type="number"
        label="Step Interval"
        placeholder="1"
      />

      <v-checkbox v-model="localOptions.alwaysShowValue" label="Always Show Value" />
    </div>

    <!-- Date/Time Options -->
    <div v-if="interfaceType === 'datetime'" class="options-group">
      <v-checkbox v-model="localOptions.includeSeconds" label="Include Seconds" />
      <v-checkbox v-model="localOptions.use24" label="Use 24-Hour Format" />

      <v-input
        v-model="localOptions.min"
        label="Minimum Date/Time"
        placeholder="YYYY-MM-DD HH:mm:ss"
      />

      <v-input
        v-model="localOptions.max"
        label="Maximum Date/Time"
        placeholder="YYYY-MM-DD HH:mm:ss"
      />
    </div>

    <!-- File/Image Options -->
    <div v-if="interfaceType === 'file' || interfaceType === 'file-image'" class="options-group">
      <v-input
        v-model="localOptions.folder"
        label="Default Folder"
        placeholder="UUID or folder name"
      />

      <v-checkbox v-model="localOptions.crop" label="Enable Cropping (Images)" />
    </div>

    <!-- Tags Options -->
    <div v-if="interfaceType === 'tags'" class="options-group">
      <v-input
        v-model="localOptions.placeholder"
        label="Placeholder"
        placeholder="Enter tags..."
      />

      <v-input
        v-model="localOptions.iconLeft"
        label="Icon"
        placeholder="local_offer"
      />

      <v-checkbox v-model="localOptions.lowercase" label="Force Lowercase" />
      <v-checkbox v-model="localOptions.alphabetize" label="Sort Alphabetically" />
      <v-checkbox v-model="localOptions.allowCustom" label="Allow Custom Tags" />

      <v-textarea
        v-model="localOptions.presets"
        label="Preset Tags (one per line)"
        rows="4"
        placeholder="tag1&#10;tag2&#10;tag3"
      />
    </div>

    <!-- Key-Value Options -->
    <div v-if="interfaceType === 'input-key-value'" class="options-group">
      <v-input
        v-model="localOptions.keyInterface"
        label="Key Interface"
        placeholder="input"
      />

      <v-input
        v-model="localOptions.valueInterface"
        label="Value Interface"
        placeholder="input"
      />
    </div>

    <!-- Fallback for unsupported interfaces -->
    <v-notice v-if="!hasOptions" type="info">
      No additional options available for this interface.
    </v-notice>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch } from 'vue';

const props = defineProps<{
  modelValue: Record<string, any> | null | undefined;
  interfaceType: string;
  fieldType: string;
}>();

const emit = defineEmits<{
  'update:modelValue': [value: Record<string, any>];
}>();

const localOptions = ref<Record<string, any>>(props.modelValue || {});

watch(
  () => props.modelValue,
  (newValue) => {
    localOptions.value = newValue || {};
  },
  { deep: true }
);

watch(
  localOptions,
  (newValue) => {
    emit('update:modelValue', newValue);
  },
  { deep: true }
);

const hasOptions = computed(() => {
  const supportedInterfaces = [
    'select-dropdown',
    'select-radio',
    'input',
    'input-rich-text-html',
    'input-rich-text-md',
    'slider',
    'datetime',
    'file',
    'file-image',
    'tags',
    'input-key-value',
  ];

  return supportedInterfaces.includes(props.interfaceType);
});

function addChoice() {
  if (!localOptions.value.choices) {
    localOptions.value.choices = [];
  }

  localOptions.value.choices.push({
    text: '',
    value: '',
  });
}

function removeChoice(index: number) {
  if (localOptions.value.choices) {
    localOptions.value.choices.splice(index, 1);
  }
}
</script>

<style scoped>
.interface-options-form {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.options-group {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.choices-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.choice-item {
  display: grid;
  grid-template-columns: 1fr 1fr auto;
  gap: 8px;
  align-items: center;
}
</style>
