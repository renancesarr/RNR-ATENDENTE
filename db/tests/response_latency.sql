SET search_path TO public;

DO $$
DECLARE
  v_contact uuid;
  v_chat uuid;
  v_latency integer;
BEGIN
  INSERT INTO contacts (phone, name)
  VALUES ('+5511999990000', 'Latency Test')
  ON CONFLICT (phone) DO UPDATE SET updated_at = now()
  RETURNING id INTO v_contact;

  INSERT INTO chats (contact_id, conversation_id, status)
  VALUES (v_contact, 'latency-chat', 'open')
  ON CONFLICT (conversation_id) DO UPDATE SET updated_at = now()
  RETURNING id INTO v_chat;

  PERFORM fn_register_response_latency('msg-latency', v_chat, v_contact, 'bot', now() - interval '4 seconds', now());

  SELECT response_time_ms INTO v_latency FROM fact_response WHERE message_id = 'msg-latency';
  IF v_latency < 3990 OR v_latency > 4010 THEN
    RAISE EXCEPTION 'Latência fora do esperado: %', v_latency;
  END IF;

  DELETE FROM fact_response WHERE message_id = 'msg-latency';
  DELETE FROM chats WHERE id = v_chat;
  DELETE FROM contacts WHERE id = v_contact;
END;
$$;
