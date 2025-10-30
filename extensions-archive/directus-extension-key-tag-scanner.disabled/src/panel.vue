<script setup lang="ts">
import { ref } from 'vue';
import { useApi, useStores } from '@directus/extensions-sdk';
import { useRouter } from 'vue-router';

interface Props {
  title?: string;
  auto_redirect?: boolean;
}

const props = withDefaults(defineProps<Props>(), {
  title: 'Key Tag Scanner',
  auto_redirect: true,
});

const api = useApi();
const router = useRouter();
const { useNotificationsStore } = useStores();
const notificationsStore = useNotificationsStore();

const cameraInput = ref<HTMLInputElement | null>(null);
const fileInput = ref<HTMLInputElement | null>(null);
const loading = ref(false);
const loadingStep = ref('');
const scannedCar = ref<any>(null);
const notFound = ref(false);
const error = ref('');
const extractedText = ref('');

function openCamera() {
  cameraInput.value?.click();
}

function openFileUpload() {
  fileInput.value?.click();
}

async function handleFileUpload(event: Event) {
  const target = event.target as HTMLInputElement;
  const file = target.files?.[0];
  if (!file) return;

  loading.value = true;
  loadingStep.value = 'Uploading image...';
  error.value = '';
  notFound.value = false;

  try {
    // Upload image to Directus files
    const formData = new FormData();
    formData.append('file', file);
    formData.append('folder', 'key-tag-scans');

    loadingStep.value = 'Processing upload...';

    const uploadResponse = await api.post('/files', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });

    const fileId = uploadResponse.data.data.id;

    // Extract text from image
    loadingStep.value = 'Extracting text from image...';

    const parseResponse = await api.post('/parse-order-pdf', {
      file_id: fileId,
    });

    const extracted = parseResponse.data.data.extracted;
    extractedText.value = parseResponse.data.data.raw_text;

    // Search for car by VIN or order number
    loadingStep.value = 'Looking up vehicle...';
    await findCar(extracted);
  } catch (err: any) {
    console.error('Scan error:', err);
    error.value = err.response?.data?.error || err.message || 'Failed to scan key tag';
  } finally {
    loading.value = false;
    loadingStep.value = '';
  }
}

async function findCar(extracted: any) {
  if (!extracted.vin && !extracted.order_number) {
    notFound.value = true;
    return;
  }

  // Build filter
  const filters: any[] = [];

  if (extracted.vin) {
    filters.push({ vin: { _eq: extracted.vin } });
  }

  if (extracted.order_number) {
    filters.push({ order_number: { _eq: extracted.order_number } });
  }

  const response = await api.get('/items/cars', {
    params: {
      filter: { _or: filters },
      fields: ['id', 'vin', 'brand', 'model', 'order_number', 'status'],
      limit: 1,
    },
  });

  if (response.data.data && response.data.data.length > 0) {
    scannedCar.value = response.data.data[0];

    if (props.auto_redirect) {
      notificationsStore.add({
        title: 'Vehicle Found',
        text: `${scannedCar.value.brand} ${scannedCar.value.model}`,
        type: 'success',
      });

      router.push(`/content/cars/${scannedCar.value.id}`);
    }
  } else {
    notFound.value = true;
  }
}

function formatStatus(status: string): string {
  return status
    .split('_')
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ');
}

function openCar() {
  if (scannedCar.value) {
    router.push(`/content/cars/${scannedCar.value.id}`);
  }
}

function startReceptionControl() {
  if (scannedCar.value) {
    router.push(`/content/cars/${scannedCar.value.id}?tab=reception`);
  }
}

function createNewCar() {
  router.push('/content/cars/+');
}

function reset() {
  scannedCar.value = null;
  notFound.value = false;
  error.value = '';
  extractedText.value = '';
  if (cameraInput.value) cameraInput.value.value = '';
  if (fileInput.value) fileInput.value.value = '';
}
</script>

