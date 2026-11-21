<script setup>
defineProps({
  tone: { type: String, default: 'neutral' }
})
</script>

<template>
  <span :class="['base-badge', `base-badge--${tone}`]">
    <slot />
  </span>
</template>

<style scoped>
.base-badge {
  display: inline-flex;
  align-items: center;
  padding: 4px 12px;
  border-radius: var(--radius-pill);
  font-size: 12px;
  font-weight: 600;
  line-height: 1.5;
  white-space: nowrap;
}

.base-badge--success {
  background: var(--success-bg);
  color: var(--success-text);
}

.base-badge--warning {
  background: var(--warning-bg);
  color: var(--warning-text);
}

.base-badge--danger {
  background: var(--danger-bg);
  color: var(--danger-text);
}

.base-badge--info {
  background: var(--info-bg);
  color: var(--info-text);
}

.base-badge--neutral {
  background: var(--neutral-100);
  color: var(--neutral-800);
}
</style>
