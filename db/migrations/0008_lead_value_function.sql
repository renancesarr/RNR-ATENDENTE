CREATE OR REPLACE FUNCTION fn_lead_estimated_value(p_chat_id uuid)
RETURNS numeric(12,2) AS
$$
DECLARE
  v_quote numeric(12,2);
  v_inbound integer;
  v_outbound integer;
  v_ttfr integer;
  v_estimate numeric(12,2) := 0;
BEGIN
  SELECT lead_value INTO v_quote
  FROM fact_lead
  WHERE chat_id = p_chat_id
  ORDER BY created_at DESC
  LIMIT 1;

  IF v_quote IS NOT NULL THEN
    RETURN v_quote;
  END IF;

  SELECT inbound_messages, outbound_messages, ttfr_seconds
    INTO v_inbound, v_outbound, v_ttfr
  FROM fact_conversation
  WHERE chat_id = p_chat_id
  ORDER BY created_at DESC
  LIMIT 1;

  IF v_inbound IS NULL THEN
    RETURN 0;
  END IF;

  v_estimate := 50
    + COALESCE(v_inbound, 0) * 5
    + COALESCE(v_outbound, 0) * 2;

  IF v_ttfr IS NOT NULL AND v_ttfr <= 60 THEN
    v_estimate := v_estimate * 1.1; -- bônus para respostas rápidas
  END IF;

  RETURN round(v_estimate, 2);
END;
$$ LANGUAGE plpgsql STABLE;
