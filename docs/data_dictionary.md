# Dicionário de Dados

## `contacts`
- `id` (uuid, PK)
- `external_id` (text) — identificador externo opcional.
- `phone` (text, único) — telefone principal (anonimizado após retenção).
- `name` (text) — nome informado pelo lead.
- `tags` (text[]) — marcas/segmentos associados ao contato.
- `timezone` (text) — fuso horário preferencial.
- `created_at` / `updated_at` (timestamptz)

## `chats`
- `id` (uuid, PK)
- `contact_id` (uuid, FK → `contacts`)
- `conversation_id` (text, único) — ID da Evolution API.
- `status` (text) — `open`, `closed`, etc.
- `last_message_at` (timestamptz)
- `metadata` (jsonb)
- `created_at` / `updated_at`

## `messages`
- `id` (uuid, PK)
- `chat_id` (uuid, FK → `chats`)
- `message_id` (text, único)
- `direction` (text) — `inbound`/`outbound`.
- `channel` (text) — padrão `whatsapp`.
- `sender` (jsonb) — dados do remetente.
- `content` (jsonb) — payload normalizado.
- `raw_payload` (jsonb) — mensagem bruta.
- `delivered_at` / `processed_at` (timestamptz)
- `created_at` / `updated_at`

## `chat_history`
- `id` (bigserial, PK)
- `chat_id` (uuid, FK → `chats`)
- `event_type` (text) — tipo de evento (handoff, nota).
- `payload` (jsonb)
- `actor` (text)
- `created_at`

## `fact_conversation`
- `id` (bigserial, PK)
- `chat_id` / `contact_id` (uuid)
- `conversation_id` (text, único)
- `first_message_at`, `first_response_at`, `closed_at` (timestamptz)
- `inbound_messages`, `outbound_messages` (integer)
- `ttfr_seconds` (integer)
- `status` (text)
- `created_at` / `updated_at`

## `fact_response`
- `id` (bigserial, PK)
- `message_id` (text)
- `chat_id` / `contact_id` (uuid)
- `responder_type` (text) — `bot` ou `human`.
- `response_time_ms` (integer)
- `created_at`

## `fact_lead`
- `id` (bigserial, PK)
- `chat_id` / `contact_id` (uuid)
- `quote_request_at` / `quote_sent_at` (timestamptz)
- `lead_value` (numeric)
- `currency` (char(3))
- `status` (text)
- `metadata` (jsonb)
- `created_at` / `updated_at`

## `event_log`
- `id` (bigserial, PK)
- `event_id` (text, único)
- `event_type` (text)
- `source` (text)
- `payload` (jsonb)
- `occurred_at` (timestamptz)
- `received_at` / `processed_at` (timestamptz)
- `status` (text) — `pending`, `processed`, etc.
- `error_message` (text)
- `created_at` / `updated_at`

## `bot_config`
- `id` (uuid, PK)
- `name` (text, único)
- `model` (text)
- `temperature` (numeric)
- `max_output_tokens` (integer)
- `debounce_seconds` (integer)
- `fallback_model` (text)
- `daily_budget_usd` (numeric)
- `metadata` (jsonb)
- `is_active` (boolean)
- `created_at` / `updated_at`

## `catalog_products`
- `id` (uuid, PK)
- `sku` (text, único)
- `name`, `description` (text)
- `price` (numeric)
- `currency` (char(3))
- `category` (text)
- `is_active` (boolean)
- `metadata` (jsonb)
- `created_at` / `updated_at`

## `audit_retention`
- `id` (uuid, PK)
- `scope` (text, único)
- `applies_to` (text)
- `scrub_after_days` (integer)
- `delete_after_months` (integer)
- `justification` (text)
- `is_active` (boolean)
- `created_at` / `updated_at`
