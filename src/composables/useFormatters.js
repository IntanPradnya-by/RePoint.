const numberFormatter = new Intl.NumberFormat('id-ID')
const dateTimeFormatter = new Intl.DateTimeFormat('id-ID', {
  day: 'numeric',
  month: 'short',
  year: 'numeric',
  hour: '2-digit',
  minute: '2-digit'
})

const TRANSACTION_TYPE_LABELS = {
  setoran: 'Setoran sampah',
  penambahan: 'Penambahan poin',
  penukaran: 'Penukaran reward'
}

const TRANSACTION_STATUS_INFO = {
  berhasil: { label: 'Berhasil', tone: 'success' },
  menunggu: { label: 'Sedang diproses', tone: 'warning' },
  ditolak: { label: 'Dibatalkan', tone: 'danger' }
}

const CLAIM_STATUS_INFO = {
  menunggu: { label: 'Menunggu diambil', tone: 'warning' },
  diverifikasi: { label: 'Sedang diproses', tone: 'info' },
  selesai: { label: 'Selesai', tone: 'success' }
}

export function formatNumber(value) {
  return numberFormatter.format(value)
}

export function formatDateTime(isoDate) {
  return dateTimeFormatter.format(new Date(isoDate))
}

export function transactionTypeLabel(type) {
  return TRANSACTION_TYPE_LABELS[type]
}

export function transactionStatusInfo(status) {
  return TRANSACTION_STATUS_INFO[status]
}

export function claimStatusInfo(status) {
  return CLAIM_STATUS_INFO[status]
}
