CREATE TABLE IF NOT EXISTS event_log (
  id bigserial PRIMARY KEY,
  event_id text NOT NULL,
  event_type text NOT NULL,
  source text NOT NULL DEFAULT 'unknown',
  payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  occurred_at timestamptz NOT NULL,
  received_at timestamptz NOT NULL DEFAULT now(),
  processed_at timestamptz,
  status text NOT NULL DEFAULT 'pending',
  error_message text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT event_log_event_id_unique UNIQUE (event_id)
);

CREATE INDEX IF NOT EXISTS idx_event_log_type ON event_log(event_type);
CREATE INDEX IF NOT EXISTS idx_event_log_status ON event_log(status);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'set_timestamp_event_log'
  ) THEN
    CREATE TRIGGER set_timestamp_event_log
    BEFORE UPDATE ON event_log
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;
END;
$$;
