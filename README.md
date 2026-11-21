# RePoint

Bank sampah digital berbasis sekolah. Siswa menyetorkan sampah yang sudah dipilah, poin ditambahkan setelah divalidasi petugas, dan poin dapat ditukar dengan reward.

Tagline: Recycle Today, Reward Tomorrow.

## Struktur utama

- `src/views` halaman aplikasi (Dashboard, Katalog Sampah, Reward, Dompet, Riwayat, Klaim, Tentang, 404)
- `src/components` komponen layout, base, dan shared
- `src/stores` store reaktif untuk poin, reward, dan transaksi
- `src/composables` logika pencarian dan filter, serta format tampilan
- `src/data` data simulasi (sampah, reward, transaksi, profil)
- `src/router` konfigurasi Vue Router
- `public/images` tempat gambar lokal sampah dan reward

## Menjalankan

Gunakan `npm install`, lalu `npm run dev` untuk mode pengembangan dan `npm run build` untuk membuat versi produksi.
