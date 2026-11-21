<script setup>
import { computed } from 'vue'
import BaseCard from '../components/base/BaseCard.vue'
import TransactionList from '../components/shared/TransactionList.vue'
import { formatNumber } from '../composables/useFormatters'
import { usePointsStore } from '../stores/usePointsStore'
import { useTransactionStore } from '../stores/useTransactionStore'

const { balance, totalEarned, totalSpent, totalWasteKg } = usePointsStore()
const { transactions } = useTransactionStore()

const ledger = computed(() =>
  transactions.value.filter((transaction) => transaction.type !== 'setoran' && transaction.status !== 'ditolak')
)

const spentRatio = computed(() => {
  if (totalEarned.value === 0) return 0
  return Math.min(100, Math.round((totalSpent.value / totalEarned.value) * 100))
})
</script>

<template>
  <div class="container page">
    <header class="page-header">
      <h1 class="page-title">Dompet Poin</h1>
      <p class="page-subtitle">Pantau saldo, pemasukan, dan pengeluaran poin dari setiap setoran sampahmu.</p>
    </header>

    <BaseCard class="balance-hero">
      <p class="hero-label">Total saldo</p>
      <p class="hero-value num">{{ formatNumber(balance) }} <span>poin</span></p>
      <p class="hero-note">Saldo dihitung dari poin yang diperoleh dikurangi poin yang sudah ditukar.</p>
    </BaseCard>

    <section class="grid grid--3 summary-grid">
      <BaseCard>
        <p class="stat-label">Total poin diperoleh</p>
        <p class="stat-value income num">+{{ formatNumber(totalEarned) }}</p>
      </BaseCard>
      <BaseCard>
        <p class="stat-label">Total poin digunakan</p>
        <p class="stat-value expense num">-{{ formatNumber(totalSpent) }}</p>
      </BaseCard>
      <BaseCard>
        <p class="stat-label">Total sampah terkumpul</p>
        <p class="stat-value num">{{ formatNumber(totalWasteKg) }} kg</p>
      </BaseCard>
    </section>

    <section class="section">
      <h2 class="section-title">Ringkasan pemasukan dan pengeluaran</h2>
      <BaseCard>
        <div class="flow-row">
          <span>Pemasukan</span>
          <strong class="num">{{ formatNumber(totalEarned) }} poin</strong>
        </div>
        <div class="flow-row">
          <span>Pengeluaran</span>
          <strong class="num">{{ formatNumber(totalSpent) }} poin</strong>
        </div>
        <div class="flow-bar" role="img" :aria-label="`${spentRatio} persen poin sudah ditukar`">
          <span class="flow-bar-fill" :style="{ width: `${spentRatio}%` }" />
        </div>
        <p class="muted flow-caption">{{ spentRatio }}% dari poin yang diperoleh sudah ditukar dengan reward.</p>
      </BaseCard>
    </section>

    <section class="section">
      <h2 class="section-title">Riwayat perubahan saldo</h2>
      <TransactionList
        :transactions="ledger"
        empty-title="Belum ada perubahan saldo"
        empty-description="Setorkan sampah dan poinnya langsung mengisi dompetmu."
      />
    </section>
  </div>
</template>

<style scoped>
.balance-hero {
  background: var(--brand-gradient);
  border-color: transparent;
  color: var(--neutral-0);
}

.hero-label {
  font-size: 14px;
  font-weight: 600;
  color: var(--primary-100);
}

.hero-value {
  margin-top: 6px;
  font-size: 40px;
  font-weight: 700;
  color: var(--neutral-0);
}

.hero-value span {
  font-size: 18px;
  color: var(--primary-100);
}

.hero-note {
  margin-top: 8px;
  font-size: 14px;
  color: var(--primary-100);
}

.summary-grid {
  margin-top: var(--space-4);
}

.stat-label {
  font-size: 14px;
  font-weight: 600;
  color: var(--text-muted);
}

.stat-value {
  margin-top: 6px;
  font-size: 28px;
  font-weight: 700;
  color: var(--text);
}

.income {
  color: var(--secondary-700);
}

.expense {
  color: var(--accent-700);
}

.flow-row {
  display: flex;
  justify-content: space-between;
  gap: var(--space-2);
  padding: var(--space-1) 0;
  font-size: 15px;
}

.flow-bar {
  height: 10px;
  margin-top: var(--space-2);
  overflow: hidden;
  background: var(--neutral-100);
  border-radius: var(--radius-pill);
}

.flow-bar-fill {
  display: block;
  height: 100%;
  background: var(--brand-gradient);
  border-radius: inherit;
  transition: width 0.6s var(--ease);
}

.flow-caption {
  margin-top: var(--space-2);
  font-size: 14px;
}
</style>
