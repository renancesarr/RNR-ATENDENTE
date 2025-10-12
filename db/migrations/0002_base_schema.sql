-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Contacts (WhatsApp leads)
CREATE TABLE IF NOT EXISTS contacts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  external_id text,
  phone text NOT NULL,
  name text,
  tags text[] DEFAULT ARRAY[]::text[],
  timezone text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT contacts_phone_unique UNIQUE (phone)
);

-- Chats (Conversation envelope)
CREATE TABLE IF NOT EXISTS chats (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  contact_id uuid NOT NULL REFERENCES contacts(id),
  conversation_id text NOT NULL,
  status text NOT NULL DEFAULT 'open',
  last_message_at timestamptz,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT chats_conversation_unique UNIQUE (conversation_id)
);

CREATE INDEX IF NOT EXISTS idx_chats_contact ON chats(contact_id);
CREATE INDEX IF NOT EXISTS idx_chats_status ON chats(status);

-- Messages
CREATE TABLE IF NOT EXISTS messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  chat_id uuid NOT NULL REFERENCES chats(id),
  message_id text NOT NULL,
  direction text NOT NULL CHECK (direction IN ('inbound','outbound')),
  channel text NOT NULL DEFAULT 'whatsapp',
  sender jsonb,
  content jsonb NOT NULL,
  raw_payload jsonb,
  delivered_at timestamptz,
  processed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT messages_message_id_unique UNIQUE (message_id)
);

CREATE INDEX IF NOT EXISTS idx_messages_chat_created_at ON messages(chat_id, created_at);
CREATE INDEX IF NOT EXISTS idx_messages_direction ON messages(direction);

-- Chat history / events (handoff, status changes, notes)
CREATE TABLE IF NOT EXISTS chat_history (
  id bigserial PRIMARY KEY,
  chat_id uuid NOT NULL REFERENCES chats(id),
  event_type text NOT NULL,
  payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  actor text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_chat_history_chat ON chat_history(chat_id, created_at DESC);

-- Trigger to keep updated_at in sync
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'set_timestamp_contacts'
  ) THEN
    CREATE TRIGGER set_timestamp_contacts
    BEFORE UPDATE ON contacts
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'set_timestamp_chats'
  ) THEN
    CREATE TRIGGER set_timestamp_chats
    BEFORE UPDATE ON chats
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'set_timestamp_messages'
  ) THEN
    CREATE TRIGGER set_timestamp_messages
    BEFORE UPDATE ON messages
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;
END;
$$;
