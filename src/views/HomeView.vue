<script setup>
import { computed } from 'vue'
import BaseButton from '../components/base/BaseButton.vue'
import BaseCard from '../components/base/BaseCard.vue'
import BaseBadge from '../components/base/BaseBadge.vue'
import TransactionList from '../components/shared/TransactionList.vue'
import WasteCard from '../components/shared/WasteCard.vue'
import {
  claimStatusInfo,
  formatDateTime,
  formatNumber
} from '../composables/useFormatters'
import { items, categories } from '../data/items'
import { usePointsStore } from '../stores/usePointsStore'
import { useAuthStore } from '../stores/useAuthStore'
import { useRewardStore } from '../stores/useRewardStore'
import { useTransactionStore } from '../stores/useTransactionStore'

const auth = useAuthStore()
const { isLoggedIn, userName } = auth
const { balance, totalEarned, totalSpent, totalWasteKg } = usePointsStore()
const { rewards } = useRewardStore()
const { transactions, transactionsByType } = useTransactionStore()

const pendingCount = computed(
  () => transactions.value.filter((t) => t.type === 'penukaran' && t.claimStatus === 'menunggu').length
)
const popularRewards = computed(() => rewards.value.slice(0, 3))
const popularItems = items.filter((item) => item.points !== null).slice(0, 3)
const recentTransactions = computed(() => transactions.value.slice(0, 4))
const redemptions = computed(() => transactionsByType('penukaran'))
const activeClaim = computed(() =>
  transactions.value.find((transaction) => transaction.type === 'penukaran' && transaction.claimStatus !== 'selesai')
)

const eduSteps = [
  {
    title: 'Pilah sampahmu',
    text: 'Pisahkan sampah menjadi enam kategori: plastik, kertas, kardus, logam, kaca, dan organik. Pastikan bersih dan kering sebelum disetorkan.'
  },
  {
    title: 'Setorkan dalam hitungan detik',
    text: 'Buka menu Setorkan, pilih jenis sampah, dan masukkan perkiraan beratnya. Tidak perlu antre atau menunggu.'
  },
  {
    title: 'Poin langsung masuk',
    text: 'Poin dihitung dari jenis dan berat sampah, lalu langsung ditambahkan ke dompetmu begitu setoran terkirim. Semua tercatat transparan di riwayat.'
  },
  {
    title: 'Tukar dengan reward',
    text: 'Gunakan poin yang terkumpul untuk menukar alat tulis, buku, totebag, atau tumbler. Simpan kode klaimnya untuk mengambil hadiahmu.'
  }
]

const eduFacts = [
  { value: '6', label: 'Kategori sampah diterima', tone: 'blue' },
  { value: 'Instan', label: 'Poin langsung masuk tanpa antre', tone: 'green' },
  { value: '4', label: 'Jenis reward menarik', tone: 'yellow' },
  { value: 'Gratis', label: 'Tanpa biaya untuk siswa', tone: 'blue' }
]

const eduTips = [
  {
    title: 'Bersihkan sebelum disetorkan',
    text: 'Bilas botol dan kaleng bekas minuman. Sampah yang bersih bernilai lebih tinggi dan lebih mudah didaur ulang.'
  },
  {
    title: 'Ikat dan lipat dengan rapi',
    text: 'Ikat tumpukan kertas dan lipat kardus hingga rata. Ini menghemat tempat dan mempercepat proses penimbangan.'
  },
  {
    title: 'Pisahkan tutup dan label',
    text: 'Lepaskan tutup logam dari botol kaca dan label yang mudah dikupas. Jenis material yang berbeda perlu dipisah.'
  },
  {
    title: 'Setorkan secara rutin',
    text: 'Kumpulkan poin sedikit demi sedikit secara konsisten. Lebih baik menyetorkan setiap minggu daripada menumpuk di rumah.'
  }
]

function categoryOf(item) {
  return categories.find((category) => category.slug === item.category)
}
</script>

