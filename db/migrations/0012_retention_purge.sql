CREATE OR REPLACE FUNCTION fn_apply_retention_purge(p_dry_run boolean DEFAULT true)
RETURNS TABLE(scope text, rows_affected integer) AS
$$
DECLARE
  rec audit_retention%ROWTYPE;
  cutoff timestamptz;
  contact_ids uuid[];
  chat_ids uuid[];
  cnt integer;
BEGIN
  FOR rec IN SELECT * FROM audit_retention WHERE is_active LOOP
    cutoff := now() - make_interval(months => rec.delete_after_months);

    IF rec.applies_to = 'contacts' THEN
      SELECT array_agg(id)
      INTO contact_ids
      FROM contacts
      WHERE created_at <= cutoff;

      IF contact_ids IS NULL THEN
        RETURN NEXT (rec.scope || ':contacts', 0);
        CONTINUE;
      END IF;

      SELECT array_agg(id)
      INTO chat_ids
      FROM chats
      WHERE contact_id = ANY(contact_ids);

      IF p_dry_run THEN
        SELECT COUNT(*) INTO cnt FROM messages WHERE chat_id = ANY(chat_ids);
        RETURN NEXT (rec.scope || ':messages', COALESCE(cnt,0));

        SELECT COUNT(*) INTO cnt FROM chat_history WHERE chat_id = ANY(chat_ids);
        RETURN NEXT (rec.scope || ':chat_history', COALESCE(cnt,0));

        SELECT COUNT(*) INTO cnt FROM fact_conversation WHERE chat_id = ANY(chat_ids);
        RETURN NEXT (rec.scope || ':fact_conversation', COALESCE(cnt,0));

        SELECT COUNT(*) INTO cnt FROM fact_response WHERE chat_id = ANY(chat_ids);
        RETURN NEXT (rec.scope || ':fact_response', COALESCE(cnt,0));

        SELECT COUNT(*) INTO cnt FROM fact_lead WHERE chat_id = ANY(chat_ids);
        RETURN NEXT (rec.scope || ':fact_lead', COALESCE(cnt,0));

        SELECT COUNT(*) INTO cnt FROM event_log WHERE payload ->> 'chat_id' IS NOT NULL AND (payload ->> 'chat_id')::uuid = ANY(chat_ids);
        RETURN NEXT (rec.scope || ':event_log', COALESCE(cnt,0));

        SELECT COUNT(*) INTO cnt FROM chats WHERE id = ANY(chat_ids);
        RETURN NEXT (rec.scope || ':chats', COALESCE(cnt,0));

        SELECT COUNT(*) INTO cnt FROM contacts WHERE id = ANY(contact_ids);
        RETURN NEXT (rec.scope || ':contacts', COALESCE(cnt,0));

      ELSE
        DELETE FROM messages WHERE chat_id = ANY(chat_ids);
        GET DIAGNOSTICS cnt = ROW_COUNT;
        RETURN NEXT (rec.scope || ':messages', cnt);

        DELETE FROM chat_history WHERE chat_id = ANY(chat_ids);
        GET DIAGNOSTICS cnt = ROW_COUNT;
        RETURN NEXT (rec.scope || ':chat_history', cnt);

        DELETE FROM fact_response WHERE chat_id = ANY(chat_ids);
        GET DIAGNOSTICS cnt = ROW_COUNT;
        RETURN NEXT (rec.scope || ':fact_response', cnt);

        DELETE FROM fact_lead WHERE chat_id = ANY(chat_ids);
        GET DIAGNOSTICS cnt = ROW_COUNT;
        RETURN NEXT (rec.scope || ':fact_lead', cnt);

        DELETE FROM fact_conversation WHERE chat_id = ANY(chat_ids);
        GET DIAGNOSTICS cnt = ROW_COUNT;
        RETURN NEXT (rec.scope || ':fact_conversation', cnt);

        DELETE FROM event_log
        WHERE payload ->> 'chat_id' IS NOT NULL
          AND (payload ->> 'chat_id')::uuid = ANY(chat_ids);
        GET DIAGNOSTICS cnt = ROW_COUNT;
        RETURN NEXT (rec.scope || ':event_log', cnt);

        DELETE FROM chats WHERE id = ANY(chat_ids);
        GET DIAGNOSTICS cnt = ROW_COUNT;
        RETURN NEXT (rec.scope || ':chats', cnt);

        DELETE FROM contacts WHERE id = ANY(contact_ids);
        GET DIAGNOSTICS cnt = ROW_COUNT;
        RETURN NEXT (rec.scope || ':contacts', cnt);
      END IF;

    ELSE
      RETURN NEXT (rec.scope || ':unsupported', 0);
    END IF;
  END LOOP;
  RETURN;
END;
$$ LANGUAGE plpgsql;
