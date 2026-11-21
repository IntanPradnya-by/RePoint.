<script setup>
import BaseBadge from '../base/BaseBadge.vue'
import EmptyState from './EmptyState.vue'
import {
  claimStatusInfo,
  formatDateTime,
  formatNumber,
  transactionStatusInfo,
  transactionTypeLabel
} from '../../composables/useFormatters'

defineProps({
  transactions: { type: Array, required: true },
  emptyTitle: { type: String, default: 'Belum ada transaksi' },
  emptyDescription: { type: String, default: '' }
})

function amountText(transaction) {
  if (transaction.type === 'setoran') {
    return `${formatNumber(transaction.weight)} kg`
  }
  const sign = transaction.type === 'penambahan' ? '+' : '-'
  return `${sign}${formatNumber(transaction.points)} poin`
}

function amountClass(transaction) {
  if (transaction.type === 'penambahan') return 'amount--plus'
  if (transaction.type === 'penukaran') return 'amount--minus'
  return 'amount--neutral'
}

function badgeFor(transaction) {
  if (transaction.type === 'penukaran' && transaction.claimStatus) {
    return claimStatusInfo(transaction.claimStatus)
  }
  return transactionStatusInfo(transaction.status)
}
</script>

<template>
  <ul v-if="transactions.length" class="tx-list">
    <li v-for="transaction in transactions" :key="transaction.id" class="tx-row">
      <div class="tx-main">
        <span class="tx-type">{{ transactionTypeLabel(transaction.type) }}</span>
        <h3 class="tx-title">{{ transaction.title }}</h3>
        <p class="tx-date">{{ formatDateTime(transaction.date) }}</p>
      </div>

      <div class="tx-meta">
        <span :class="['tx-amount', 'num', amountClass(transaction)]">{{ amountText(transaction) }}</span>
        <BaseBadge :tone="badgeFor(transaction).tone">
          {{ badgeFor(transaction).label }}
        </BaseBadge>
      </div>

      <div v-if="$slots.actions" class="tx-actions">
        <slot name="actions" :transaction="transaction" />
      </div>
    </li>
  </ul>
  <EmptyState v-else :title="emptyTitle" :description="emptyDescription" />
</template>

<style scoped>
.tx-list {
  display: grid;
  gap: var(--space-2);
  margin: 0;
  padding: 0;
  list-style: none;
}

.tx-row {
  display: grid;
  gap: var(--space-2);
  padding: var(--space-3) var(--space-3);
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius-md);
  box-shadow: var(--shadow-sm);
  transition: border-color 0.2s var(--ease), box-shadow 0.2s var(--ease);
}

.tx-row:hover {
  border-color: var(--primary-300);
  box-shadow: var(--shadow-md);
}

.tx-main {
  display: grid;
  gap: 6px;
  min-width: 0;
}

.tx-type {
  font-size: 12px;
  font-weight: 600;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.tx-title {
  font-size: 16px;
  overflow-wrap: anywhere;
}

.tx-date {
  font-size: 13px;
  color: var(--text-muted);
}

.tx-meta {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-1);
}

.tx-amount {
  font-size: 16px;
  font-weight: 700;
}

.amount--plus {
  color: var(--secondary-700);
}

.amount--minus {
  color: var(--accent-700);
}

.amount--neutral {
  color: var(--text);
}

.tx-actions {
  display: flex;
  flex-wrap: wrap;
  gap: var(--space-1);
}

@media (min-width: 720px) {
  .tx-row {
    grid-template-columns: 1fr auto;
    align-items: center;
  }

  .tx-actions {
    grid-column: 1 / -1;
  }
}
</style>
