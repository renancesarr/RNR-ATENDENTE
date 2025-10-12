CREATE TABLE IF NOT EXISTS bot_config (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  model text NOT NULL DEFAULT 'gpt-4o-mini',
  temperature numeric(3,2) NOT NULL DEFAULT 0.30,
  max_output_tokens integer NOT NULL DEFAULT 2048,
  debounce_seconds integer NOT NULL DEFAULT 30,
  fallback_model text,
  daily_budget_usd numeric(8,2) NOT NULL DEFAULT 50.00,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT bot_config_name_unique UNIQUE (name)
);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'set_timestamp_bot_config'
  ) THEN
    CREATE TRIGGER set_timestamp_bot_config
    BEFORE UPDATE ON bot_config
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;
END;
$$;
