import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../stores/useAuthStore'

import HomeView from '../views/HomeView.vue'
import WasteView from '../views/WasteView.vue'
import RewardsView from '../views/RewardsView.vue'
import WalletView from '../views/WalletView.vue'
import HistoryView from '../views/HistoryView.vue'
import ClaimView from '../views/ClaimView.vue'
import AboutView from '../views/AboutView.vue'
import LoginView from '../views/LoginView.vue'
import NotFoundView from '../views/NotFoundView.vue'

const routes = [
  { path: '/', name: 'home', component: HomeView },
  { path: '/waste', name: 'waste', component: WasteView, meta: { requiresAuth: true } },
  { path: '/rewards', name: 'rewards', component: RewardsView, meta: { requiresAuth: true } },
  { path: '/wallet', name: 'wallet', component: WalletView, meta: { requiresAuth: true } },
  { path: '/history', name: 'history', component: HistoryView, meta: { requiresAuth: true } },
  { path: '/claim', name: 'claim', component: ClaimView, meta: { requiresAuth: true } },
  { path: '/about', name: 'about', component: AboutView },
  { path: '/login', name: 'login', component: LoginView, meta: { guestOnly: true } },
  {
    path: '/:pathMatch(.*)*',
    name: 'not-found',
    component: NotFoundView
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior() {
    return { top: 0 }
  }
})

router.beforeEach(async (to) => {
  const auth = useAuthStore()
  await auth.initialize()

  if (to.meta.guestOnly && auth.isLoggedIn.value) return { name: 'home' }
  if (to.meta.requiresAuth && !auth.isLoggedIn.value) {
    return { name: 'login', query: { redirect: to.fullPath } }
  }
  if (to.meta.requiresAuth) await auth.refreshUserData()
  return true
})

export default router
