CREATE TABLE IF NOT EXISTS catalog_products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  sku text NOT NULL,
  name text NOT NULL,
  description text,
  price numeric(10,2) NOT NULL,
  currency char(3) NOT NULL DEFAULT 'BRL',
  category text,
  is_active boolean NOT NULL DEFAULT true,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT catalog_products_sku_unique UNIQUE (sku)
);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger WHERE tgname = 'set_timestamp_catalog_products'
  ) THEN
    CREATE TRIGGER set_timestamp_catalog_products
    BEFORE UPDATE ON catalog_products
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
  END IF;
END;
$$;

INSERT INTO catalog_products (sku, name, description, price, currency, category, metadata)
VALUES
  ('KIT-ONBOARD', 'Kit Onboarding WhatsApp', 'Material de boas-vindas impresso e digital', 149.90, 'BRL', 'Onboarding', '{"sla":"48h"}'::jsonb),
  ('BOT-TREINO', 'Sessão de Treinamento Bot', 'Sessão remota de 1h para ajustes do bot', 299.00, 'BRL', 'Serviço', '{"sprint":"setup"}'::jsonb),
  ('SUP-PRIOR', 'Suporte Prioritário 30 dias', 'Canal prioritário via Slack + telefone comercial', 449.00, 'BRL', 'Suporte', '{"horario":"09h-18h"}'::jsonb),
  ('ADD-CRM', 'Integração CRM Básica', 'Integração unidirecional com CRM interno', 599.00, 'BRL', 'Integração', '{"crm":"PipeRun"}'::jsonb),
  ('ADD-RAG', 'Pacote Conteúdo RAG', 'Curadoria e ingestão de 50 documentos', 799.00, 'BRL', 'RAG', '{"docs":50}'::jsonb),
  ('ADD-VOICE', 'Canal Voz/Audio Beta', 'Suporte a mensagens de voz com transcrição', 399.00, 'BRL', 'Canal', '{"stt":"whisper"}'::jsonb)
ON CONFLICT (sku) DO UPDATE
SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  price = EXCLUDED.price,
  currency = EXCLUDED.currency,
  category = EXCLUDED.category,
  metadata = EXCLUDED.metadata,
  updated_at = now();
