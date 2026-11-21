-- Add a batch-approve function so an admin can approve multiple pending deposits in one call.
-- This speeds up verification so students don't wait days for their points.

CREATE OR REPLACE FUNCTION batch_approve_deposits(p_ids uuid[])
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_count integer := 0;
  v_id uuid;
  v_tx transactions%ROWTYPE;
  v_points_per_kg integer;
BEGIN
  IF NOT is_admin() THEN
    RAISE EXCEPTION 'Not authorized';
  END IF;

  IF p_ids IS NULL OR array_length(p_ids, 1) IS NULL THEN
    RETURN 0;
  END IF;

  FOREACH v_id IN ARRAY p_ids LOOP
    SELECT * INTO v_tx FROM transactions
    WHERE id = v_id AND type = 'setoran' AND status = 'menunggu'
    FOR UPDATE;

    IF NOT FOUND THEN
      CONTINUE;
    END IF;

    SELECT points_per_kg INTO v_points_per_kg FROM waste_items WHERE item_id = v_tx.ref_id;
    IF v_points_per_kg IS NULL THEN
      CONTINUE;
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

    v_count := v_count + 1;
  END LOOP;

  RETURN v_count;
END;
$$;

REVOKE EXECUTE ON FUNCTION batch_approve_deposits(uuid[]) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION batch_approve_deposits(uuid[]) TO authenticated;
