<script setup>
defineProps({
  hoverable: { type: Boolean, default: false }
})
</script>

<template>
  <div :class="['base-card', { 'base-card--hoverable': hoverable }]">
    <slot />
  </div>
</template>

<style scoped>
.base-card {
  padding: var(--space-3);
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius-md);
  transition: border-color 0.25s var(--ease), box-shadow 0.25s var(--ease);
}

.base-card--hoverable:hover {
  border-color: var(--primary-300);
  box-shadow: var(--shadow-md);
}
</style>
