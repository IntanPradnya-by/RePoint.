/*
# Raise reward stock to tens

1. Plain-English explanation
- Reward stock is bumped to tens so many users can redeem before a reward
  runs out: Paket Alat Tulis 50, Buku Catatan 60, Totebag 40, Tumbler 30.
- The seed migration's starting values are updated to match, so a fresh
  rebuild of the database starts with the same tens-level stock.

2. Modified tables
- `reward_stock`: stock values updated for the four catalog rewards
  (referenced by stable reward_id, not by generated ids). All rewards marked
  available.

3. Security
- No policy or grant changes; `reward_stock` stays read-only for signed-in
  users and stock only changes through the redeem function.
*/

UPDATE reward_stock SET stock = 50, is_available = true WHERE reward_id = 'rew-001';
UPDATE reward_stock SET stock = 60, is_available = true WHERE reward_id = 'rew-002';
UPDATE reward_stock SET stock = 40, is_available = true WHERE reward_id = 'rew-003';
UPDATE reward_stock SET stock = 30, is_available = true WHERE reward_id = 'rew-004';
