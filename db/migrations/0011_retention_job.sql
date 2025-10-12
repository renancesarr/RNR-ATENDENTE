CREATE OR REPLACE FUNCTION fn_apply_retention_scrub()
RETURNS TABLE(scope text, rows_affected integer) AS
$$
DECLARE
  rec audit_retention%ROWTYPE;
  cutoff timestamptz;
  affected integer;
BEGIN
  FOR rec IN SELECT * FROM audit_retention WHERE is_active LOOP
    cutoff := now() - make_interval(days => rec.scrub_after_days);

    IF rec.applies_to = 'contacts' THEN
      UPDATE contacts c
      SET
        phone = 'anon-' || encode(digest(c.phone || c.id::text, 'sha256'), 'hex'),
        name = NULL,
        updated_at = now()
      WHERE c.created_at <= cutoff
        AND c.phone NOT LIKE 'anon-%';

      GET DIAGNOSTICS affected = ROW_COUNT;
      RETURN NEXT (rec.scope, affected);

    ELSIF rec.applies_to = 'messages' THEN
      UPDATE messages m
      SET
        content = jsonb_set(m.content, '{text}', to_jsonb('[redacted]'), true),
        raw_payload = NULL,
        updated_at = now()
      WHERE m.created_at <= cutoff
        AND (m.content ? 'text');

      GET DIAGNOSTICS affected = ROW_COUNT;
      RETURN NEXT (rec.scope, affected);

    ELSE
      affected := 0;
      RETURN NEXT (rec.scope, affected);
    END IF;
  END LOOP;
  RETURN;
END;
$$ LANGUAGE plpgsql;
