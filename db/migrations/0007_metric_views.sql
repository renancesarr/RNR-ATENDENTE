CREATE OR REPLACE VIEW metrics_response_rate AS
SELECT
  date_trunc('day', fc.first_message_at) AS day,
  SUM(fc.inbound_messages) AS inbound_messages,
  SUM(fc.outbound_messages) AS outbound_messages,
  CASE WHEN SUM(fc.inbound_messages) = 0 THEN 0
       ELSE SUM(fc.outbound_messages)::numeric / SUM(fc.inbound_messages)::numeric
  END AS response_rate
FROM fact_conversation fc
GROUP BY day
ORDER BY day;

CREATE OR REPLACE VIEW metrics_ttfr AS
SELECT
  date_trunc('day', fc.first_message_at) AS day,
  AVG(fc.ttfr_seconds)::numeric(10,2) AS avg_ttfr_seconds,
  percentile_cont(0.5) WITHIN GROUP (ORDER BY fc.ttfr_seconds) AS p50_ttfr_seconds,
  percentile_cont(0.95) WITHIN GROUP (ORDER BY fc.ttfr_seconds) AS p95_ttfr_seconds
FROM fact_conversation fc
WHERE fc.ttfr_seconds IS NOT NULL
GROUP BY day
ORDER BY day;

CREATE OR REPLACE VIEW metrics_conversion_to_proposal AS
SELECT
  date_trunc('day', COALESCE(fl.quote_request_at, fl.created_at)) AS day,
  COUNT(*) FILTER (WHERE fl.quote_request_at IS NOT NULL) AS quote_requests,
  COUNT(*) FILTER (WHERE fl.quote_sent_at IS NOT NULL) AS quotes_sent,
  CASE WHEN COUNT(*) FILTER (WHERE fl.quote_request_at IS NOT NULL) = 0 THEN 0
       ELSE COUNT(*) FILTER (WHERE fl.quote_sent_at IS NOT NULL)::numeric /
            NULLIF(COUNT(*) FILTER (WHERE fl.quote_request_at IS NOT NULL), 0)
  END AS conversion_rate
FROM fact_lead fl
GROUP BY day
ORDER BY day;
