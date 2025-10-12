SET search_path TO public;

DO $$
DECLARE
  v_windows integer;
  v_first interval;
  v_second interval;
  v_contact uuid;
  v_chat uuid;
BEGIN
  INSERT INTO contacts (phone, name)
  VALUES ('+5511987654321', 'Teste Janela')
  ON CONFLICT (phone) DO UPDATE SET updated_at = now()
  RETURNING id INTO v_contact;

  INSERT INTO chats (contact_id, conversation_id, status)
  VALUES (v_contact, 'test-window-chat', 'open')
  ON CONFLICT (conversation_id) DO UPDATE SET updated_at = now()
  RETURNING id INTO v_chat;

  DELETE FROM messages WHERE chat_id = v_chat;

  INSERT INTO messages (chat_id, message_id, direction, channel, content, created_at)
  VALUES
    (v_chat, 'm1', 'inbound', 'whatsapp', '{"text":"oi"}', now() - interval '50 minutes'),
    (v_chat, 'm2', 'outbound', 'whatsapp', '{"text":"ola"}', now() - interval '49 minutes'),
    (v_chat, 'm3', 'inbound', 'whatsapp', '{"text":"t2"}', now() - interval '10 minutes'),
    (v_chat, 'm4', 'outbound', 'whatsapp', '{"text":"t3"}', now() - interval '9 minutes');

  SELECT count(*) INTO v_windows FROM fn_message_windows(30) WHERE chat_id = v_chat;
  IF v_windows <> 2 THEN
    RAISE EXCEPTION 'Esperado 2 janelas, obtido %', v_windows;
  END IF;

  SELECT (end_at - start_at)
  INTO v_first
  FROM fn_message_windows(30)
  WHERE chat_id = v_chat AND window_index = 1;

  IF v_first < interval '0 minutes' THEN
    RAISE EXCEPTION 'Janela 1 inválida';
  END IF;

  SELECT (end_at - start_at)
  INTO v_second
  FROM fn_message_windows(30)
  WHERE chat_id = v_chat AND window_index = 2;

  IF v_second < interval '0 minutes' THEN
    RAISE EXCEPTION 'Janela 2 inválida';
  END IF;

  DELETE FROM messages WHERE chat_id = v_chat;
  DELETE FROM chats WHERE id = v_chat;
  DELETE FROM contacts WHERE id = v_contact;
END;
$$;
