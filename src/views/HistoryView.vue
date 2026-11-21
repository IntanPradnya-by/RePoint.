<script setup>
import { computed, ref } from 'vue'
import BaseAlert from '../components/base/BaseAlert.vue'
import BaseBadge from '../components/base/BaseBadge.vue'
import BaseButton from '../components/base/BaseButton.vue'
import BaseCard from '../components/base/BaseCard.vue'
import EmptyState from '../components/shared/EmptyState.vue'
import TransactionList from '../components/shared/TransactionList.vue'
import {
  claimStatusInfo,
  formatDateTime,
  formatNumber
} from '../composables/useFormatters'
import { rewards as rewardCatalog } from '../data/rewards'
import { useTransactionStore } from '../stores/useTransactionStore'

const filters = [
  { value: 'semua', label: 'Semua' },
  { value: 'setoran', label: 'Setoran sampah' },
  { value: 'penambahan', label: 'Penambahan poin' },
  { value: 'penukaran', label: 'Penukaran reward' }
]

const activeFilter = ref('semua')
const { transactions, transactionsByType } = useTransactionStore()

const filteredTransactions = computed(() =>
  activeFilter.value === 'semua' ? transactions.value : transactionsByType(activeFilter.value)
)

const redemptions = computed(() => transactionsByType('penukaran'))
const totalRedeemedPoints = computed(() =>
  redemptions.value.reduce((total, redemption) => total + redemption.points, 0)
)

const rewardImageById = Object.fromEntries(
  rewardCatalog.map((reward) => [reward.id, reward.imageUrl])
)

function rewardImage(refId) {
  return rewardImageById[refId] ?? null
}

function summaryOf(redemptions) {
  const total = redemptions.length
  const done = redemptions.filter((redemption) => redemption.claimStatus === 'selesai').length
  if (total > 0 && done === total) {
    return `Semua ${total} penukaran sudah selesai. Terima kasih sudah memilah sampah!`
  }
  if (total > 0 && done > 0) {
    return `${done} dari ${total} penukaran sudah selesai, sisanya menunggu diambil.`
  }
  if (total > 0) {
    return `${total} penukaran menunggu diambil. Lihat kode klaimnya di halaman Klaim Reward.`
  }
  return ''
}
</script>

<template>
  <div class="container page">
    <header class="page-header">
      <h1 class="page-title">Riwayat Transaksi</h1>
      <p class="page-subtitle">
        Seluruh setoran, penambahan poin, dan penukaran reward kamu tercatat di sini. Poin dari setoran
        langsung masuk otomatis begitu setoran terkirim.
      </p>
    </header>

    <section v-if="redemptions.length" class="redeem-section">
      <div class="section-head">
        <h2 class="section-title">Reward yang sudah ditukarkan</h2>
        <BaseBadge tone="info" class="redeem-count">
          {{ redemptions.length }} penukaran | {{ formatNumber(totalRedeemedPoints) }} poin
        </BaseBadge>
      </div>

      <BaseAlert tone="info" class="redeem-summary">{{ summaryOf(redemptions) }}</BaseAlert>

      <div class="redeem-grid">
        <BaseCard v-for="redemption in redemptions" :key="redemption.id" hoverable class="redeem-card">
          <div class="redeem-top">
            <img
              v-if="rewardImage(redemption.refId)"
              :src="rewardImage(redemption.refId)"
              :alt="redemption.title"
              loading="lazy"
              class="redeem-image"
            />
            <div v-else class="redeem-image redeem-image--fallback" aria-hidden="true">🎁</div>
            <div class="redeem-info">
              <h3 class="redeem-title">{{ redemption.title }}</h3>
              <p class="redeem-date">{{ formatDateTime(redemption.date) }}</p>
              <BaseBadge :tone="claimStatusInfo(redemption.claimStatus).tone">
                {{ claimStatusInfo(redemption.claimStatus).label }}
              </BaseBadge>
            </div>
          </div>
          <div class="redeem-bottom">
            <span class="redeem-points num">-{{ formatNumber(redemption.points) }} poin</span>
            <p v-if="redemption.claimCode" class="redeem-code num">Kode: {{ redemption.claimCode }}</p>
          </div>
        </BaseCard>
      </div>
    </section>

    <EmptyState
      v-else
      title="Belum ada reward yang ditukar"
      description="Tukarkan poinmu dengan reward untuk melihat riwayat penukarannya di sini."
    >
      <BaseButton to="/rewards">Lihat Katalog Reward</BaseButton>
    </EmptyState>

    <section class="section">
      <h2 class="section-title">Semua transaksi</h2>
      <div class="chip-row filter-row" role="group" aria-label="Filter jenis transaksi">
        <button
          v-for="filter in filters"
          :key="filter.value"
          type="button"
          class="chip"
          :aria-pressed="activeFilter === filter.value"
          @click="activeFilter = filter.value"
        >
          {{ filter.label }}
        </button>
      </div>

      <TransactionList
        :transactions="filteredTransactions"
        empty-title="Tidak ada transaksi"
        empty-description="Belum ada transaksi untuk filter ini."
      />
    </section>
  </div>
</template>

<style scoped>
.redeem-section {
  margin-bottom: var(--space-4);
}

.redeem-count {
  align-self: center;
}

.redeem-summary {
  margin-bottom: var(--space-2);
}

.redeem-grid {
  display: grid;
  gap: var(--space-2);
}

@media (min-width: 720px) {
  .redeem-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

.redeem-card {
  display: grid;
  gap: var(--space-2);
}

.redeem-top {
  display: flex;
  align-items: center;
  gap: var(--space-2);
}

.redeem-image {
  width: 72px;
  height: 72px;
  flex-shrink: 0;
  object-fit: cover;
  border-radius: var(--radius-md);
}

.redeem-image--fallback {
  display: grid;
  place-items: center;
  font-size: 28px;
  background: var(--primary-50);
  border: 1px solid var(--primary-100);
}

.redeem-info {
  display: grid;
  gap: 6px;
  justify-items: start;
}

.redeem-title {
  font-size: 17px;
}

.redeem-date {
  font-size: 13px;
  color: var(--text-muted);
}

.redeem-bottom {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-1);
  padding-top: var(--space-2);
  border-top: 1px solid var(--border);
}

.redeem-points {
  font-size: 16px;
  font-weight: 700;
  color: var(--accent-700);
}

.redeem-code {
  font-size: 13px;
  color: var(--text-muted);
  letter-spacing: 0.06em;
}

.filter-row {
  margin-bottom: var(--space-2);
}
</style>
