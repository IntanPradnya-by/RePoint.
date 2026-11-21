import { computed, ref } from 'vue'
import { rewards as catalogRewards } from '../data/rewards'
import { supabase } from '../lib/supabase'
import { useTransactionStore } from './useTransactionStore'

const stockById = ref({})

const rewards = computed(() =>
  catalogRewards.map((reward) => ({
    ...reward,
    price: stockById.value[reward.id]?.price ?? 0,
    stock: stockById.value[reward.id]?.stock ?? 0,
    isAvailable: stockById.value[reward.id]?.isAvailable ?? false
  }))
)

export function getRewardAvailability(reward, balance) {
  if (!reward.isAvailable || reward.stock <= 0) return 'habis'
  if (balance < reward.price) return 'poin-kurang'
  return 'tersedia'
}

async function loadRewardStock() {
  const { data, error } = await supabase
    .from('reward_stock')
    .select('reward_id, price, stock, is_available')
  if (error) throw error
  stockById.value = Object.fromEntries(
    data.map((row) => [
      row.reward_id,
      { price: row.price, stock: row.stock, isAvailable: row.is_available }
    ])
  )
}

export function useRewardStore() {
  const { loadTransactions } = useTransactionStore()

  function findReward(id) {
    return rewards.value.find((reward) => reward.id === id)
  }

  async function redeemReward(rewardId) {
    const { data, error } = await supabase.rpc('redeem_reward', { p_reward_id: rewardId })
    if (error) throw error
    await Promise.all([loadTransactions(), loadRewardStock()])
    return data
  }

  return {
    rewards,
    findReward,
    redeemReward,
    loadRewardStock
  }
}
