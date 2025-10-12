-- Verifica FKs e métricas básicas das tabelas de fatos
SET search_path TO public;

DO $$
DECLARE
  v_missing integer;
BEGIN
  SELECT COUNT(*) INTO v_missing
  FROM fact_conversation fc
  LEFT JOIN contacts c ON c.id = fc.contact_id
  WHERE c.id IS NULL;

  IF v_missing > 0 THEN
    RAISE EXCEPTION 'fact_conversation possui % registros sem contato associado', v_missing;
  END IF;

  SELECT COUNT(*) INTO v_missing
  FROM fact_conversation fc
  LEFT JOIN chats ch ON ch.id = fc.chat_id
  WHERE ch.id IS NULL;

  IF v_missing > 0 THEN
    RAISE EXCEPTION 'fact_conversation possui % registros sem chat associado', v_missing;
  END IF;

  SELECT COUNT(*) INTO v_missing
  FROM fact_response fr
  LEFT JOIN chats ch ON ch.id = fr.chat_id
  WHERE ch.id IS NULL;

  IF v_missing > 0 THEN
    RAISE EXCEPTION 'fact_response possui % registros sem chat associado', v_missing;
  END IF;

  SELECT COUNT(*) INTO v_missing
  FROM fact_lead fl
  WHERE fl.quote_request_at IS NULL AND fl.quote_sent_at IS NOT NULL;

  IF v_missing > 0 THEN
    RAISE EXCEPTION 'fact_lead possui % registros com quote_sent_at sem quote_request_at', v_missing;
  END IF;

  SELECT COUNT(*) INTO v_missing
  FROM fact_conversation
  WHERE inbound_messages < 0 OR outbound_messages < 0;

  IF v_missing > 0 THEN
    RAISE EXCEPTION 'fact_conversation possui contagens negativas';
  END IF;

  -- Nenhuma exceção disparada: testes passaram
END;
$$;
