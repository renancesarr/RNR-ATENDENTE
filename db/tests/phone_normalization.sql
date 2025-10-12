SET search_path TO public;

DO $$
DECLARE
  v_result text;
BEGIN
  SELECT fn_normalize_phone('+5511999999999') INTO v_result;
  IF v_result <> '+5511999999999' THEN
    RAISE EXCEPTION 'Falha: esperado +5511999999999, obtido %', v_result;
  END IF;

  SELECT fn_normalize_phone('011 99999-9999') INTO v_result;
  IF v_result <> '+550119999999999' THEN
    RAISE EXCEPTION 'Falha: esperado +550119999999999, obtido %', v_result;
  END IF;

  SELECT fn_normalize_phone('00 1 202-555-0123', '1') INTO v_result;
  IF v_result <> '+12025550123' THEN
    RAISE EXCEPTION 'Falha: esperado +12025550123, obtido %', v_result;
  END IF;

  SELECT fn_normalize_phone('202-555-0123', '1') INTO v_result;
  IF v_result <> '+12025550123' THEN
    RAISE EXCEPTION 'Falha: esperado +12025550123, obtido %', v_result;
  END IF;

  SELECT fn_normalize_phone(NULL) INTO v_result;
  IF v_result IS NOT NULL THEN
    RAISE EXCEPTION 'Falha: esperado NULL, obtido %', v_result;
  END IF;
END;
$$;
