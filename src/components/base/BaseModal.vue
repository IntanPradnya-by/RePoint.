<script setup>
import { onBeforeUnmount, onMounted } from 'vue'

const props = defineProps({
  open: { type: Boolean, default: false },
  title: { type: String, default: '' }
})

const emit = defineEmits(['close'])

function handleKeydown(event) {
  if (event.key === 'Escape' && props.open) {
    emit('close')
  }
}

onMounted(() => window.addEventListener('keydown', handleKeydown))
onBeforeUnmount(() => window.removeEventListener('keydown', handleKeydown))
</script>

<template>
  <Teleport to="body">
    <Transition name="modal">
      <div v-if="open" class="modal-backdrop" @click.self="emit('close')">
        <div class="modal" role="dialog" aria-modal="true" :aria-label="title">
          <header class="modal-header">
            <h2 class="modal-title">{{ title }}</h2>
            <button type="button" class="modal-close" aria-label="Tutup" @click="emit('close')">&times;</button>
          </header>
          <div class="modal-body">
            <slot />
          </div>
          <footer v-if="$slots.footer" class="modal-footer">
            <slot name="footer" />
          </footer>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.modal-backdrop {
  position: fixed;
  inset: 0;
  z-index: 100;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 16px;
  background: rgba(15, 23, 42, 0.5);
}

.modal {
  width: 100%;
  max-width: 480px;
  max-height: 90vh;
  overflow-y: auto;
  background: var(--surface);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-hover);
}

.modal-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  padding: 24px 24px 0;
}

.modal-title {
  font-size: 20px;
}

.modal-close {
  width: 36px;
  height: 36px;
  border: none;
  border-radius: var(--radius-pill);
  background: var(--neutral-100);
  font-size: 22px;
  line-height: 1;
  color: var(--text);
  transition: background 0.2s var(--ease);
}

.modal-close:hover {
  background: var(--neutral-200);
}

.modal-body {
  padding: 24px;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  flex-wrap: wrap;
  gap: 8px;
  padding: 0 24px 24px;
}

.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.2s var(--ease);
}

.modal-enter-active .modal,
.modal-leave-active .modal {
  transition: transform 0.2s var(--ease);
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-from .modal,
.modal-leave-to .modal {
  transform: translateY(12px);
}
</style>
