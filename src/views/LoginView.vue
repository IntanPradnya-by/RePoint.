<script setup>
import { computed, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import BaseAlert from '../components/base/BaseAlert.vue'
import BaseButton from '../components/base/BaseButton.vue'
import BaseCard from '../components/base/BaseCard.vue'
import { useAuthStore } from '../stores/useAuthStore'

const route = useRoute()
const router = useRouter()
const auth = useAuthStore()

const mode = ref('masuk')
const name = ref('')
const email = ref('')
const password = ref('')
const submitting = ref(false)
const errorMessage = ref('')
const guestSession = ref(false)

const isSignUp = computed(() => mode.value === 'daftar')

const redirectTarget = computed(() => {
  const target = route.query.redirect
  return typeof target === 'string' && target.startsWith('/') && !target.startsWith('//') ? target : '/'
})

function setMode(nextMode) {
  mode.value = nextMode
  errorMessage.value = ''
}

// Prototype-friendly: accepts any input. A bare name like "budi" becomes budi@gmail.com
// so the demo works without a real email address.
function normalizeEmail(value) {
  const cleaned = value.trim().replace(/\s+/g, '').toLowerCase()
  if (!cleaned.includes('@')) return `${cleaned}@gmail.com`
  if (cleaned.endsWith('@')) return `${cleaned}gmail.com`
  return cleaned
}

function validate() {
  if (!email.value.trim()) {
    return 'Isi email atau nama panggilan kamu, contoh: budi.'
  }
  if (!password.value) {
    return 'Isi kata sandi kamu.'
  }
  if (isSignUp.value && password.value.length < 6) {
    return 'Untuk pendaftaran, kata sandi minimal 6 karakter (aturan sistem, bukan aturan prototype).'
  }
  if (isSignUp.value && !name.value.trim()) {
    return 'Isi nama lengkap kamu.'
  }
  return ''
}

async function submit() {
  errorMessage.value = validate()
  if (errorMessage.value) return

  submitting.value = true
  try {
    if (isSignUp.value) {
      await auth.signUp(name.value.trim(), normalizeEmail(email.value), password.value)
    } else {
      await auth.signIn(normalizeEmail(email.value), password.value)
    }
    router.replace(redirectTarget.value)
  } catch (cause) {
    console.error('auth failed', cause)
    const detail = cause?.message ?? ''
    if (detail.includes('Invalid login credentials')) {
      // Prototype-friendly fallback: if this demo account does not exist yet,
      // register it on the fly with the same credentials and continue.
      if (!isSignUp.value && emailLooksLikeDemo(normalizeEmail(email.value))) {
        try {
          await auth.signUp('Tamu Demo', normalizeEmail(email.value), password.value)
          router.replace(redirectTarget.value)
          return
        } catch (signUpCause) {
          console.error('demo signup fallback failed', signUpCause)
          errorMessage.value = 'Masuk demo belum berhasil. Coba lagi sebentar.'
          return
        }
      }
      errorMessage.value = 'Email atau kata sandi tidak sesuai. Coba lagi.'
    } else if (detail.includes('already registered')) {
      errorMessage.value = 'Email ini sudah terdaftar. Coba masuk saja.'
    } else {
      errorMessage.value = isSignUp.value
        ? 'Pendaftaran belum berhasil. Periksa data kamu lalu coba lagi.'
        : 'Masuk belum berhasil. Periksa koneksi lalu coba lagi.'
    }
  } finally {
    submitting.value = false
  }
}

function emailLooksLikeDemo(value) {
  return value.endsWith('@repoint.test')
}

// Guest session: enters RePoint instantly with a throwaway guest account,
// created on first use. No form filling needed.
async function guestLogin() {
  submitting.value = true
  errorMessage.value = ''
  guestSession.value = true
  try {
    const guests = ['Tamu RePoint', 'Tamu RePoint 2', 'Tamu RePoint 3']
    const suffix = Math.random().toString(36).slice(2, 8)
    try {
      await auth.signIn(`tamu.${suffix}@repoint.test`, 'tamu-repoint-2026')
    } catch {
      await auth.signUp(guests[0], `tamu.${suffix}@repoint.test`, 'tamu-repoint-2026')
    }
    router.replace(redirectTarget.value)
  } catch (cause) {
    console.error('guest login failed', cause)
    errorMessage.value = 'Masuk sebagai tamu belum berhasil. Coba lagi sebentar.'
  } finally {
    submitting.value = false
    guestSession.value = false
  }
}
</script>

<template>
  <div class="container page auth-page">
    <BaseCard class="auth-card">
      <header class="auth-header">
        <h1 class="page-title">{{ isSignUp ? 'Buat Akun Baru' : 'Masuk ke RePoint' }}</h1>
        <p class="page-subtitle">
          {{
            isSignUp
              ? 'Daftar untuk mulai menyetorkan sampah dan mengumpulkan poin.'
              : 'Masuk untuk melihat poin dan status setoran kamu.'
          }}
        </p>
      </header>

      <div class="chip-row auth-tabs" role="group" aria-label="Pilih mode akun">
        <button type="button" class="chip" :aria-pressed="!isSignUp" @click="setMode('masuk')">Masuk</button>
        <button type="button" class="chip" :aria-pressed="isSignUp" @click="setMode('daftar')">Daftar</button>
      </div>

      <form class="auth-form" novalidate @submit.prevent="submit">
        <label v-if="isSignUp" class="field">
          <span>Nama lengkap</span>
          <input v-model="name" type="text" autocomplete="name" maxlength="80" />
        </label>

        <label class="field">
          <span>Email atau nama bebas</span>
          <input
            v-model="email"
            type="text"
            :autocomplete="isSignUp ? 'off' : 'email'"
            inputmode="email"
            :placeholder="isSignUp ? 'Tulis apa saja, contoh: budi123' : 'username@gmail.com atau nama bebas'"
          />
        </label>

        <label class="field">
          <span>Kata sandi</span>
          <input
            v-model="password"
            type="password"
            :autocomplete="isSignUp ? 'new-password' : 'current-password'"
            :placeholder="isSignUp ? 'Minimal 6 karakter untuk daftar' : 'Kata sandi apa saja'"
          />
        </label>

        <BaseAlert v-if="errorMessage" tone="danger">{{ errorMessage }}</BaseAlert>

        <p v-if="isSignUp" class="muted auth-note">
          Ini mode prototype: kamu tidak perlu email asli. Tulis nama bebas dan kata sandi apa saja
          (minimal 6 karakter untuk pendaftaran).
        </p>

        <BaseButton type="submit" block :disabled="submitting">
          {{ submitting ? 'Memproses...' : isSignUp ? 'Daftar Sekarang' : 'Masuk' }}
        </BaseButton>

        <div class="auth-divider" role="separator" aria-label="atau">
          <span>atau</span>
        </div>

        <BaseButton block variant="secondary" :disabled="submitting" @click="guestLogin">
          {{ guestSession ? 'Menyiapkan sesi tamu...' : 'Masuk sebagai Tamu' }}
        </BaseButton>

        <p class="muted auth-note">
          Klik tombol di atas untuk mencoba RePoint langsung tanpa mendaftar. Semua fitur bisa dicoba:
          setorkan sampah, kumpulkan poin, dan tukar reward.
        </p>
      </form>
    </BaseCard>
  </div>
</template>

<style scoped>
.auth-page {
  display: grid;
  place-items: center;
  min-height: calc(100vh - var(--header-height) - 120px);
}

.auth-card {
  width: 100%;
  max-width: 440px;
  display: grid;
  gap: var(--space-3);
}

.auth-header {
  display: grid;
  gap: 8px;
}

.auth-tabs {
  margin-bottom: 0;
}

.auth-form {
  display: grid;
  gap: var(--space-2);
}

.auth-note {
  font-size: 13px;
}

.auth-divider {
  display: flex;
  align-items: center;
  gap: 12px;
  color: var(--text-muted);
  font-size: 13px;
}

.auth-divider::before,
.auth-divider::after {
  content: '';
  flex: 1;
  height: 1px;
  background: var(--border);
}
</style>
