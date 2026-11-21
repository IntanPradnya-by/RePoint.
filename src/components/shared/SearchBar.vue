<script setup>
defineProps({
  modelValue: { type: String, default: '' },
  placeholder: { type: String, default: 'Cari jenis sampah...' }
})

defineEmits(['update:modelValue'])
</script>

<template>
  <label class="search-bar">
    <svg class="search-icon" viewBox="0 0 24 24" aria-hidden="true">
      <circle cx="11" cy="11" r="7" fill="none" stroke="currentColor" stroke-width="2" />
      <path d="M20 20l-3.5-3.5" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" />
    </svg>
    <input
      type="search"
      :value="modelValue"
      :placeholder="placeholder"
      aria-label="Cari sampah"
      @input="$emit('update:modelValue', $event.target.value)"
    />
  </label>
</template>

<style scoped>
.search-bar {
  display: flex;
  align-items: center;
  gap: 12px;
  width: 100%;
  height: 48px;
  padding: 0 16px;
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius-pill);
  color: var(--text-muted);
  transition: border-color 0.2s var(--ease), box-shadow 0.2s var(--ease);
}

.search-bar:focus-within {
  border-color: var(--primary-500);
  box-shadow: 0 0 0 3px var(--primary-100);
}

.search-icon {
  width: 20px;
  height: 20px;
  flex-shrink: 0;
}

.search-bar input {
  flex: 1;
  min-width: 0;
  height: 100%;
  border: none;
  background: transparent;
  color: var(--text);
  outline: none;
}

.search-bar input::placeholder {
  color: var(--neutral-400);
}
</style>
