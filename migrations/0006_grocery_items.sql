CREATE TABLE grocery_items (
    id         UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    list_id    UUID         NOT NULL REFERENCES lists(id) ON DELETE CASCADE,
    name       TEXT         NOT NULL,
    quantity   NUMERIC(10,2) NOT NULL DEFAULT 1,
    unit       TEXT,
    image_url  TEXT,
    price      NUMERIC(10,2),
    is_checked BOOLEAN      NOT NULL DEFAULT false,
    position   INTEGER      NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ  NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE TRIGGER grocery_items_updated_at
    BEFORE UPDATE ON grocery_items
    FOR EACH ROW EXECUTE FUNCTION touch_updated_at();

CREATE INDEX idx_grocery_items_list_id ON grocery_items(list_id);
CREATE INDEX idx_grocery_items_position ON grocery_items(list_id, position);