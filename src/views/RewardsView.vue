<script setup>
import { computed, ref } from 'vue'
import { useRouter } from 'vue-router'
import BaseAlert from '../components/base/BaseAlert.vue'
import BaseButton from '../components/base/BaseButton.vue'
import BaseCard from '../components/base/BaseCard.vue'
import BaseModal from '../components/base/BaseModal.vue'
import RewardCard from '../components/shared/RewardCard.vue'
import { formatNumber } from '../composables/useFormatters'
import { usePointsStore } from '../stores/usePointsStore'
import { getRewardAvailability, useRewardStore } from '../stores/useRewardStore'

const router = useRouter()
const { balance } = usePointsStore()
const { rewards, redeemReward } = useRewardStore()

const selectedReward = ref(null)
const redeemError = ref('')
const redeeming = ref(false)

const remainingBalance = computed(() =>
  selectedReward.value ? balance.value - selectedReward.value.price : balance.value
)

function openRedeem(reward) {
  selectedReward.value = reward
  redeemError.value = ''
}

function closeRedeem() {
  selectedReward.value = null
}

async function confirmRedeem() {
  redeeming.value = true
  redeemError.value = ''
  try {
    await redeemReward(selectedReward.value.id)
  } catch (cause) {
    console.error('redeem failed', cause)
    redeemError.value = 'Penukaran belum berhasil. Pastikan poin dan stok masih cukup, lalu coba lagi.'
    return
  } finally {
    redeeming.value = false
  }
  closeRedeem()
  router.push({ name: 'claim' })
}

function canRedeem(reward) {
  return getRewardAvailability(reward, balance.value) === 'tersedia'
}
</script>

<template>
  <div class="container page">
    <header class="page-header">
      <h1 class="page-title">Katalog Reward</h1>
      <p class="page-subtitle">Tukar poin hasil setoran sampahmu dengan hadiah pilihan. Stok terbatas.</p>
    </header>

    <BaseCard class="balance-card">
      <div>
        <p class="balance-label">Saldo poin kamu</p>
        <p class="balance-value num">{{ formatNumber(balance) }} <span>poin</span></p>
      </div>
      <p class="balance-note">Poin bertambah otomatis setiap kali kamu menyetorkan sampah.</p>
    </BaseCard>

    <div class="grid grid--cards reward-grid">
      <RewardCard
        v-for="reward in rewards"
        :key="reward.id"
        :reward="reward"
        :balance="balance"
        @redeem="openRedeem"
      />
    </div>

    <BaseModal :open="selectedReward !== null" title="Konfirmasi Penukaran" @close="closeRedeem">
      <div class="confirm">
        <p class="confirm-text">
          Kamu akan menukar <strong>{{ selectedReward?.name }}</strong> dengan
          <strong class="num">{{ formatNumber(selectedReward?.price ?? 0) }} poin</strong>.
        </p>
        <div class="confirm-summary">
          <span>Sisa saldo setelah penukaran</span>
          <strong class="num">{{ formatNumber(remainingBalance) }} poin</strong>
        </div>
        <p class="muted confirm-hint">Setelah ditukar, kode klaim akan dibuat untuk ditunjukkan saat mengambil hadiah.</p>
        <BaseAlert v-if="redeemError" tone="danger">{{ redeemError }}</BaseAlert>
      </div>

      <template #footer>
        <BaseButton variant="ghost" @click="closeRedeem">Batal</BaseButton>
        <BaseButton :disabled="!selectedReward || !canRedeem(selectedReward) || redeeming" @click="confirmRedeem">
          {{ redeeming ? 'Memproses...' : 'Ya, Tukar Sekarang' }}
        </BaseButton>
      </template>
    </BaseModal>
  </div>
</template>

<style scoped>
.balance-card {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-2);
  margin-bottom: var(--space-4);
  background: var(--primary-50);
  border-color: var(--primary-100);
}

.balance-label {
  font-size: 14px;
  font-weight: 600;
  color: var(--text-muted);
}

.balance-value {
  margin-top: 4px;
  font-size: 32px;
  font-weight: 700;
  color: var(--primary-700);
}

.balance-value span {
  font-size: 16px;
  color: var(--text-muted);
}

.balance-note {
  max-width: 320px;
  font-size: 14px;
  color: var(--text-muted);
}

.confirm {
  display: grid;
  gap: var(--space-2);
}

.confirm-text {
  line-height: 1.5;
}

.confirm-summary {
  display: flex;
  justify-content: space-between;
  gap: var(--space-2);
  padding: var(--space-2) var(--space-3);
  background: var(--neutral-50);
  border-radius: var(--radius-md);
  font-size: 14px;
}

.confirm-hint {
  font-size: 14px;
}
</style>
