# Project memory

## Product intent & audience

- Web app for trash deposit/recycling where users exchange waste for points and redeem rewards.
- Audience: individual users only; no admin or staff role exists.
- Fully self-service: deposits and reward claims require no external approval.

## Brand personality & voice

- Indonesian language (Bahasa Indonesia) throughout UI and copy.
- Tone: simple, direct, user-empowering; removes any mention of staff/validation/approval.

## Visual design & UX direction

- Login page includes one-click "Masuk sebagai Tamu" button that creates a private guest session without form input.
- Waste catalog page: each waste type card has a tappable "Setorkan Sekarang" button → opens weight input → submit.
- Wallet page shows points balance updated automatically after deposit.
- Reward claim page: user can redeem multiple rewards; each claim has a self-confirm "Sudah Diterima" button.
- Navigation menu has no admin/approval entries; only user-facing pages (Beranda, Tentang, Riwayat, Dompet, Reward, Klaim).
- All UI text updated to remove references to petugas/persetujuan/validasi.

## Decisions, constraints & rationale

- **Guest feature (replaced instant demo):** one-click private guest session per device; temporary — logout and re-login as guest to reset.
- **Auto-verified deposits:** on submission, deposit status is immediately "Berhasil" and points auto-credit to wallet — no pending/approval state.
- **No admin role:** admin pages, approval logic, and menu items removed entirely.
- **Self-confirmed rewards:** after redeeming, user marks reward as received via "Sudah Diterima" button on Klaim page.
- **Database rules updated** to enforce auto-approve and auto-point-credit on deposit write.

## Open questions & assumptions

- Guest data persistence: assumed ephemeral per device; no cross-device guest sync.
- Abuse prevention for self-confirmed deposits and reward claims is not addressed — trust-based model assumed.
- No admin analytics or moderation — may be needed later if scale grows.