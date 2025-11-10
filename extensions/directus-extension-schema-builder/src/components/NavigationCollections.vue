<template>
  <v-list nav>
    <v-list-item
      v-for="collection in collections"
      :key="collection.collection"
      :active="active?.collection === collection.collection"
      :value="collection.collection"
      clickable
      @click="$emit('select', collection)"
    >
      <v-list-item-icon>
        <v-icon :name="collection.meta.icon || 'box'" />
      </v-list-item-icon>

      <v-list-item-content>
        <v-text-overflow :text="collection.collection" />
        <div v-if="collection.meta.singleton" class="collection-badge">
          <v-badge>Singleton</v-badge>
        </div>
      </v-list-item-content>

      <v-list-item-hint>
        <span class="field-count">{{ collection.fields.length }} fields</span>
      </v-list-item-hint>
    </v-list-item>

    <v-divider v-if="collections.length > 0" />

    <v-list-item clickable @click="$emit('new')">
      <v-list-item-icon>
        <v-icon name="add" />
      </v-list-item-icon>
      <v-list-item-content>New Collection</v-list-item-content>
    </v-list-item>
  </v-list>
</template>

<script setup lang="ts">
import type { CollectionSchema } from '../types/schema';

defineProps<{
  collections: CollectionSchema[];
  active: CollectionSchema | null;
}>();

defineEmits<{
  select: [collection: CollectionSchema];
  new: [];
}>();
</script>

<style scoped>
.collection-badge {
  margin-top: 4px;
}

.field-count {
  font-size: 12px;
  color: var(--foreground-subdued);
}
</style>
