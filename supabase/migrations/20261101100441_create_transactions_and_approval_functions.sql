/*
# Create transactions with approval functions

1. New Tables
- `transactions`: every deposit, point addition, and reward redemption.
  - `user_id`: the student who owns the record (filled automatically from the signed-in account)
  - `type`: 'setoran' (deposit), 'penambahan' (points added), or 'penukaran' (reward redeemed)
  - `ref_id`, `title`, `weight` (kg), `points`
  - `status`: 'menunggu' (waiting), 'berhasil' (approved), or 'ditolak' (rejected)
  - `claim_code`, `claim_status` for reward claims: 'menunggu', 'diverifikasi', 'selesai'
  - `created_at`

2. Functions (all run on the server and check who is calling)
- `submit_deposit`: a student submits a deposit. It always starts as waiting.
- `approve_deposit`: an admin approves a deposit. Points are calculated on the server and added to the student's balance.
- `reject_deposit`: an admin rejects a deposit.
- `redeem_reward`: a student redeems a reward. Balance and stock are checked on the server and a claim code is created.
- `verify_claim`: an admin verifies a claim code.
- `complete_claim`: an admin marks a claim as received.

3. Security
- Row level security is enabled. Students can read only their own transactions. Admins can read all transactions.
- Nobody can insert, update, or delete rows directly. Every change goes through the functions above.

4. Important notes
- Points are added only after an admin approves a deposit.
- Points on a deposit are never sent by the app; they come from the waste catalog table.
*/

CREATE TABLE IF NOT EXISTS transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL DEFAULT auth.uid() REFERENCES profiles(id) ON DELETE CASCADE,
  type text NOT NULL CHECK (type IN ('setoran', 'penambahan', 'penukaran')),
  ref_id text,
  title text NOT NULL,
  weight numeric(10, 2) CHECK (weight IS NULL OR weight > 0),
  points integer CHECK (points IS NULL OR points >= 0),
  status text NOT NULL CHECK (status IN ('menunggu', 'berhasil', 'ditolak')),
  claim_code text,
  claim_status text CHECK (claim_status IS NULL OR claim_status IN ('menunggu', 'diverifikasi', 'selesai')),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS transactions_user_created_idx ON transactions (user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS transactions_status_idx ON transactions (status);

ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON transactions FROM anon, authenticated;
GRANT SELECT ON transactions TO authenticated;

DROP POLICY IF EXISTS "transactions_select_own" ON transactions;
CREATE POLICY "transactions_select_own" ON transactions FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "transactions_select_admin" ON transactions;
CREATE POLICY "transactions_select_admin" ON transactions FOR SELECT
TO authenticated
USING (is_admin());

CREATE OR REPLACE FUNCTION submit_deposit(p_item_id text, p_weight numeric)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_title text;
  v_id uuid;
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF p_weight IS NULL OR p_weight < 0.01 OR p_weight > 1000 THEN
    RAISE EXCEPTION 'Invalid weight';
  END IF;

  SELECT title INTO v_title FROM waste_items WHERE item_id = p_item_id;
  IF v_title IS NULL THEN
    RAISE EXCEPTION 'Unknown waste item';
  END IF;

  INSERT INTO transactions (user_id, type, ref_id, title, weight, status)
  VALUES (auth.uid(), 'setoran', p_item_id, v_title, round(p_weight, 2), 'menunggu')
  RETURNING id INTO v_id;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION approve_deposit(p_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_tx transactions%ROWTYPE;
  v_points_per_kg integer;
BEGIN
  IF NOT is_admin() THEN
    RAISE EXCEPTION 'Not authorized';
  END IF;

  SELECT * INTO v_tx FROM transactions
  WHERE id = p_id AND type = 'setoran' AND status = 'menunggu'
  FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Deposit is not waiting for approval';
  END IF;

  SELECT points_per_kg INTO v_points_per_kg FROM waste_items WHERE item_id = v_tx.ref_id;
  IF v_points_per_kg IS NULL THEN
    RAISE EXCEPTION 'Points for this waste type are not set';
  END IF;

  UPDATE transactions SET status = 'berhasil' WHERE id = v_tx.id;

  INSERT INTO transactions (user_id, type, ref_id, title, points, status)
  VALUES (
    v_tx.user_id,
    'penambahan',
    v_tx.id::text,
    v_tx.title,
    round(v_points_per_kg * v_tx.weight)::integer,
    'berhasil'
  );
END;
$$;

CREATE OR REPLACE FUNCTION reject_deposit(p_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT is_admin() THEN
    RAISE EXCEPTION 'Not authorized';
  END IF;

  UPDATE transactions SET status = 'ditolak'
  WHERE id = p_id AND type = 'setoran' AND status = 'menunggu';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Deposit is not waiting for approval';
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION redeem_reward(p_reward_id text)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_reward reward_stock%ROWTYPE;
  v_balance integer;
  v_code text;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  SELECT * INTO v_reward FROM reward_stock WHERE reward_id = p_reward_id FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Reward not found';
  END IF;
  IF NOT v_reward.is_available OR v_reward.stock <= 0 THEN
    RAISE EXCEPTION 'Reward out of stock';
  END IF;

  SELECT COALESCE(SUM(CASE WHEN type = 'penambahan' THEN points ELSE -points END), 0)::integer
  INTO v_balance
  FROM transactions
  WHERE user_id = v_uid
    AND type IN ('penambahan', 'penukaran')
    AND status <> 'ditolak';

  IF v_balance < v_reward.price THEN
    RAISE EXCEPTION 'Insufficient points';
  END IF;

  v_code := 'RP-' || upper(substr(md5(random()::text || clock_timestamp()::text), 1, 6));

  UPDATE reward_stock SET stock = stock - 1 WHERE reward_id = p_reward_id;

  INSERT INTO transactions (user_id, type, ref_id, title, points, status, claim_code, claim_status)
  VALUES (v_uid, 'penukaran', p_reward_id, v_reward.name, v_reward.price, 'menunggu', v_code, 'menunggu');

  RETURN v_code;
END;
$$;

CREATE OR REPLACE FUNCTION verify_claim(p_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT is_admin() THEN
    RAISE EXCEPTION 'Not authorized';
  END IF;

  UPDATE transactions SET claim_status = 'diverifikasi', status = 'berhasil'
  WHERE id = p_id AND type = 'penukaran' AND claim_status = 'menunggu';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Claim is not waiting for verification';
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION complete_claim(p_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NOT is_admin() THEN
    RAISE EXCEPTION 'Not authorized';
  END IF;

  UPDATE transactions SET claim_status = 'selesai'
  WHERE id = p_id AND type = 'penukaran' AND claim_status = 'diverifikasi';
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Claim is not verified yet';
  END IF;
END;
$$;

REVOKE EXECUTE ON FUNCTION submit_deposit(text, numeric) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION approve_deposit(uuid) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION reject_deposit(uuid) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION redeem_reward(text) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION verify_claim(uuid) FROM PUBLIC, anon;
REVOKE EXECUTE ON FUNCTION complete_claim(uuid) FROM PUBLIC, anon;

GRANT EXECUTE ON FUNCTION submit_deposit(text, numeric) TO authenticated;
GRANT EXECUTE ON FUNCTION approve_deposit(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION reject_deposit(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION redeem_reward(text) TO authenticated;
GRANT EXECUTE ON FUNCTION verify_claim(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION complete_claim(uuid) TO authenticated;
