/*
# Create user profiles with roles

1. New Tables
- `profiles`: one row per sign-in account.
  - `id` (uuid, same as the account id in the sign-in system)
  - `name` (text, display name shown in the app)
  - `role` (text, either 'siswa' for students or 'admin' for staff)
  - `created_at` (timestamp)

2. Functions
- `is_admin()`: returns true when the signed-in account has the admin role.
- `handle_new_user()`: runs after every new sign-up and creates the matching profile with the role 'siswa'.

3. Security
- Row level security is enabled on `profiles`.
- Signed-in users can read only their own profile. Admins can read all profiles.
- Users have no insert, update, or delete rights, so nobody can change their own role from the app.

4. Important notes
- Roles are assigned directly in the database, never from the app.
- The backfill at the end creates profiles for any account that already exists.
*/

CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name text NOT NULL,
  role text NOT NULL DEFAULT 'siswa' CHECK (role IN ('siswa', 'admin')),
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

REVOKE ALL ON profiles FROM anon, authenticated;
GRANT SELECT ON profiles TO authenticated;

CREATE OR REPLACE FUNCTION is_admin()
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin'
  );
$$;

REVOKE EXECUTE ON FUNCTION is_admin() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION is_admin() TO authenticated;

DROP POLICY IF EXISTS "profiles_select_own" ON profiles;
CREATE POLICY "profiles_select_own" ON profiles FOR SELECT
TO authenticated
USING (auth.uid() = id);

DROP POLICY IF EXISTS "profiles_select_admin" ON profiles;
CREATE POLICY "profiles_select_admin" ON profiles FOR SELECT
TO authenticated
USING (is_admin());

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO profiles (id, name)
  VALUES (
    NEW.id,
    left(COALESCE(NULLIF(trim(NEW.raw_user_meta_data->>'name'), ''), split_part(NEW.email, '@', 1)), 80)
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

REVOKE EXECUTE ON FUNCTION handle_new_user() FROM PUBLIC, anon, authenticated;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION handle_new_user();

INSERT INTO profiles (id, name)
SELECT u.id, left(COALESCE(NULLIF(trim(u.raw_user_meta_data->>'name'), ''), split_part(u.email, '@', 1)), 80)
FROM auth.users u
ON CONFLICT (id) DO NOTHING;
