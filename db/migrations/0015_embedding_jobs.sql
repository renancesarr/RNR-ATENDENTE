CREATE TABLE IF NOT EXISTS rag_embedding_jobs (
  id bigserial PRIMARY KEY,
  document_id uuid NOT NULL REFERENCES rag_documents(id) ON DELETE CASCADE,
  status text NOT NULL DEFAULT 'pending',
  retries integer NOT NULL DEFAULT 0,
  scheduled_at timestamptz NOT NULL DEFAULT now(),
  started_at timestamptz,
  finished_at timestamptz,
  error_message text,
  payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_rag_embedding_jobs_status ON rag_embedding_jobs(status, scheduled_at);

CREATE OR REPLACE FUNCTION trg_rag_documents_versioning()
RETURNS trigger AS $$
BEGIN
  IF NEW.checksum <> OLD.checksum THEN
    INSERT INTO rag_document_revisions (document_id, revision, content, checksum, metadata)
    VALUES (OLD.id, OLD.revision, OLD.content, OLD.checksum, OLD.metadata);
    NEW.revision := OLD.revision + 1;

    INSERT INTO rag_embedding_jobs (document_id, status, payload)
    VALUES (NEW.id, 'pending', jsonb_build_object('reason', 'document_update', 'revision', NEW.revision));
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'rag_embedding_jobs_updated_at'
  ) THEN
    CREATE TRIGGER rag_embedding_jobs_updated_at
    BEFORE UPDATE ON rag_embedding_jobs
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;
END;
$$;
