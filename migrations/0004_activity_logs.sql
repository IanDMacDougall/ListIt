-- Migration 006: Admin Activity Logs
CREATE TYPE log_level AS ENUM ('info', 'warn', 'error');

CREATE TYPE log_category AS ENUM (
    'auth',
    'user_management', 
    'list',
    'system'
);

CREATE TABLE activity_logs (
    id          UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    level       log_level    NOT NULL DEFAULT 'info',
    category    log_category NOT NULL,
    message     TEXT         NOT NULL,
    -- Who did the action (NULL = system/unauthenticated)
    actor_id    UUID         REFERENCES users(id) ON DELETE SET NULL,
    actor_name  TEXT,        -- snapshot of username at time of event
                             -- kept even if user is later deleted
    -- Extra structured data (IP address, affected resource, etc.)
    metadata    JSONB,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- Logs are append-only — no updated_at needed
CREATE INDEX idx_logs_created_at  ON activity_logs(created_at DESC);
CREATE INDEX idx_logs_category    ON activity_logs(category);
CREATE INDEX idx_logs_level       ON activity_logs(level);
CREATE INDEX idx_logs_actor_id    ON activity_logs(actor_id);
CREATE INDEX idx_logs_metadata    ON activity_logs USING GIN(metadata);