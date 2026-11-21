<script setup>
import { computed } from 'vue'
import BaseBadge from '../base/BaseBadge.vue'
import BaseButton from '../base/BaseButton.vue'
import { formatNumber } from '../../composables/useFormatters'
import { getRewardAvailability } from '../../stores/useRewardStore'

const props = defineProps({
  reward: { type: Object, required: true },
  balance: { type: Number, required: true }
})

defineEmits(['redeem'])

const availability = computed(() => getRewardAvailability(props.reward, props.balance))

const statusInfo = computed(() => {
  if (availability.value === 'habis') return { label: 'Stok habis', tone: 'danger', action: 'Stok Habis' }
  if (availability.value === 'poin-kurang') return { label: 'Poin belum cukup', tone: 'warning', action: 'Poin Belum Cukup' }
  return { label: 'Tersedia', tone: 'success', action: 'Tukar Sekarang' }
})
</script>

<template>
  <article class="reward-card">
    <div class="reward-image">
      <img :src="reward.imageUrl" :alt="reward.name" loading="lazy" />
    </div>
    <div class="reward-body">
      <div class="reward-head">
        <h3 class="reward-title">{{ reward.name }}</h3>
        <BaseBadge :tone="statusInfo.tone">{{ statusInfo.label }}</BaseBadge>
      </div>
      <p class="reward-description">{{ reward.description }}</p>

      <div class="reward-facts">
        <div>
          <span class="fact-label">Harga</span>
          <span class="fact-value num">{{ formatNumber(reward.price) }} poin</span>
        </div>
        <div>
          <span class="fact-label">Stok</span>
          <span class="fact-value num">{{ reward.stock }}</span>
        </div>
      </div>

      <BaseButton block :disabled="availability !== 'tersedia'" @click="$emit('redeem', reward)">
        {{ statusInfo.action }}
      </BaseButton>
    </div>
  </article>
</template>

<style scoped>
.reward-card {
  display: flex;
  flex-direction: column;
  overflow: hidden;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  transition: transform 0.25s var(--ease), box-shadow 0.25s var(--ease);
}

.reward-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-hover);
}

.reward-image {
  aspect-ratio: 16 / 10;
  overflow: hidden;
  background: var(--neutral-100);
}

.reward-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.4s var(--ease);
}

.reward-card:hover .reward-image img {
  transform: scale(1.05);
}

.reward-body {
  display: flex;
  flex-direction: column;
  gap: 12px;
  flex: 1;
  padding: 20px;
}

.reward-head {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 8px;
  flex-wrap: wrap;
}

.reward-title {
  font-size: 18px;
}

.reward-description {
  font-size: 14px;
  color: var(--text-muted);
}

.reward-facts {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 8px;
  padding: 12px 16px;
  background: var(--neutral-50);
  border-radius: var(--radius-md);
}

.reward-facts > div {
  display: grid;
  gap: 2px;
}

.fact-label {
  font-size: 12px;
  color: var(--text-muted);
}

.fact-value {
  font-weight: 700;
  color: var(--text);
}

.reward-body :deep(.base-button) {
  margin-top: auto;
}
</style>
