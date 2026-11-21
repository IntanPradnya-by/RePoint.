<script setup>
import { computed, ref, watch } from 'vue'
import BaseAlert from '../base/BaseAlert.vue'
import BaseButton from '../base/BaseButton.vue'
import BaseModal from '../base/BaseModal.vue'
import { items } from '../../data/items'

const props = defineProps({
  open: { type: Boolean, default: false },
  presetItemId: { type: String, default: null }
})

const emit = defineEmits(['close', 'submit'])

const itemId = ref('')
const weightInput = ref('')
const error = ref('')

watch(
  () => props.open,
  (isOpen) => {
    if (!isOpen) return
    itemId.value = props.presetItemId ?? items[0].id
    weightInput.value = ''
    error.value = ''
  }
)

const selectedItem = computed(() => items.find((item) => item.id === itemId.value))

function submit() {
  const weight = Number(weightInput.value.replace(',', '.'))

  if (!selectedItem.value) {
    error.value = 'Pilih jenis sampah terlebih dahulu.'
    return
  }
  if (!Number.isFinite(weight) || weight <= 0) {
    error.value = 'Masukkan berat sampah yang valid (lebih dari 0 kg).'
    return
  }

  emit('submit', { item: selectedItem.value, weight })
}
</script>

<template>
  <BaseModal :open="open" title="Setorkan Sampah" @close="emit('close')">
    <form class="deposit-form" @submit.prevent="submit">
      <label class="field">
        <span>Jenis sampah</span>
        <select v-model="itemId">
          <option v-for="item in items" :key="item.id" :value="item.id">{{ item.title }}</option>
        </select>
      </label>

      <label class="field">
        <span>Perkiraan berat (kg)</span>
        <input v-model="weightInput" type="text" inputmode="decimal" placeholder="Contoh: 1.5" />
      </label>

      <BaseAlert v-if="error" tone="danger">{{ error }}</BaseAlert>

      <p class="hint">Poin langsung ditambahkan ke dompetmu setelah setoran terkirim — tanpa perlu menunggu persetujuan.</p>

      <div class="deposit-actions">
        <BaseButton variant="ghost" @click="emit('close')">Batal</BaseButton>
        <BaseButton type="submit">Setorkan Sekarang</BaseButton>
      </div>
    </form>
  </BaseModal>
</template>

<style scoped>
.deposit-form {
  display: grid;
  gap: var(--space-2);
}

.hint {
  font-size: 14px;
  color: var(--text-muted);
}

.deposit-actions {
  display: flex;
  justify-content: flex-end;
  flex-wrap: wrap;
  gap: var(--space-1);
}
</style>
