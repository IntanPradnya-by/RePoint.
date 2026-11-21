<script setup>
import BaseButton from '../components/base/BaseButton.vue'
import BaseCard from '../components/base/BaseCard.vue'

const steps = [
  { title: 'Pilah sampah', text: 'Pisahkan sampah plastik, kertas, kardus, logam, kaca, dan organik di rumah atau sekolah.' },
  { title: 'Setorkan', text: 'Pilih jenis sampah di katalog, masukkan perkiraan beratnya, lalu kirim setoranmu langsung dari aplikasi.' },
  { title: 'Poin langsung masuk', text: 'Poin dihitung otomatis dari jenis dan berat sampah, lalu langsung ditambahkan ke dompetmu begitu setoran terkirim.' },
  { title: 'Tukar reward', text: 'Gunakan saldo poin untuk menukar hadiah. Simpan kode klaimnya, lalu tandai selesai setelah hadiah diterima.' }
]

const benefits = [
  'Siswa belajar memilah sampah sejak dini.',
  'Setiap kilogram sampah yang terkumpul mengurangi timbunan di lingkungan sekolah.',
  'Poin memberi motivasi dan hadiah yang nyata bagi siswa yang aktif.'
]
</script>

<template>
  <div class="container page">
    <header class="page-header">
      <h1 class="page-title">Tentang RePoint</h1>
      <p class="page-subtitle">
        RePoint adalah bank sampah digital berbasis sekolah. Kami menjadikan kebiasaan memilah sampah sebagai
        pengalaman yang menyenangkan dan bermanfaat.
      </p>
    </header>

    <div class="grid grid--2">
      <BaseCard>
        <h2 class="section-title">Tujuan aplikasi</h2>
        <p class="body-text">
          Meningkatkan kepedulian siswa terhadap lingkungan melalui sistem gamifikasi. Sampah yang disetorkan
          dicatat secara transparan, sehingga siswa dapat melihat dampak setiap setoran.
        </p>
      </BaseCard>

      <BaseCard>
        <h2 class="section-title">Manfaat bagi siswa dan sekolah</h2>
        <ul class="bullet-list">
          <li v-for="benefit in benefits" :key="benefit">{{ benefit }}</li>
        </ul>
      </BaseCard>
    </div>

    <section class="section">
      <h2 class="section-title">Cara kerja bank sampah digital</h2>
      <ol class="step-grid">
        <li v-for="(step, index) in steps" :key="step.title" class="step-card">
          <span class="step-number">{{ index + 1 }}</span>
          <h3 class="step-title">{{ step.title }}</h3>
          <p class="body-text">{{ step.text }}</p>
        </li>
      </ol>
    </section>

    <section class="section grid grid--2">
      <BaseCard>
        <h2 class="section-title">Cara mengumpulkan poin</h2>
        <p class="body-text">
          Setorkan sampah yang sudah dipilah dan dibersihkan. Poin dihitung otomatis dari jenis dan berat sampah
          dan langsung masuk ke dompetmu. Nilai poin setiap jenis sampah dapat dilihat di katalog sampah.
        </p>
      </BaseCard>

      <BaseCard>
        <h2 class="section-title">Cara menukarkan reward</h2>
        <p class="body-text">
          Buka katalog reward, pilih hadiah yang diinginkan, lalu konfirmasi penukaran. Saldo poin akan berkurang
          dan kode klaim dibuat. Simpan kode tersebut, dan tandai klaim selesai setelah hadiah diterima.
        </p>
        <div class="about-action">
          <BaseButton to="/rewards">Lihat Reward</BaseButton>
        </div>
      </BaseCard>
    </section>
  </div>
</template>

<style scoped>
.body-text {
  color: var(--text-muted);
}

.bullet-list {
  display: grid;
  gap: 12px;
  margin: 0;
  padding-left: 20px;
  color: var(--text-muted);
}

.step-grid {
  display: grid;
  gap: 16px;
  margin: 16px 0 0;
  padding: 0;
  list-style: none;
}

@media (min-width: 768px) {
  .step-grid {
    grid-template-columns: repeat(4, 1fr);
  }
}

.step-card {
  display: grid;
  gap: 8px;
  align-content: start;
  padding: 24px;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-sm);
  transition: transform 0.25s var(--ease), box-shadow 0.25s var(--ease);
}

.step-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-hover);
}

.step-number {
  display: grid;
  place-items: center;
  width: 36px;
  height: 36px;
  border-radius: var(--radius-pill);
  background: var(--primary-100);
  color: var(--primary-900);
  font-weight: 700;
}

.step-title {
  font-size: 18px;
}

.about-action {
  margin-top: 16px;
}
</style>
