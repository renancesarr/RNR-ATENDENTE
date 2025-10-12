CREATE TABLE IF NOT EXISTS audit_retention (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  scope text NOT NULL,
  applies_to text NOT NULL,
  scrub_after_days integer NOT NULL,
  delete_after_months integer NOT NULL,
  justification text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT audit_retention_scope_unique UNIQUE (scope)
);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'set_timestamp_audit_retention'
  ) THEN
    CREATE TRIGGER set_timestamp_audit_retention
    BEFORE UPDATE ON audit_retention
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;
END;
$$;
