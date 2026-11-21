<script setup>
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { RouterLink, useRoute, useRouter } from 'vue-router'
import { usePointsStore } from '../../stores/usePointsStore'
import { useAuthStore } from '../../stores/useAuthStore'
import { formatNumber } from '../../composables/useFormatters'
import BaseButton from '../base/BaseButton.vue'

const router = useRouter()
const route = useRoute()
const { balance } = usePointsStore()
const auth = useAuthStore()
const { isLoggedIn, userName } = auth
const menuOpen = ref(false)
const dropdownOpen = ref(false)
const dropdownRoot = ref(null)

const menuDropdownLinks = [
  { to: '/waste', label: 'Katalog Sampah' },
  { to: '/rewards', label: 'Reward' },
  { to: '/wallet', label: 'Dompet Poin' },
  { to: '/history', label: 'Riwayat' }
]

const dropdownLinks = computed(() => {
  if (!isLoggedIn.value) return []
  return menuDropdownLinks
})

const dropdownActive = computed(() => menuDropdownLinks.some((link) => router.currentRoute.value.path.startsWith(link.to)))

const initials = computed(() =>
  userName.value
    ? userName.value
        .split(' ')
        .map((part) => part[0])
        .join('')
        .slice(0, 2)
        .toUpperCase()
    : ''
)

async function handleSignOut() {
  menuOpen.value = false
  dropdownOpen.value = false
  try {
    await auth.signOut()
  } catch (cause) {
    console.error('sign out failed', cause)
    return
  }
  router.replace({ name: 'login' })
}

function toggleDropdown() {
  dropdownOpen.value = !dropdownOpen.value
}

function closeMenus() {
  menuOpen.value = false
  dropdownOpen.value = false
}

function onDocumentClick(event) {
  if (dropdownOpen.value && dropdownRoot.value && !dropdownRoot.value.contains(event.target)) {
    dropdownOpen.value = false
  }
}

function onKeydown(event) {
  if (event.key === 'Escape') closeMenus()
}

watch(() => route.fullPath, closeMenus)

onMounted(() => {
  document.addEventListener('click', onDocumentClick)
  document.addEventListener('keydown', onKeydown)
})

onBeforeUnmount(() => {
  document.removeEventListener('click', onDocumentClick)
  document.removeEventListener('keydown', onKeydown)
})
</script>

