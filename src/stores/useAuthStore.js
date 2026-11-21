import { computed, ref } from 'vue'
import { supabase } from '../lib/supabase'
import { useRewardStore } from './useRewardStore'
import { useTransactionStore } from './useTransactionStore'

const session = ref(null)
const profile = ref(null)
let initPromise = null

const isLoggedIn = computed(() => session.value !== null)
const userName = computed(() => profile.value?.name ?? '')

async function loadProfile(userId) {
  const { data, error } = await supabase
    .from('profiles')
    .select('id, name')
    .eq('id', userId)
    .maybeSingle()
  if (error) {
    console.error('profile load failed', error)
    profile.value = null
    return
  }
  profile.value = data
}

export function useAuthStore() {
  const { clearTransactions, loadTransactions } = useTransactionStore()
  const { loadRewardStock } = useRewardStore()

  function initialize() {
    if (!initPromise) {
      initPromise = (async () => {
        const { data } = await supabase.auth.getSession()
        session.value = data.session
        if (data.session) await loadProfile(data.session.user.id)

        supabase.auth.onAuthStateChange((_event, nextSession) => {
          (async () => {
            session.value = nextSession
            if (nextSession) {
              await loadProfile(nextSession.user.id)
            } else {
              profile.value = null
              clearTransactions()
            }
          })()
        })
      })()
    }
    return initPromise
  }

  async function signIn(email, password) {
    const { data, error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) throw error
    session.value = data.session
    await loadProfile(data.user.id)
  }

  async function signUp(name, email, password) {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: { data: { name } }
    })
    if (error) throw error
    if (!data.session) throw new Error('Konfirmasi email belum diaktifkan.')
    session.value = data.session
    await loadProfile(data.user.id)
  }

  async function signOut() {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
    session.value = null
    profile.value = null
    clearTransactions()
  }

  async function refreshUserData() {
    try {
      await Promise.all([loadTransactions(), loadRewardStock()])
    } catch (cause) {
      console.error('user data refresh failed', cause)
    }
  }

  return {
    session,
    isLoggedIn,
    userName,
    initialize,
    signIn,
    signUp,
    signOut,
    refreshUserData
  }
}
