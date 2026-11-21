import { computed, ref } from 'vue'
import { supabase } from '../lib/supabase'

const transactions = ref([])

const sortedTransactions = computed(() =>
  [...transactions.value].sort((a, b) => Date.parse(b.date) - Date.parse(a.date))
)

export function toTransaction(row) {
  return {
    id: row.id,
    date: row.created_at,
    type: row.type,
    refId: row.ref_id,
    title: row.title,
    weight: row.weight === null ? null : Number(row.weight),
    points: row.points,
    status: row.status,
    claimCode: row.claim_code,
    claimStatus: row.claim_status,
    studentName: row.profiles?.name ?? null
  }
}

export function useTransactionStore() {
  function transactionsByType(type) {
    return sortedTransactions.value.filter((transaction) => transaction.type === type)
  }

  async function loadTransactions() {
    const { data, error } = await supabase
      .from('transactions')
      .select('*')
      .order('created_at', { ascending: false })
    if (error) throw error
    transactions.value = data.map(toTransaction)
  }

  function clearTransactions() {
    transactions.value = []
  }

  async function addDeposit(item, weight) {
    const { error } = await supabase.rpc('submit_deposit', {
      p_item_id: item.id,
      p_weight: weight
    })
    if (error) throw error
    await loadTransactions()
  }

  return {
    transactions: sortedTransactions,
    transactionsByType,
    loadTransactions,
    clearTransactions,
    addDeposit
  }
}
