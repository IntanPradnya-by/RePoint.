<script setup>
defineProps({
  tone: { type: String, default: 'info' }
})
</script>

<template>
  <div :class="['base-alert', `base-alert--${tone}`]" role="alert">
    <slot />
  </div>
</template>

<style scoped>
.base-alert {
  padding: 14px 20px;
  border-radius: var(--radius-sm);
  font-size: 14px;
  font-weight: 600;
  line-height: 1.5;
}

.base-alert--success {
  background: var(--success-bg);
  color: var(--success-text);
}

.base-alert--danger {
  background: var(--danger-bg);
  color: var(--danger-text);
}

.base-alert--info {
  background: var(--info-bg);
  color: var(--info-text);
}
</style>
