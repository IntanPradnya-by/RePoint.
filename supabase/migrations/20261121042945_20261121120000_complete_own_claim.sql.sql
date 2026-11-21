/*
# Self-service claim completion (no staff verification)

1. Plain-English explanation
- Reward redemptions no longer need staff verification. After a user redeems
  a reward, they can mark it as received themselves on the claim page.
- A new server function lets a user complete ONLY their own redemption, so
  nobody can touch another user's claims.

2. New functions
- `complete_own_claim(p_id uuid)`: marks one of the caller's own 'penukaran'
  (redemption) rows as claim_status 'selesai' (received). Only works when the
  row belongs to the signed-in user and its claim is still open.

3. Security
- SECURITY DEFINER so it can write to `transactions`, but the WHERE clause
  pins user_id to auth.uid(), so each user can only complete their own claim.
- EXECUTE granted to authenticated only; revoked from PUBLIC and anon.

4. Important notes
- The old staff-only `complete_claim`/`verify_claim` functions stay revoked
  from every role; this new function replaces them in the app.
*/

CREATE OR REPLACE FUNCTION complete_own_claim(p_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  UPDATE transactions
  SET claim_status = 'selesai', status = 'berhasil'
  WHERE id = p_id
    AND user_id = auth.uid()
    AND type = 'penukaran'
    AND claim_status IS NOT NULL
    AND claim_status <> 'selesai';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Claim not found or already completed';
  END IF;
END;
$$;

REVOKE EXECUTE ON FUNCTION complete_own_claim(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION complete_own_claim(uuid) TO authenticated;
