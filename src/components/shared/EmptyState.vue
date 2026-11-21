<script setup>
defineProps({
  title: { type: String, required: true },
  description: { type: String, default: '' }
})
</script>

<template>
  <div class="empty-state">
    <p class="empty-title">{{ title }}</p>
    <p v-if="description" class="empty-description">{{ description }}</p>
    <div v-if="$slots.default" class="empty-action">
      <slot />
    </div>
  </div>
</template>

<style scoped>
.empty-state {
  display: grid;
  justify-items: center;
  gap: 8px;
  padding: 40px 24px;
  text-align: center;
  background: var(--surface);
  border: 1px dashed var(--neutral-400);
  border-radius: var(--radius-lg);
}

.empty-title {
  font-size: 18px;
  font-weight: 700;
  color: var(--text);
}

.empty-description {
  max-width: 420px;
  color: var(--text-muted);
}

.empty-action {
  margin-top: 8px;
}
</style>
