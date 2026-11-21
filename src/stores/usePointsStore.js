import { computed } from 'vue'
import { useTransactionStore } from './useTransactionStore'

const { transactions } = useTransactionStore()

function sumPoints(type) {
  return transactions.value
    .filter((transaction) => transaction.type === type && transaction.status !== 'ditolak')
    .reduce((total, transaction) => total + transaction.points, 0)
}

const totalEarned = computed(() => sumPoints('penambahan'))
const totalSpent = computed(() => sumPoints('penukaran'))
const balance = computed(() => totalEarned.value - totalSpent.value)

const totalWasteKg = computed(() =>
  transactions.value
    .filter((transaction) => transaction.type === 'setoran' && transaction.status === 'berhasil')
    .reduce((total, transaction) => total + transaction.weight, 0)
)

export function usePointsStore() {
  return {
    balance,
    totalEarned,
    totalSpent,
    totalWasteKg
  }
}