<template>
  <div class="key-tag-scanner-panel">
    <div class="panel-header">
      <h2 class="title">{{ title }}</h2>
      <div class="controls">
        <v-button v-if="scannedCar" icon rounded @click="reset">
          <v-icon name="refresh" />
        </v-button>
      </div>
    </div>

    <!-- Scan Interface -->
    <div v-if="!scannedCar && !loading" class="scan-interface">
      <!-- Camera Capture -->
      <div class="scan-method">
        <v-icon name="photo_camera" large />
        <h3>Take Photo</h3>
        <input
          ref="cameraInput"
          type="file"
          accept="image/*"
          capture="environment"
          style="display: none"
          @change="handleFileUpload"
        />
        <v-button large @click="openCamera">
          <v-icon name="photo_camera" left />
          Open Camera
        </v-button>
      </div>

      <div class="divider">
        <span>OR</span>
      </div>

      <!-- File Upload -->
      <div class="scan-method">
        <v-icon name="upload_file" large />
        <h3>Upload Photo</h3>
        <input
          ref="fileInput"
          type="file"
          accept="image/*"
          style="display: none"
          @change="handleFileUpload"
        />
        <v-button large @click="openFileUpload">
          <v-icon name="upload" left />
          Choose File
        </v-button>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="loading-container">
      <v-progress-circular indeterminate />
      <p>Scanning key tag...</p>
      <p class="loading-step">{{ loadingStep }}</p>
    </div>

    <!-- Scanned Result -->
    <div v-if="scannedCar && !loading" class="scan-result">
      <div class="result-header">
        <v-icon name="check_circle" class="success-icon" />
        <h3>Vehicle Found!</h3>
      </div>

      <div class="car-info">
        <div class="info-row">
          <span class="label">VIN:</span>
          <span class="value">{{ scannedCar.vin }}</span>
        </div>
        <div class="info-row">
          <span class="label">Brand:</span>
          <span class="value">{{ scannedCar.brand }}</span>
        </div>
        <div class="info-row">
          <span class="label">Model:</span>
          <span class="value">{{ scannedCar.model }}</span>
        </div>
        <div class="info-row">
          <span class="label">Order Number:</span>
          <span class="value">{{ scannedCar.order_number }}</span>
        </div>
        <div class="info-row">
          <span class="label">Status:</span>
          <span class="value status-badge">{{ formatStatus(scannedCar.status) }}</span>
        </div>
      </div>

      <div class="actions">
        <v-button large @click="openCar">
          <v-icon name="launch" left />
          Open Car
        </v-button>
        <v-button large secondary @click="startReceptionControl">
          <v-icon name="fact_check" left />
          Start Reception Control
        </v-button>
      </div>
    </div>

    <!-- Not Found -->
    <div v-if="notFound && !loading" class="not-found">
      <v-icon name="search_off" class="error-icon" />
      <h3>Vehicle Not Found</h3>
      <p>Could not find a vehicle matching the scanned key tag.</p>
      <p v-if="extractedText" class="extracted-text">
        <strong>Extracted:</strong> {{ extractedText }}
      </p>
      <div class="actions">
        <v-button large @click="createNewCar">
          <v-icon name="add" left />
          Create New Vehicle
        </v-button>
        <v-button large secondary @click="reset">
          Try Again
        </v-button>
      </div>
    </div>

    <!-- Error -->
    <div v-if="error && !loading" class="error-state">
      <v-icon name="error" class="error-icon" />
      <h3>Scan Failed</h3>
      <p>{{ error }}</p>
      <v-button large @click="reset">
        Try Again
      </v-button>
    </div>
  </div>
</template>

<style scoped>
.key-tag-scanner-panel {
  padding: var(--content-padding);
  height: 100%;
  display: flex;
  flex-direction: column;
  gap: 24px;
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.title {
  margin: 0;
  font-size: 20px;
  font-weight: 600;
}

.scan-interface {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 48px;
}

.scan-method {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
  padding: 48px;
  background: var(--theme--background-subdued);
  border-radius: 12px;
  border: 2px dashed var(--theme--border-color);
  transition: all 0.2s;
}

.scan-method:hover {
  border-color: var(--theme--primary);
  background: var(--theme--background-normal);
}

.scan-method h3 {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
}

.divider {
  position: relative;
  width: 60px;
  height: 2px;
  background: var(--theme--border-color);
}

.divider span {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  padding: 0 12px;
  background: var(--theme--background);
  color: var(--theme--foreground-subdued);
  font-size: 12px;
  font-weight: 600;
}

.loading-container {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 16px;
}

.loading-step {
  color: var(--theme--foreground-subdued);
  font-size: 14px;
}

.scan-result,
.not-found,
.error-state {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 24px;
}

.result-header {
  display: flex;
  align-items: center;
  gap: 12px;
}

.result-header h3 {
  margin: 0;
  font-size: 24px;
  font-weight: 600;
}

.success-icon {
  color: var(--theme--success);
  font-size: 48px;
}

.error-icon {
  color: var(--theme--danger);
  font-size: 48px;
}

.car-info {
  width: 100%;
  max-width: 500px;
  background: var(--theme--background-subdued);
  border-radius: 8px;
  padding: 24px;
}

.info-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 0;
  border-bottom: 1px solid var(--theme--border-color);
}

.info-row:last-child {
  border-bottom: none;
}

.label {
  font-weight: 600;
  color: var(--theme--foreground-subdued);
}

.value {
  font-weight: 500;
}

.status-badge {
  padding: 4px 12px;
  background: var(--theme--primary-background);
  color: var(--theme--primary);
  border-radius: 4px;
  font-size: 12px;
}

.actions {
  display: flex;
  gap: 12px;
}

.extracted-text {
  max-width: 500px;
  padding: 16px;
  background: var(--theme--background-subdued);
  border-radius: 4px;
  font-size: 12px;
  color: var(--theme--foreground-subdued);
  word-break: break-word;
}
</style>