<template>
  <!-- Guest landing page: educational and informative -->
  <div v-if="!isLoggedIn" class="container page">
    <section class="hero">
      <div class="hero-orbs" aria-hidden="true">
        <span class="orb orb--blue" />
        <span class="orb orb--green" />
        <span class="orb orb--yellow" />
      </div>
      <div class="hero-content">
        <p class="hero-greeting">Bank sampah digital untuk sekolahmu</p>
        <h1 class="hero-title">Ubah sampah jadi poin, tukar dengan reward menarik.</h1>
        <p class="hero-tagline">Recycle Today, Reward Tomorrow.</p>
        <div class="hero-actions">
          <BaseButton to="/login">Mulai Sekarang</BaseButton>
          <BaseButton to="/about" variant="ghost">Pelajari Cara Kerjanya</BaseButton>
        </div>
      </div>
    </section>

    <section class="edu-facts grid grid--4">
      <BaseCard v-for="fact in eduFacts" :key="fact.label" hoverable>
        <p :class="['edu-fact-value', `edu-fact--${fact.tone}`]">{{ fact.value }}</p>
        <p class="edu-fact-label">{{ fact.label }}</p>
      </BaseCard>
    </section>

    <section class="section">
      <div class="section-head">
        <h2 class="section-title">Bagaimana RePoint bekerja?</h2>
      </div>
      <div class="grid grid--4">
        <BaseCard v-for="(step, index) in eduSteps" :key="step.title" hoverable class="edu-step">
          <span class="edu-step-number">{{ index + 1 }}</span>
          <h3 class="edu-step-title">{{ step.title }}</h3>
          <p class="edu-step-text">{{ step.text }}</p>
        </BaseCard>
      </div>
    </section>

    <section class="section">
      <div class="section-head">
        <h2 class="section-title">Sampah apa saja yang diterima?</h2>
        <BaseButton to="/login" variant="ghost" size="sm">Masuk untuk setorkan</BaseButton>
      </div>
      <div class="grid grid--cards">
        <WasteCard
          v-for="item in items.slice(0, 4)"
          :key="item.id"
          :item="item"
          :category="categoryOf(item)"
        />
      </div>
      <p class="muted edu-note">
        Masuk ke akun untuk melihat semua jenis sampah dan mulai menyetorkan.
      </p>
    </section>

    <section class="section">
      <div class="section-head">
        <h2 class="section-title">Tips memilah sampah</h2>
      </div>
      <div class="grid grid--2">
        <BaseCard v-for="tip in eduTips" :key="tip.title" hoverable class="edu-tip">
          <h3 class="edu-tip-title">{{ tip.title }}</h3>
          <p class="edu-tip-text">{{ tip.text }}</p>
        </BaseCard>
      </div>
    </section>

    <section class="section">
      <div class="section-head">
        <h2 class="section-title">Reward yang bisa ditukar</h2>
        <BaseButton to="/login" variant="ghost" size="sm">Masuk untuk menukar</BaseButton>
      </div>
      <div class="grid grid--3">
        <RouterLink v-for="reward in popularRewards" :key="reward.id" to="/login" class="mini-card">
          <img :src="reward.imageUrl" :alt="reward.name" loading="lazy" />
          <div class="mini-body">
            <p class="mini-title">{{ reward.name }}</p>
            <p class="mini-meta">{{ reward.description }}</p>
          </div>
        </RouterLink>
      </div>
    </section>

    <section class="edu-cta">
      <h2 class="edu-cta-title">Siap mulai kumpulkan poin dari sampah?</h2>
      <p class="edu-cta-text">Daftar sekarang, setorkan sampah pertamamu, dan tukar dengan reward menarik.</p>
      <BaseButton to="/login">Daftar Sekarang</BaseButton>
    </section>
  </div>

  <!-- Logged-in student dashboard (unchanged) -->
  <div v-else class="container page">
    <section class="hero">
      <div class="hero-orbs" aria-hidden="true">
        <span class="orb orb--blue" />
        <span class="orb orb--green" />
        <span class="orb orb--yellow" />
      </div>
      <div class="hero-content">
        <p class="hero-greeting">Selamat datang kembali, {{ userName }}</p>
        <h1 class="hero-title">Setiap sampah yang kamu pilah menjadi poin.</h1>
        <p class="hero-tagline">Recycle Today, Reward Tomorrow.</p>
        <div class="hero-actions">
          <BaseButton to="/waste">Lihat Katalog Sampah</BaseButton>
          <BaseButton to="/rewards" variant="ghost">Tukar Reward</BaseButton>
        </div>
      </div>
      <div class="hero-trash" aria-hidden="true">
        <svg viewBox="0 0 24 24" class="trash-bin">
          <path class="trash-body" d="M5 7h14l-1.5 13a1.5 1.5 0 01-1.5 1.3H8a1.5 1.5 0 01-1.5-1.3L5 7z" fill="rgba(255,255,255,0.9)"/>
          <path class="trash-lid" d="M4 5h16v2H4z" fill="#fcd34d"/>
          <path d="M9 3h6v2H9z" fill="#fcd34d"/>
          <rect class="trash-line trash-line--1" x="9" y="10" width="1.6" height="8" rx="0.8" fill="#10b981"/>
          <rect class="trash-line trash-line--2" x="11.7" y="10" width="1.6" height="8" rx="0.8" fill="#10b981"/>
          <rect class="trash-line trash-line--3" x="14.4" y="10" width="1.6" height="8" rx="0.8" fill="#10b981"/>
        </svg>
        <span class="trash-leaf trash-leaf--1">♻️</span>
        <span class="trash-leaf trash-leaf--2">♻️</span>
      </div>
    </section>

    <section class="stats grid grid--4">
      <BaseCard hoverable>
        <p class="stat-label">Saldo poin</p>
        <p class="stat-value num">{{ formatNumber(balance) }} <span>poin</span></p>
      </BaseCard>
      <BaseCard hoverable>
        <p class="stat-label">Total diperoleh</p>
        <p class="stat-value num stat-plus">{{ formatNumber(totalEarned) }}</p>
      </BaseCard>
      <BaseCard hoverable>
        <p class="stat-label">Total digunakan</p>
        <p class="stat-value num stat-minus">{{ formatNumber(totalSpent) }}</p>
      </BaseCard>
      <BaseCard hoverable>
        <p class="stat-label">Sampah terkumpul</p>
        <p class="stat-value num">{{ formatNumber(totalWasteKg) }} <span>kg</span></p>
      </BaseCard>
    </section>

    <section v-if="pendingCount > 0" class="pending-hero">
      <div class="pending-hero-icon">
        <svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 2a10 10 0 100 20 10 10 0 000-20zm0 6a1.5 1.5 0 110 3 1.5 1.5 0 010-3zm1 9h-2v-5h2v5z" fill="currentColor"/></svg>
      </div>
      <div class="pending-hero-text">
        <p class="pending-hero-title">Kamu punya {{ pendingCount }} penukaran reward yang sedang diproses</p>
        <p class="muted">Tunjukkan kode klaimnya di halaman Klaim Reward untuk menerima hadiahmu.</p>
      </div>
      <BaseButton to="/claim" size="sm" variant="secondary">Lihat Klaim</BaseButton>
    </section>

    <section v-if="activeClaim" class="claim-banner">
      <div>
        <p class="claim-banner-title">Klaim reward kamu: {{ activeClaim.title }}</p>
        <p class="muted">Tandai klaim selesai di halaman Klaim Reward setelah hadiahmu diterima.</p>
      </div>
      <BaseBadge :tone="claimStatusInfo(activeClaim.claimStatus).tone">
        {{ claimStatusInfo(activeClaim.claimStatus).label }}
      </BaseBadge>
      <BaseButton to="/claim" size="sm" variant="secondary">Lihat Klaim</BaseButton>
    </section>

    <section class="section">
      <div class="section-head">
        <h2 class="section-title">Reward populer</h2>
        <BaseButton to="/rewards" variant="ghost" size="sm">Semua reward</BaseButton>
      </div>
      <div class="grid grid--3">
        <RouterLink v-for="reward in popularRewards" :key="reward.id" to="/rewards" class="mini-card">
          <img :src="reward.imageUrl" :alt="reward.name" loading="lazy" />
          <div class="mini-body">
            <p class="mini-title">{{ reward.name }}</p>
            <p class="mini-meta num">{{ formatNumber(reward.price) }} poin | Stok {{ reward.stock }}</p>
          </div>
        </RouterLink>
      </div>
    </section>

    <section class="section">
      <div class="section-head">
        <h2 class="section-title">Katalog sampah populer</h2>
        <BaseButton to="/waste" variant="ghost" size="sm">Semua sampah</BaseButton>
      </div>
      <div class="grid grid--3">
        <RouterLink v-for="item in popularItems" :key="item.id" to="/waste" class="mini-card">
          <img :src="item.imageUrl" :alt="item.title" loading="lazy" />
          <div class="mini-body">
            <p class="mini-title">{{ item.title }}</p>
            <p class="mini-meta num">{{ formatNumber(item.points) }} poin per {{ item.unit }}</p>
          </div>
        </RouterLink>
      </div>
    </section>

    <section v-if="redemptions.length > 0" class="section">
      <div class="section-head">
        <h2 class="section-title">Riwayat penukaran reward</h2>
        <BaseButton to="/history" variant="ghost" size="sm">Lihat semua</BaseButton>
      </div>
      <ul class="redeem-list">
        <li v-for="redemption in redemptions" :key="redemption.id" class="redeem-row">
          <div class="redeem-main">
            <h3 class="redeem-title">{{ redemption.title }}</h3>
            <p class="redeem-date">{{ formatDateTime(redemption.date) }}</p>
          </div>
          <div class="redeem-meta">
            <span class="redeem-points num">-{{ formatNumber(redemption.points) }} poin</span>
            <BaseBadge :tone="claimStatusInfo(redemption.claimStatus).tone">
              {{ claimStatusInfo(redemption.claimStatus).label }}
            </BaseBadge>
          </div>
        </li>
      </ul>
    </section>

    <section class="section">
      <div class="section-head">
        <h2 class="section-title">Riwayat transaksi terbaru</h2>
        <BaseButton to="/history" variant="ghost" size="sm">Lihat semua</BaseButton>
      </div>
      <TransactionList :transactions="recentTransactions" empty-title="Belum ada transaksi" />
    </section>
  </div>
