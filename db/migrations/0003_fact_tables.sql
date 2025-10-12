CREATE TABLE IF NOT EXISTS fact_conversation (
  id bigserial PRIMARY KEY,
  chat_id uuid NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
  contact_id uuid NOT NULL REFERENCES contacts(id),
  conversation_id text NOT NULL,
  first_message_at timestamptz NOT NULL,
  first_response_at timestamptz,
  closed_at timestamptz,
  inbound_messages integer NOT NULL DEFAULT 0,
  outbound_messages integer NOT NULL DEFAULT 0,
  ttfr_seconds integer,
  status text NOT NULL DEFAULT 'open',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT fact_conversation_conversation_unique UNIQUE (conversation_id)
);

CREATE INDEX IF NOT EXISTS idx_fact_conversation_chat ON fact_conversation(chat_id);
CREATE INDEX IF NOT EXISTS idx_fact_conversation_status ON fact_conversation(status);

CREATE TABLE IF NOT EXISTS fact_response (
  id bigserial PRIMARY KEY,
  message_id text NOT NULL,
  chat_id uuid NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
  contact_id uuid NOT NULL REFERENCES contacts(id),
  responder_type text NOT NULL CHECK (responder_type IN ('bot','human')),
  response_time_ms integer,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_fact_response_chat ON fact_response(chat_id);
CREATE INDEX IF NOT EXISTS idx_fact_response_message ON fact_response(message_id);

CREATE TABLE IF NOT EXISTS fact_lead (
  id bigserial PRIMARY KEY,
  chat_id uuid NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
  contact_id uuid NOT NULL REFERENCES contacts(id),
  quote_request_at timestamptz,
  quote_sent_at timestamptz,
  lead_value numeric(12,2),
  currency char(3) NOT NULL DEFAULT 'BRL',
  status text NOT NULL DEFAULT 'pending',
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_fact_lead_chat ON fact_lead(chat_id);
CREATE INDEX IF NOT EXISTS idx_fact_lead_status ON fact_lead(status);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'set_timestamp_fact_conversation'
  ) THEN
    CREATE TRIGGER set_timestamp_fact_conversation
    BEFORE UPDATE ON fact_conversation
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'set_timestamp_fact_lead'
  ) THEN
    CREATE TRIGGER set_timestamp_fact_lead
    BEFORE UPDATE ON fact_lead
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;
END;
$$;
