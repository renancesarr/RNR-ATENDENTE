CREATE TABLE IF NOT EXISTS rag_sources (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  source_type text NOT NULL DEFAULT 'document',
  description text,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT rag_sources_name_unique UNIQUE (name)
);

CREATE TABLE IF NOT EXISTS rag_documents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  source_id uuid NOT NULL REFERENCES rag_sources(id) ON DELETE CASCADE,
  external_id text,
  title text,
  content text NOT NULL,
  language text DEFAULT 'pt-BR',
  checksum text NOT NULL,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT rag_documents_checksum_unique UNIQUE (checksum)
);

CREATE TABLE IF NOT EXISTS rag_embeddings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id uuid NOT NULL REFERENCES rag_documents(id) ON DELETE CASCADE,
  chunk_index integer NOT NULL,
  embedding vector(1536) NOT NULL,
  chunk text NOT NULL,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT rag_embeddings_document_chunk_unique UNIQUE (document_id, chunk_index)
);

CREATE INDEX IF NOT EXISTS idx_rag_documents_source ON rag_documents(source_id);
CREATE INDEX IF NOT EXISTS idx_rag_embeddings_document ON rag_embeddings(document_id);
CREATE INDEX IF NOT EXISTS idx_rag_embeddings_metadata ON rag_embeddings USING GIN (metadata);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'set_timestamp_rag_sources'
  ) THEN
    CREATE TRIGGER set_timestamp_rag_sources
    BEFORE UPDATE ON rag_sources
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'set_timestamp_rag_documents'
  ) THEN
    CREATE TRIGGER set_timestamp_rag_documents
    BEFORE UPDATE ON rag_documents
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'set_timestamp_rag_embeddings'
  ) THEN
    CREATE TRIGGER set_timestamp_rag_embeddings
    BEFORE UPDATE ON rag_embeddings
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;
END;
$$;
