<script setup>
import { computed, ref } from 'vue'
import BaseAlert from '../components/base/BaseAlert.vue'
import BaseBadge from '../components/base/BaseBadge.vue'
import BaseButton from '../components/base/BaseButton.vue'
import BaseCard from '../components/base/BaseCard.vue'
import EmptyState from '../components/shared/EmptyState.vue'
import { claimStatusInfo, formatDateTime, formatNumber } from '../composables/useFormatters'
import { supabase } from '../lib/supabase'
import { useRewardStore } from '../stores/useRewardStore'
import { useTransactionStore } from '../stores/useTransactionStore'

const { transactions, transactionsByType, loadTransactions } = useTransactionStore()
const { findReward } = useRewardStore()

const claims = computed(() => transactionsByType('penukaran'))
const activeClaim = computed(() => claims.value.find((claim) => claim.claimStatus !== 'selesai') ?? null)
const completing = ref(false)
const completeError = ref('')

const steps = [
  'Setelah menukar poin dengan reward, kode klaim otomatis dibuat.',
  'Simpan atau tunjukkan kode klaim saat mengambil hadiahmu.',
  'Ambil hadiahnya, lalu tekan "Sudah Diterima" untuk menutup klaim.'
]

function statusInfoOf(claim) {
  return claimStatusInfo(claim.claimStatus)
}

function rewardOf(claim) {
  return findReward(claim.refId)
}

async function markReceived(claim) {
  completing.value = true
  completeError.value = ''
  try {
    const { error } = await supabase.rpc('complete_own_claim', { p_id: claim.id })
    if (error) throw error
    await loadTransactions()
  } catch (cause) {
    console.error('complete claim failed', cause)
    completeError.value = 'Klaim belum bisa ditandai selesai. Coba lagi beberapa saat.'
  } finally {
    completing.value = false
  }
}
</script>

<template>
  <div class="container page">
    <header class="page-header">
      <h1 class="page-title">Klaim Reward</h1>
      <p class="page-subtitle">Simpan kode klaim reward kamu di sini, lalu tandai selesai setelah hadiah diterima.</p>
    </header>

    <EmptyState
      v-if="!claims.length"
      title="Belum ada klaim reward"
      description="Tukar poin kamu dengan reward untuk membuat kode klaim."
    >
      <BaseButton to="/rewards">Lihat Katalog Reward</BaseButton>
    </EmptyState>

    <template v-else>
      <BaseAlert v-if="completeError" tone="danger">{{ completeError }}</BaseAlert>

      <div class="claim-layout">
        <BaseCard v-for="claim in claims" :key="claim.id" class="claim-card">
          <div class="claim-reward">
            <img v-if="rewardOf(claim)" :src="rewardOf(claim).imageUrl" :alt="claim.title" class="claim-image" />
            <div>
              <p class="claim-label">Reward yang ditukar</p>
              <h2 class="claim-name">{{ claim.title }}</h2>
              <p class="claim-points num">{{ formatNumber(claim.points) }} poin</p>
            </div>
          </div>

          <div class="claim-code-box">
            <p class="claim-label">Kode klaim</p>
            <p class="claim-code num">{{ claim.claimCode }}</p>
          </div>

          <div class="claim-meta">
            <div>
              <p class="claim-label">Tanggal klaim</p>
              <p>{{ formatDateTime(claim.date) }}</p>
            </div>
            <div>
              <p class="claim-label">Status klaim</p>
              <BaseBadge :tone="statusInfoOf(claim).tone">{{ statusInfoOf(claim).label }}</BaseBadge>
            </div>
          </div>

          <div class="claim-action">
            <BaseAlert v-if="claim.claimStatus === 'selesai'" tone="success">
              Reward sudah diterima. Terima kasih sudah menjaga lingkungan!
            </BaseAlert>
            <BaseButton v-else block :disabled="completing" @click="markReceived(claim)">
              {{ completing ? 'Memproses...' : 'Sudah Diterima' }}
            </BaseButton>
          </div>
        </BaseCard>
      </div>

      <BaseCard>
        <h2 class="section-title">Cara menerima reward</h2>
        <ol class="steps">
          <li v-for="step in steps" :key="step">{{ step }}</li>
        </ol>
      </BaseCard>
    </template>
  </div>
</template>

<style scoped>
.claim-layout {
  display: grid;
  gap: var(--space-3);
}

@media (min-width: 900px) {
  .claim-layout {
    grid-template-columns: repeat(2, 1fr);
    align-items: start;
  }
}

.claim-card {
  display: grid;
  gap: var(--space-3);
}

.claim-reward {
  display: flex;
  align-items: center;
  gap: var(--space-2);
}

.claim-image {
  width: 88px;
  height: 88px;
  flex-shrink: 0;
  object-fit: cover;
  border-radius: var(--radius-md);
}

.claim-label {
  font-size: 13px;
  font-weight: 600;
  color: var(--text-muted);
}

.claim-name {
  margin-top: 6px;
  font-size: 22px;
}

.claim-points {
  margin-top: 6px;
  color: var(--primary-700);
  font-weight: 600;
}

.claim-code-box {
  padding: var(--space-4);
  text-align: center;
  background: var(--primary-50);
  border: 2px dashed var(--primary-300);
  border-radius: var(--radius-md);
}

.claim-code {
  margin-top: var(--space-1);
  font-size: clamp(1.5rem, 5vw, 2rem);
  font-weight: 700;
  letter-spacing: 0.12em;
  color: var(--primary-700);
}

.claim-meta {
  display: grid;
  gap: var(--space-2);
  grid-template-columns: 1fr 1fr;
}

.claim-meta > div {
  display: grid;
  gap: 6px;
  justify-items: start;
}

.steps {
  display: grid;
  gap: var(--space-2);
  margin: var(--space-2) 0 0;
  padding-left: 20px;
  color: var(--text);
}
</style>
