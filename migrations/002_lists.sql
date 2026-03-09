CREATE TYPE list_type AS ENUM ('grocery', 'button'); -- as add lists update here

CREATE TABLE lists (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id    UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name        TEXT        NOT NULL,
    description TEXT,
    list_type   list_type   NOT NULL,
    is_public   BOOLEAN     NOT NULL DEFAULT false,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TRIGGER lists_updated_at
    BEFORE UPDATE ON lists
    FOR EACH ROW EXECUTE FUNCTION touch_updated_at();

CREATE INDEX idx_lists_owner_id ON lists(owner_id);

-- Who else can access a list beyond the owner
CREATE TYPE member_role AS ENUM ('viewer', 'editor');

CREATE TABLE list_members (
    list_id  UUID        NOT NULL REFERENCES lists(id) ON DELETE CASCADE,
    user_id  UUID        NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role     member_role NOT NULL DEFAULT 'viewer',
    added_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (list_id, user_id)
);

CREATE INDEX idx_list_members_user_id ON list_members(user_id);