<template>
  <header class="app-header">
    <div class="container header-inner">
      <RouterLink to="/" class="brand" aria-label="RePoint - Dashboard">
        <span class="brand-mark">R</span>
        <span class="brand-name">RePoint</span>
      </RouterLink>

      <nav class="nav-desktop" aria-label="Navigasi utama">
        <RouterLink to="/" class="nav-link" @click="closeMenus">Dashboard</RouterLink>
        <div v-if="isLoggedIn" ref="dropdownRoot" class="dropdown">
          <button
            type="button"
            class="nav-link dropdown-toggle"
            :class="{ 'dropdown-toggle--active': dropdownActive }"
            :aria-expanded="dropdownOpen ? 'true' : 'false'"
            aria-haspopup="menu"
            aria-controls="desktop-menu-panel"
            @click="toggleDropdown"
          >
            Menu
            <svg class="dropdown-caret" :class="{ 'dropdown-caret--open': dropdownOpen }" viewBox="0 0 24 24" aria-hidden="true">
              <path d="M6 9l6 6 6-6" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </button>
          <div v-show="dropdownOpen" id="desktop-menu-panel" class="dropdown-panel" role="menu">
            <RouterLink
              v-for="link in dropdownLinks"
              :key="link.to"
              :to="link.to"
              class="dropdown-item"
              role="menuitem"
              @click="closeMenus"
            >
              {{ link.label }}
            </RouterLink>
          </div>
        </div>
        <RouterLink to="/about" class="nav-link" @click="closeMenus">Tentang</RouterLink>
      </nav>

      <div class="header-actions">
        <template v-if="isLoggedIn">
          <RouterLink to="/wallet" class="balance-chip" aria-label="Saldo poin">
            <span class="balance-label">Saldo</span>
            <span class="balance-value num">{{ formatNumber(balance) }} poin</span>
          </RouterLink>
          <div class="profile" :title="userName">
            <span class="avatar">{{ initials }}</span>
            <span class="profile-name">{{ userName }}</span>
          </div>
          <BaseButton class="header-signout" variant="ghost" size="sm" @click="handleSignOut">Keluar</BaseButton>
        </template>
        <BaseButton v-else to="/login" size="sm">Masuk</BaseButton>
        <button
          type="button"
          class="menu-toggle"
          :aria-expanded="menuOpen ? 'true' : 'false'"
          aria-controls="mobile-nav"
          :aria-label="menuOpen ? 'Tutup menu' : 'Buka menu'"
          @click="menuOpen = !menuOpen"
        >
          <span class="menu-bar" />
          <span class="menu-bar" />
          <span class="menu-bar" />
        </button>
      </div>
    </div>

    <nav v-show="menuOpen" id="mobile-nav" class="nav-mobile" aria-label="Navigasi seluler">
      <div class="container nav-mobile-list">
        <RouterLink v-if="!isLoggedIn" to="/" class="nav-link" @click="closeMenus">Beranda</RouterLink>
        <RouterLink v-else to="/" class="nav-link" @click="closeMenus">Dashboard</RouterLink>

        <template v-if="isLoggedIn">
          <button
            type="button"
            class="nav-link nav-collapse"
            :aria-expanded="menuOpen && dropdownOpen ? 'true' : 'false'"
            @click="toggleDropdown"
          >
            Menu
            <svg class="dropdown-caret" :class="{ 'dropdown-caret--open': dropdownOpen }" viewBox="0 0 24 24" aria-hidden="true">
              <path d="M6 9l6 6 6-6" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </button>
          <template v-if="dropdownOpen">
            <RouterLink
              v-for="link in dropdownLinks"
              :key="link.to"
              :to="link.to"
              class="nav-link nav-sub-link"
              @click="closeMenus"
            >
              {{ link.label }}
            </RouterLink>
          </template>
        </template>

        <RouterLink to="/about" class="nav-link" @click="closeMenus">Tentang</RouterLink>
        <BaseButton v-if="isLoggedIn" variant="ghost" @click="handleSignOut">Keluar</BaseButton>
      </div>
    </nav>
  </header>
</template>

<style scoped>
.app-header {
  position: sticky;
  top: 0;
  z-index: 50;
  background: var(--surface);
  border-bottom: 1px solid var(--border);
  box-shadow: var(--shadow-sm);
}

.header-inner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  height: var(--header-height);
}

.brand {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  flex-shrink: 0;
}

.brand-mark {
  display: grid;
  place-items: center;
  width: 36px;
  height: 36px;
  border-radius: 10px;
  background: var(--brand-gradient);
  color: var(--neutral-0);
  font-weight: 700;
  font-size: 18px;
  transition: transform 0.3s var(--ease);
}

.brand:hover .brand-mark {
  transform: rotate(-8deg);
}

.brand-name {
  font-size: 20px;
  font-weight: 700;
  color: var(--primary-800);
}

.nav-desktop {
  display: none;
  align-items: center;
  gap: 4px;
}

.dropdown {
  position: relative;
}

.dropdown-toggle {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  border: none;
  background: transparent;
  cursor: pointer;
  font: inherit;
}

.dropdown-toggle--active {
  background: var(--primary-100);
  color: var(--primary-800);
}

.dropdown-caret {
  width: 14px;
  height: 14px;
  transition: transform 0.2s var(--ease);
}

.dropdown-caret--open {
  transform: rotate(180deg);
}

.dropdown-panel {
  position: absolute;
  top: calc(100% + 6px);
  left: 0;
  min-width: 200px;
  padding: 8px;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius-md);
  box-shadow: var(--shadow-md);
  animation: fade-up 0.18s var(--ease) both;
}

.dropdown-item {
  display: block;
  padding: 10px 14px;
  border-radius: var(--radius-sm);
  font-size: 14px;
  font-weight: 600;
  color: var(--text);
  transition: background 0.15s var(--ease), color 0.15s var(--ease);
}

