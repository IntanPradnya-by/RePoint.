/*
# Create waste catalog points and reward stock tables

1. New Tables
- `waste_items`: the point value per kilogram for each waste type, used when a deposit is approved.
  - `item_id`, `title`, `points_per_kg` (empty when the school has not set a value yet)
- `reward_stock`: the price, remaining stock, and availability of each reward.
  - `reward_id`, `name`, `price`, `stock`, `is_available`

2. Seed data
- Six waste types and four rewards copied from the app catalog. Re-running this does not reset existing stock.

3. Security
- `waste_items` is private: no direct access for the app. Only server functions read it.
- `reward_stock` is readable by signed-in users (it is a public catalog). Nobody can edit it directly.
- Stock changes only through the redeem function added later.

4. Important notes
- Points are decided on the server, so a student cannot change the value of a deposit.
*/

CREATE TABLE IF NOT EXISTS waste_items (
  item_id text PRIMARY KEY,
  title text NOT NULL,
  points_per_kg integer CHECK (points_per_kg IS NULL OR points_per_kg > 0)
);

ALTER TABLE waste_items ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON waste_items FROM anon, authenticated;

INSERT INTO waste_items (item_id, title, points_per_kg) VALUES
  ('item-001', 'Botol Plastik', 100),
  ('item-002', 'Kertas Bekas', 80),
  ('item-003', 'Kardus Bekas', 70),
  ('item-004', 'Kaleng Aluminium', 150),
  ('item-005', 'Botol Kaca', NULL),
  ('item-006', 'Sampah Organik', NULL)
ON CONFLICT (item_id) DO NOTHING;

CREATE TABLE IF NOT EXISTS reward_stock (
  reward_id text PRIMARY KEY,
  name text NOT NULL,
  price integer NOT NULL CHECK (price > 0),
  stock integer NOT NULL CHECK (stock >= 0),
  is_available boolean NOT NULL DEFAULT true
);

ALTER TABLE reward_stock ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON reward_stock FROM anon, authenticated;
GRANT SELECT ON reward_stock TO authenticated;

INSERT INTO reward_stock (reward_id, name, price, stock, is_available) VALUES
  ('rew-001', 'Paket Alat Tulis', 200, 50, true),
  ('rew-002', 'Buku Catatan', 300, 60, true),
  ('rew-003', 'Totebag', 500, 40, true),
  ('rew-004', 'Tumbler', 700, 30, true)
ON CONFLICT (reward_id) DO NOTHING;

DROP POLICY IF EXISTS "reward_stock_select_signed_in" ON reward_stock;
CREATE POLICY "reward_stock_select_signed_in" ON reward_stock FOR SELECT
TO authenticated
USING (true);
