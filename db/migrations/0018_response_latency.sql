CREATE OR REPLACE FUNCTION fn_register_response_latency(
  p_message_id text,
  p_chat_id uuid,
  p_contact_id uuid,
  p_responder_type text,
  p_inbound_at timestamptz,
  p_outbound_at timestamptz
) RETURNS void AS
$$
DECLARE
  v_latency_ms integer;
BEGIN
  IF p_inbound_at IS NULL OR p_outbound_at IS NULL THEN
    RAISE EXCEPTION 'Timestamps inválidos para cálculo de latência';
  END IF;

  v_latency_ms := floor(extract(epoch FROM (p_outbound_at - p_inbound_at)) * 1000);
  IF v_latency_ms < 0 THEN
    v_latency_ms := 0;
  END IF;

  INSERT INTO fact_response (message_id, chat_id, contact_id, responder_type, response_time_ms)
  VALUES (p_message_id, p_chat_id, p_contact_id, p_responder_type, v_latency_ms)
  ON CONFLICT (message_id) DO UPDATE SET
    chat_id = EXCLUDED.chat_id,
    contact_id = EXCLUDED.contact_id,
    responder_type = EXCLUDED.responder_type,
    response_time_ms = EXCLUDED.response_time_ms,
    created_at = now();
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE VIEW metrics_response_latency AS
SELECT
  date_trunc('day', created_at) AS day,
  avg(response_time_ms)::numeric(10,2) AS avg_ms,
  percentile_cont(0.5) WITHIN GROUP (ORDER BY response_time_ms) AS p50_ms,
  percentile_cont(0.95) WITHIN GROUP (ORDER BY response_time_ms) AS p95_ms,
  count(*) AS samples
FROM fact_response
GROUP BY day
ORDER BY day;