.dropdown-item:hover {
  background: var(--primary-50);
  color: var(--primary-800);
}

.dropdown-item.router-link-active {
  background: var(--primary-100);
  color: var(--primary-800);
}

.nav-link {
  padding: 8px 12px;
  border-radius: var(--radius-pill);
  font-size: 15px;
  font-weight: 600;
  color: var(--text-muted);
  transition: background 0.2s var(--ease), color 0.2s var(--ease);
}

.nav-link:hover {
  background: var(--primary-50);
  color: var(--primary-800);
}

.nav-link.router-link-active {
  background: var(--primary-100);
  color: var(--primary-800);
}

.header-actions {
  display: flex;
  align-items: center;
  gap: 12px;
}

.balance-chip {
  display: flex;
  flex-direction: column;
  padding: 4px 14px;
  border-radius: var(--radius-md);
  background: var(--primary-50);
  border: 1px solid var(--primary-100);
  transition: border-color 0.2s var(--ease);
}

.balance-chip:hover {
  border-color: var(--primary-500);
}

.balance-label {
  font-size: 11px;
  font-weight: 600;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.04em;
}

.balance-value {
  font-size: 15px;
  font-weight: 700;
  color: var(--primary-700);
}

.profile {
  display: flex;
  align-items: center;
  gap: 8px;
}

.avatar {
  display: grid;
  place-items: center;
  width: 36px;
  height: 36px;
  border-radius: var(--radius-pill);
  background: var(--brand-gradient);
  color: var(--neutral-0);
  font-size: 13px;
  font-weight: 700;
}

.profile-name {
  font-size: 14px;
  font-weight: 600;
}

.menu-toggle {
  display: flex;
  flex-direction: column;
  justify-content: center;
  gap: 4px;
  width: 44px;
  height: 44px;
  padding: 0 10px;
  flex-shrink: 0;
  border: 1px solid var(--border);
  border-radius: var(--radius-sm);
  background: var(--surface);
  cursor: pointer;
}

.menu-bar {
  display: block;
  height: 2px;
  border-radius: 2px;
  background: var(--text);
}

.nav-mobile {
  border-top: 1px solid var(--border);
  background: var(--surface);
  box-shadow: var(--shadow-md);
}

.nav-mobile-list .nav-link,
.nav-mobile-list .nav-collapse {
  min-height: 48px;
}

.nav-mobile-list .base-button {
  margin-top: 8px;
}

.nav-mobile-list {
  display: grid;
  gap: 4px;
  padding-top: 8px;
  padding-bottom: 16px;
}

.nav-mobile-list .nav-link {
  padding: 12px 16px;
}

.nav-collapse {
  display: flex;
  align-items: center;
  justify-content: space-between;
  width: 100%;
  border: none;
  background: transparent;
  text-align: left;
  cursor: pointer;
  font: inherit;
}

.nav-sub-link {
  padding-left: 32px;
  font-weight: 500;
}

@media (max-width: 599px) {
  .header-inner {
    gap: 8px;
  }

  .header-actions {
    gap: 8px;
  }

  /* Keluar already lives inside the mobile menu; hiding it here keeps the
     hamburger button fully visible and tappable on small screens. */
  .header-signout {
    display: none;
  }

  .brand-name {
    font-size: 18px;
  }

  .balance-chip {
    padding: 4px 8px;
    min-width: 0;
  }

  .balance-label {
    display: none;
  }

  .balance-value {
    font-size: 12px;
    white-space: nowrap;
  }
}

@media (max-width: 479px) {
  .balance-chip {
    padding: 4px 10px;
  }

  .balance-value {
    font-size: 13px;
  }

  .profile {
    display: none;
  }
}

@media (min-width: 960px) {
  .nav-desktop {
    display: flex;
  }

  .menu-toggle {
    display: none;
  }

  .nav-mobile {
    display: none;
  }
}

@media (min-width: 960px) and (max-width: 1180px) {
  .profile-name {
    display: none;
  }
}
</style>
