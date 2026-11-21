<script setup>
import { computed, ref } from 'vue'
import BaseAlert from '../components/base/BaseAlert.vue'
import BaseButton from '../components/base/BaseButton.vue'
import DepositModal from '../components/shared/DepositModal.vue'
import EmptyState from '../components/shared/EmptyState.vue'
import SearchBar from '../components/shared/SearchBar.vue'
import WasteCard from '../components/shared/WasteCard.vue'
import { formatNumber } from '../composables/useFormatters'
import { useItemFilter } from '../composables/useItemFilter'
import { useTransactionStore } from '../stores/useTransactionStore'

const { categories, searchQuery, activeCategory, filteredItems, resetFilters } = useItemFilter()
const { addDeposit } = useTransactionStore()

const depositOpen = ref(false)
const depositPresetId = ref(null)
const notice = ref(null)
const depositError = ref('')

const activeCategoryInfo = computed(() =>
  categories.find((category) => category.slug === activeCategory.value)
)

function categoryOf(item) {
  return categories.find((category) => category.slug === item.category)
}

function openDeposit(item = null) {
  depositPresetId.value = item?.id ?? null
  depositOpen.value = true
}

async function handleDeposit({ item, weight }) {
  depositError.value = ''
  try {
    await addDeposit(item, weight)
  } catch (cause) {
    console.error('deposit failed', cause)
    depositOpen.value = false
    depositError.value = 'Setoran belum terkirim. Coba lagi beberapa saat lagi.'
    return
  }
  depositOpen.value = false
  notice.value = { title: item.title, weight }
}
</script>

<template>
  <div class="container page">
    <header class="page-header header-row">
      <div>
        <h1 class="page-title">Katalog Sampah</h1>
        <p class="page-subtitle">
          Pilih jenis sampah yang sudah dipilah, masukkan perkiraan beratnya, lalu setorkan. Poin
          langsung ditambahkan ke dompetmu begitu setoran terkirim.
        </p>
      </div>
      <BaseButton @click="openDeposit()">Setorkan Sampah</BaseButton>
    </header>

    <BaseAlert v-if="depositError" tone="danger">{{ depositError }}</BaseAlert>

    <BaseAlert v-if="notice" tone="success">
      <div class="notice-row">
        <span>
          Setoran {{ notice.title }} {{ formatNumber(notice.weight) }} kg berhasil! Poin sudah langsung
          masuk ke dompetmu.
        </span>
        <div class="notice-actions">
          <BaseButton to="/history" variant="ghost" size="sm">Lihat Riwayat</BaseButton>
          <BaseButton variant="ghost" size="sm" @click="notice = null">Tutup</BaseButton>
        </div>
      </div>
    </BaseAlert>

    <section class="filters">
      <SearchBar v-model="searchQuery" />

      <div class="chip-row" role="group" aria-label="Filter kategori sampah">
        <button
          type="button"
          class="chip"
          :aria-pressed="activeCategory === 'semua'"
          @click="activeCategory = 'semua'"
        >
          Semua
        </button>
        <button
          v-for="category in categories"
          :key="category.id"
          type="button"
          class="chip"
          :aria-pressed="activeCategory === category.slug"
          @click="activeCategory = category.slug"
        >
          {{ category.title }}
        </button>
      </div>

      <p class="category-info muted">
        {{ activeCategoryInfo ? activeCategoryInfo.description : 'Menampilkan seluruh kategori sampah yang diterima sekolah.' }}
      </p>
    </section>

    <p class="results-count muted">Menampilkan {{ filteredItems.length }} jenis sampah</p>

    <div v-if="filteredItems.length" class="grid grid--cards">
      <WasteCard
        v-for="item in filteredItems"
        :key="item.id"
        :item="item"
        :category="categoryOf(item)"
        @deposit="openDeposit"
      />
    </div>

    <EmptyState
      v-else
      title="Sampah tidak ditemukan"
      description="Coba kata kunci lain atau pilih kategori yang berbeda."
    >
      <BaseButton variant="ghost" size="sm" @click="resetFilters">Reset pencarian</BaseButton>
    </EmptyState>

    <DepositModal
      :open="depositOpen"
      :preset-item-id="depositPresetId"
      @close="depositOpen = false"
      @submit="handleDeposit"
    />
  </div>
</template>

<style scoped>
.header-row {
  display: flex;
  flex-wrap: wrap;
  align-items: flex-end;
  justify-content: space-between;
  gap: var(--space-2);
}

.filters {
  display: grid;
  gap: var(--space-2);
  margin-bottom: var(--space-3);
}

.category-info {
  font-size: 14px;
}

.results-count {
  margin-bottom: var(--space-3);
  font-size: 14px;
}

.notice-row {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: space-between;
  gap: var(--space-2);
}

.notice-actions {
  display: flex;
  flex-wrap: wrap;
  gap: var(--space-1);
}
</style>
