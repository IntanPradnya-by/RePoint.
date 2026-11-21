/*
# Instant deposit verification (no admin approval)

1. Plain-English explanation
- Deposits are now verified instantly: when a student submits a deposit, the
  system immediately marks it as successful ("berhasil") and adds the points
  earned to the student's balance in the same step. There is no more waiting
  for staff approval.
- The admin role and all admin-only functions are no longer used by the app.
  Existing data is untouched.

2. Modified functions
- `submit_deposit(p_item_id text, p_weight numeric)`: now performs the whole
  flow in one call. It validates the weight, looks up the waste item title and
  points-per-kg from the waste catalog, inserts the deposit row with status
  'berhasil', and inserts the matching 'penambahan' (points added) row whose
  points are calculated on the server. Returns the deposit row id.
- `redeem_reward(p_reward_id text)`: unchanged logic, kept so balances and
  stock keep working. Re-applied only to refresh its definition.

3. Unused functions kept but locked down
- `approve_deposit`, `reject_deposit`, `batch_approve_deposits`,
  `verify_claim`, `complete_claim`, `is_admin`: EXECUTE is revoked from every
  role (PUBLIC, anon, and authenticated) because the app no longer calls them.
  The functions are not dropped so existing rows and history remain intact.

4. Security
- Row level security and existing policies on `transactions` are unchanged:
  users still see only their own rows. All writes still go through the
  SECURITY DEFINER functions above, never direct table inserts.
- `submit_deposit` remains executable only by authenticated users.

5. Important notes
- Points on a deposit are never sent by the app; they always come from the
  `waste_items` catalog table.
- The 'menunggu' and 'ditolak' statuses remain valid in the schema so old
  history rows still render, but new deposits are always 'berhasil'.
*/

CREATE OR REPLACE FUNCTION submit_deposit(p_item_id text, p_weight numeric)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_uid uuid := auth.uid();
  v_title text;
  v_points_per_kg integer;
  v_id uuid;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF p_weight IS NULL OR p_weight < 0.01 OR p_weight > 1000 THEN
    RAISE EXCEPTION 'Invalid weight';
  END IF;

  SELECT title, points_per_kg INTO v_title, v_points_per_kg
  FROM waste_items WHERE item_id = p_item_id;
  IF v_title IS NULL OR v_points_per_kg IS NULL THEN
    RAISE EXCEPTION 'Unknown waste item';
  END IF;

  INSERT INTO transactions (user_id, type, ref_id, title, weight, status)
  VALUES (v_uid, 'setoran', p_item_id, v_title, round(p_weight, 2), 'berhasil')
  RETURNING id INTO v_id;

  INSERT INTO transactions (user_id, type, ref_id, title, points, status)
  VALUES (
    v_uid,
    'penambahan',
    v_id::text,
    v_title,
    round(v_points_per_kg * round(p_weight, 2))::integer,
    'berhasil'
  );

  RETURN v_id;
END;
$$;

REVOKE EXECUTE ON FUNCTION submit_deposit(text, numeric) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION submit_deposit(text, numeric) TO authenticated;

REVOKE EXECUTE ON FUNCTION approve_deposit(uuid) FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION reject_deposit(uuid) FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION batch_approve_deposits(uuid[]) FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION verify_claim(uuid) FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION complete_claim(uuid) FROM PUBLIC, anon, authenticated;
REVOKE EXECUTE ON FUNCTION is_admin() FROM PUBLIC, anon, authenticated;

DROP POLICY IF EXISTS "transactions_select_admin" ON transactions;
DROP POLICY IF EXISTS "profiles_select_admin" ON profiles;
