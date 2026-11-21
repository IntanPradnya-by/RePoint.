<script setup>
import { computed } from 'vue'
import { RouterLink } from 'vue-router'

const props = defineProps({
  variant: { type: String, default: 'primary' },
  size: { type: String, default: 'md' },
  to: { type: [String, Object], default: null },
  type: { type: String, default: 'button' },
  disabled: { type: Boolean, default: false },
  block: { type: Boolean, default: false }
})

const tag = computed(() => (props.to ? RouterLink : 'button'))
</script>

<template>
  <component
    :is="tag"
    :to="to ?? undefined"
    :type="to ? undefined : type"
    :disabled="to ? undefined : disabled"
    :class="[
      'base-button',
      `base-button--${variant}`,
      `base-button--${size}`,
      { 'base-button--block': block }
    ]"
  >
    <slot />
  </component>
</template>

<style scoped>
.base-button {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  border: 1px solid transparent;
  border-radius: var(--radius-pill);
  font-weight: 600;
  line-height: 1;
  white-space: nowrap;
  transition: background 0.2s var(--ease), border-color 0.2s var(--ease),
    color 0.2s var(--ease), transform 0.2s var(--ease), box-shadow 0.2s var(--ease);
}

.base-button--md {
  height: 44px;
  padding: 0 24px;
  font-size: 15px;
}

.base-button--sm {
  height: 36px;
  padding: 0 16px;
  font-size: 14px;
}

.base-button--block {
  width: 100%;
}

.base-button--primary {
  background: var(--brand-gradient);
  background-size: 200% auto;
  color: var(--neutral-0);
  box-shadow: var(--shadow-sm);
}

.base-button--primary:hover:not(:disabled) {
  background-position: right center;
  transform: translateY(-1px);
  box-shadow: var(--shadow-md);
}

.base-button--secondary {
  background: var(--primary-100);
  color: var(--primary-700);
}

.base-button--secondary:hover:not(:disabled) {
  background: var(--primary-300);
}

.base-button--ghost {
  background: transparent;
  border-color: var(--border);
  color: var(--text);
}

.base-button--ghost:hover:not(:disabled) {
  border-color: var(--primary-500);
  color: var(--primary-700);
}

.base-button--danger {
  background: var(--danger-bg);
  color: var(--danger-text);
}

.base-button--danger:hover:not(:disabled) {
  background: #fecaca;
}

.base-button:active:not(:disabled) {
  transform: translateY(0);
}

.base-button:disabled {
  background: var(--neutral-100);
  border-color: var(--neutral-200);
  color: var(--neutral-500);
  cursor: not-allowed;
}
</style>
