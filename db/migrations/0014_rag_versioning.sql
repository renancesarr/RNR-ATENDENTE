ALTER TABLE rag_documents
  ADD COLUMN IF NOT EXISTS revision integer NOT NULL DEFAULT 1;

CREATE TABLE IF NOT EXISTS rag_document_revisions (
  id bigserial PRIMARY KEY,
  document_id uuid NOT NULL REFERENCES rag_documents(id) ON DELETE CASCADE,
  revision integer NOT NULL,
  content text NOT NULL,
  checksum text NOT NULL,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_rag_document_revisions_doc ON rag_document_revisions(document_id, revision DESC);

CREATE OR REPLACE FUNCTION trg_rag_documents_versioning()
RETURNS trigger AS $$
BEGIN
  IF NEW.checksum <> OLD.checksum THEN
    INSERT INTO rag_document_revisions (document_id, revision, content, checksum, metadata)
    VALUES (OLD.id, OLD.revision, OLD.content, OLD.checksum, OLD.metadata);
    NEW.revision := OLD.revision + 1;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'rag_documents_versioning'
  ) THEN
    CREATE TRIGGER rag_documents_versioning
    BEFORE UPDATE ON rag_documents
    FOR EACH ROW EXECUTE FUNCTION trg_rag_documents_versioning();
  END IF;
END;
$$;
