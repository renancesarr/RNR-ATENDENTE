CREATE INDEX IF NOT EXISTS idx_contacts_phone_lower ON contacts ((lower(phone)));

CREATE INDEX IF NOT EXISTS idx_chats_conversation_contact ON chats(contact_id, conversation_id);

CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);

CREATE INDEX IF NOT EXISTS idx_fact_conversation_created_at ON fact_conversation(created_at);

CREATE INDEX IF NOT EXISTS idx_event_log_created_at ON event_log(created_at);
