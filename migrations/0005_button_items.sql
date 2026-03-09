CREATE TABLE button_items (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    list_id     UUID        NOT NULL REFERENCES lists(id) ON DELETE CASCADE,
    name        TEXT        NOT NULL,
    description TEXT,
    link_url    TEXT,
    image_url   TEXT,
    position    INTEGER     NOT NULL DEFAULT 0,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER button_items_updated_at
    BEFORE UPDATE ON button_items
    FOR EACH ROW EXECUTE FUNCTION touch_updated_at();

CREATE INDEX idx_button_items_list_id ON button_items(list_id);
CREATE INDEX idx_button_items_position ON button_items(list_id, position);