CREATE OR REPLACE FUNCTION fn_normalize_phone(p_input text, p_default_country_code text DEFAULT '55')
RETURNS text AS
$$
DECLARE
  sanitized text;
BEGIN
  IF p_input IS NULL OR length(trim(p_input)) = 0 THEN
    RETURN NULL;
  END IF;

  sanitized := regexp_replace(p_input, '[^0-9+]', '', 'g');

  IF sanitized LIKE '+%' THEN
    RETURN sanitized;
  ELSIF sanitized LIKE '00%' THEN
    RETURN '+' || substr(sanitized, 3);
  ELSE
    sanitized := regexp_replace(sanitized, '^0+', '');
    RETURN '+' || p_default_country_code || sanitized;
  END IF;
END;
$$ LANGUAGE plpgsql IMMUTABLE;
