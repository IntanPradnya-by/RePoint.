<script setup>
import BaseButton from '../components/base/BaseButton.vue'
</script>

<template>
  <div class="container not-found">
    <p class="not-found-code">404</p>
    <h1 class="not-found-title">Halaman tidak ditemukan</h1>
    <p class="not-found-text">Halaman yang kamu cari tidak tersedia atau sudah dipindahkan.</p>
    <BaseButton to="/">Kembali ke Dashboard</BaseButton>
  </div>
</template>

<style scoped>
.not-found {
  display: grid;
  justify-items: center;
  gap: 16px;
  padding: 80px 0;
  text-align: center;
}

.not-found-code {
  font-size: 72px;
  font-weight: 700;
  line-height: 1;
  color: var(--primary-500);
}

.not-found-title {
  font-size: 24px;
}

.not-found-text {
  color: var(--text-muted);
}
</style>
