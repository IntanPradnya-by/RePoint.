<template>
  <footer class="app-footer">
    <div class="container footer-inner">
      <div>
        <p class="footer-brand">RePoint</p>
        <p class="footer-tagline">Recycle Today, Reward Tomorrow.</p>
      </div>
      <p class="footer-note">Bank sampah digital sekolah. Recycle Today, Reward Tomorrow.</p>
    </div>
  </footer>
</template>

<style scoped>
.app-footer {
  margin-top: auto;
  padding: 24px 0;
  background: var(--surface);
  border-top: 1px solid var(--border);
}

.footer-inner {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.footer-brand {
  font-weight: 700;
  color: var(--primary-700);
}

.footer-tagline,
.footer-note {
  font-size: 14px;
  color: var(--text-muted);
}

@media (min-width: 768px) {
  .footer-inner {
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
  }
}
</style>
