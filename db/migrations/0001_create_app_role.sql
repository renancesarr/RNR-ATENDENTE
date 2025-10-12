\set app_user      :POSTGRES_APP_USER
\set app_password  :POSTGRES_APP_PASSWORD
\set app_db        :POSTGRES_APP_DB

DO
$$
DECLARE
  v_app_user CONSTANT text := :app_user;
  v_app_password CONSTANT text := :app_password;
  v_app_db CONSTANT text := :app_db;
BEGIN
  IF v_app_password IS NULL OR length(v_app_password) = 0 THEN
    RAISE EXCEPTION 'POSTGRES_APP_PASSWORD must be provided when running this migration.';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = v_app_user) THEN
    EXECUTE format('CREATE ROLE %I LOGIN PASSWORD %L', v_app_user, v_app_password);
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = v_app_db) THEN
    EXECUTE format('CREATE DATABASE %I OWNER %I TEMPLATE template0', v_app_db, v_app_user);
  END IF;

  EXECUTE format('GRANT ALL PRIVILEGES ON DATABASE %I TO %I', v_app_db, v_app_user);
END
$$ LANGUAGE plpgsql;