</template>

<style scoped>
.hero {
  position: relative;
  overflow: hidden;
  padding: 40px 24px;
  border-radius: var(--radius-lg);
  background: linear-gradient(135deg, #1e3a8a 0%, #1d4ed8 35%, #10b981 70%, #f59e0b 100%);
  background-size: 200% 200%;
  animation: gradient-shift 8s ease infinite;
  color: var(--neutral-0);
  box-shadow: var(--shadow-md);
}

@keyframes gradient-shift {
  0%, 100% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
}

.hero-orbs {
  position: absolute;
  inset: 0;
  pointer-events: none;
}

.orb {
  position: absolute;
  border-radius: 50%;
  filter: blur(2px);
  opacity: 0.25;
}

.orb--blue {
  width: 180px;
  height: 180px;
  top: -40px;
  right: 10%;
  background: radial-gradient(circle, #93c5fd 0%, transparent 70%);
  animation: float-orb 7s ease-in-out infinite;
}

.orb--green {
  width: 140px;
  height: 140px;
  bottom: -30px;
  left: 5%;
  background: radial-gradient(circle, #6ee7b7 0%, transparent 70%);
  animation: float-orb-reverse 6s ease-in-out infinite;
}

.orb--yellow {
  width: 100px;
  height: 100px;
  top: 40%;
  right: 30%;
  background: radial-gradient(circle, #fcd34d 0%, transparent 70%);
  animation: float-orb 9s ease-in-out infinite 1s;
  opacity: 0.2;
}

.hero-content {
  position: relative;
  z-index: 1;
  animation: fade-up 0.6s var(--ease) both;
}

.hero-greeting {
  font-size: 15px;
  font-weight: 600;
  color: rgba(255, 255, 255, 0.85);
}

.hero-title {
  margin-top: 8px;
  font-size: clamp(1.5rem, 4vw, 2.25rem);
  color: var(--neutral-0);
  text-shadow: 0 2px 12px rgba(0, 0, 0, 0.15);
}

.hero-tagline {
  margin-top: 8px;
  color: rgba(255, 255, 255, 0.8);
  font-weight: 600;
}

.hero-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 12px;
  margin-top: 20px;
}

.hero-actions :deep(.base-button--ghost) {
  background: rgba(255, 255, 255, 0.15);
  border-color: rgba(255, 255, 255, 0.5);
  color: var(--neutral-0);
  backdrop-filter: blur(4px);
}

.hero-actions :deep(.base-button--ghost:hover) {
  background: rgba(255, 255, 255, 0.25);
  color: var(--neutral-0);
}

@media (min-width: 768px) {
  .hero {
    grid-template-columns: 1fr auto;
    align-items: center;
    padding: 48px 40px;
  }

  .hero-trash {
    display: flex;
  }
}

.hero-trash {
  position: relative;
  z-index: 1;
  display: none;
  width: 120px;
  height: 130px;
}

.trash-bin {
  width: 100%;
  height: 100%;
  animation: trash-bounce 2.4s ease-in-out infinite;
  filter: drop-shadow(0 8px 16px rgba(0, 0, 0, 0.25));
}

.trash-lid {
  transform-origin: 12px 6px;
  animation: lid-swing 3.2s ease-in-out infinite;
}

.trash-line--1 { animation: line-pulse 2s ease-in-out infinite; }
.trash-line--2 { animation: line-pulse 2s ease-in-out infinite 0.2s; }
.trash-line--3 { animation: line-pulse 2s ease-in-out infinite 0.4s; }

.trash-leaf {
  position: absolute;
  font-size: 18px;
  opacity: 0;
  animation: leaf-float 4s ease-in-out infinite;
}

.trash-leaf--1 { top: 20%; left: -10%; animation-delay: 0.5s; }
.trash-leaf--2 { bottom: 10%; right: -5%; animation-delay: 2.2s; }

@keyframes trash-bounce {
  0%, 100% { transform: translateY(0) rotate(0deg); }
  25% { transform: translateY(-6px) rotate(-3deg); }
  50% { transform: translateY(0) rotate(0deg); }
  75% { transform: translateY(-4px) rotate(3deg); }
}

@keyframes lid-swing {
  0%, 100% { transform: rotate(0deg) translateY(0); }
  40% { transform: rotate(-18deg) translateY(-2px); }
  70% { transform: rotate(0deg) translateY(0); }
}

@keyframes line-pulse {
  0%, 100% { opacity: 1; }
  50% { opacity: 0.4; }
}

@keyframes leaf-float {
  0% { opacity: 0; transform: translateY(0) scale(0.6); }
  25% { opacity: 1; }
  75% { opacity: 1; transform: translateY(-24px) scale(1.1); }
  100% { opacity: 0; transform: translateY(-40px) scale(0.9); }
}

.edu-facts {
  margin-top: var(--space-4);
}

.edu-fact-value {
  font-size: 30px;
  font-weight: 700;
}

.edu-fact--blue { color: var(--primary-700); }
.edu-fact--green { color: var(--secondary-700); }
.edu-fact--yellow { color: var(--accent-700); }

.edu-fact-label {
  margin-top: 4px;
  font-size: 14px;
  color: var(--text-muted);
}

.edu-step {
  display: grid;
  gap: 8px;
  align-content: start;
}

.edu-step-number {
  display: grid;
  place-items: center;
  width: 36px;
  height: 36px;
  border-radius: var(--radius-pill);
  background: var(--brand-gradient);
  color: var(--neutral-0);
  font-weight: 700;
}

.edu-step-title {
  font-size: 17px;
}

.edu-step-text {
  font-size: 14px;
  color: var(--text-muted);
}

.edu-note {
  margin-top: var(--space-2);
  font-size: 14px;
}

.edu-tip {
  display: grid;
  gap: 8px;
}

.edu-tip-title {
  font-size: 17px;
  color: var(--primary-700);
}

.edu-tip-text {
  font-size: 14px;
  color: var(--text-muted);
}

.edu-cta {
  display: grid;
  justify-items: center;
  gap: 12px;
  margin-top: var(--space-6);
  padding: var(--space-5) var(--space-3);
  text-align: center;
  background: var(--brand-gradient-soft);
  border: 1px solid var(--primary-100);
  border-radius: var(--radius-lg);
}

.edu-cta-title {
  font-size: clamp(1.25rem, 3vw, 1.5rem);
}

.edu-cta-text {
  max-width: 480px;
  color: var(--text-muted);
}

.stats {
  margin-top: var(--space-4);
}

.stat-label {
  font-size: 13px;
  font-weight: 600;
  color: var(--text-muted);
}

.stat-value {
  margin-top: 6px;
  font-size: 26px;
  font-weight: 700;
  color: var(--primary-700);
}

.stat-plus {
  color: var(--secondary-700);
}

.stat-minus {
  color: var(--accent-700);
}

.stat-value span {
  font-size: 14px;
  color: var(--text-muted);
}

.pending-hero {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: var(--space-2);
  margin-top: var(--space-4);
  padding: var(--space-3) var(--space-3);
  background: var(--info-bg);
  border: 1px solid var(--primary-300);
  border-radius: var(--radius-md);
}

.pending-hero-icon {
  display: grid;
  place-items: center;
  width: 40px;
  height: 40px;
  flex-shrink: 0;
  border-radius: var(--radius-pill);
  background: var(--primary-700);
  color: var(--neutral-0);
}

.pending-hero-icon svg {
  width: 22px;
  height: 22px;
}

.pending-hero-text {
  flex: 1;
  min-width: 200px;
}

.pending-hero-title {
  font-weight: 700;
  color: var(--info-text);
}

.claim-banner {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: var(--space-2);
  margin-top: var(--space-4);
  padding: var(--space-3) var(--space-3);
  background: var(--accent-50);
  border: 1px solid var(--accent-300);
  border-radius: var(--radius-md);
}

.claim-banner > div {
  flex: 1;
  min-width: 200px;
}

.claim-banner-title {
  font-weight: 700;
}

.mini-card {
  display: block;
  overflow: hidden;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius-md);
  transition: transform 0.25s var(--ease), box-shadow 0.25s var(--ease);
}

.mini-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-hover);
}

.mini-card img {
  width: 100%;
  aspect-ratio: 16 / 9;
  object-fit: cover;
}

.mini-body {
  padding: var(--space-2) var(--space-2) var(--space-3);
}

.mini-title {
  font-weight: 700;
}

.mini-meta {
  margin-top: 4px;
  font-size: 14px;
  color: var(--text-muted);
}

.redeem-list {
  display: grid;
  gap: var(--space-2);
  margin: 0;
  padding: 0;
  list-style: none;
}

.redeem-row {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-2);
  padding: var(--space-3) var(--space-3);
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius-md);
  transition: border-color 0.2s var(--ease), box-shadow 0.2s var(--ease);
}

.redeem-row:hover {
  border-color: var(--primary-300);
  box-shadow: var(--shadow-md);
}

.redeem-main {
  display: grid;
  gap: 6px;
}

.redeem-title {
  font-size: 16px;
}

.redeem-date {
  font-size: 13px;
  color: var(--text-muted);
}

.redeem-meta {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: var(--space-2);
}

.redeem-points {
  font-size: 16px;
  font-weight: 700;
  color: var(--accent-700);
}
</style>
