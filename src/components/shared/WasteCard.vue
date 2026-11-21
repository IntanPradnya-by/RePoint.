<script setup>
import { computed } from 'vue'
import BaseBadge from '../base/BaseBadge.vue'
import BaseButton from '../base/BaseButton.vue'
import { formatNumber } from '../../composables/useFormatters'

const props = defineProps({
  item: { type: Object, required: true },
  category: { type: Object, default: null }
})

defineEmits(['deposit'])

const hasPoints = computed(() => props.item.points !== null)
</script>

<template>
  <article class="waste-card">
    <div class="waste-image">
      <img :src="item.imageUrl" :alt="item.title" loading="lazy" />
    </div>
    <div class="waste-body">
      <div class="waste-meta">
        <BaseBadge tone="success">{{ category?.title }}</BaseBadge>
      </div>
      <h3 class="waste-title">{{ item.title }}</h3>
      <p class="waste-summary">{{ item.summary }}</p>

      <div class="waste-points">
        <template v-if="hasPoints">
          <span class="points-value num">{{ formatNumber(item.points) }} poin</span>
          <span class="points-unit">per {{ item.unit }}</span>
        </template>
        <span v-else class="points-pending">Nilai poin menunggu ketentuan sekolah</span>
      </div>

      <ul class="waste-highlights">
        <li v-for="highlight in item.highlights" :key="highlight">{{ highlight }}</li>
      </ul>

      <BaseButton variant="secondary" block @click="$emit('deposit', item)">Setorkan</BaseButton>
    </div>
  </article>
</template>

<style scoped>
.waste-card {
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  transition: transform 0.25s var(--ease), box-shadow 0.25s var(--ease);
}

.waste-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-hover);
}

.waste-image {
  aspect-ratio: 16 / 10;
  overflow: hidden;
  background: var(--neutral-100);
}

.waste-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.4s var(--ease);
}

.waste-card:hover .waste-image img {
  transform: scale(1.05);
}

.waste-body {
  display: flex;
  flex-direction: column;
  gap: 8px;
  flex: 1;
  padding: 20px;
}

.waste-title {
  font-size: 18px;
  margin-top: 4px;
}

.waste-summary {
  font-size: 14px;
  color: var(--text-muted);
}

.waste-points {
  display: flex;
  flex-wrap: wrap;
  align-items: baseline;
  gap: 4px 8px;
  padding: 12px 16px;
  margin-top: 4px;
  background: var(--primary-50);
  border-radius: var(--radius-md);
}

.points-value {
  font-size: 18px;
  font-weight: 700;
  color: var(--primary-700);
}

.points-unit {
  font-size: 14px;
  color: var(--text-muted);
}

.points-pending {
  font-size: 14px;
  font-weight: 600;
  color: var(--warning-text);
}

.waste-highlights {
  margin: 4px 0 8px;
  padding-left: 18px;
  font-size: 14px;
  color: var(--text-muted);
  display: grid;
  gap: 4px;
}

.waste-body :deep(.base-button) {
  margin-top: auto;
}
</style>
