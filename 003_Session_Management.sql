-- SESSION mit erweiterten Attributen
CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    client_id UUID NOT NULL,  -- Referenz zum Client/Device
    ip_address VARCHAR(255) NOT NULL,
    user_agent TEXT,          -- Browser/App-Information
    session_type VARCHAR(50) NOT NULL DEFAULT 'WEB', -- WEB, MOBILE, API
    is_active BOOLEAN DEFAULT true,
    last_activity_at TIMESTAMP WITH TIME ZONE,
    expires_in INT NOT NULL DEFAULT 3600,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (client_id) REFERENCES clients(id)
);

-- CLIENT/DEVICE Informationen
CREATE TABLE clients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id VARCHAR(255) NOT NULL UNIQUE,
    client_secret VARCHAR(255),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    client_type VARCHAR(50) NOT NULL, -- CONFIDENTIAL, PUBLIC
    allowed_grant_types TEXT[], -- array of allowed grant types
    redirect_uris TEXT[],
    allowed_scopes TEXT[],
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL
);

-- Erweiterte Token-Tabelle
CREATE TYPE session_token_type AS ENUM (
    'AUTHORIZATION_CODE',
    'ACCESS_TOKEN',
    'REFRESH_TOKEN',
    'ID_TOKEN'
);

CREATE TABLE tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id UUID NOT NULL,
    client_id UUID NOT NULL,
    token VARCHAR(255) NOT NULL,
    token_type session_token_type NOT NULL,
    reference_id UUID,        -- Referenz zu anderen Tokens
    scope TEXT[],            -- Array von Berechtigungen
    audience TEXT[],         -- Zielgruppe des Tokens
    expires_in INT NOT NULL DEFAULT 3600,
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    is_revoked BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    FOREIGN KEY (session_id) REFERENCES sessions(id),
    FOREIGN KEY (client_id) REFERENCES clients(id),
    FOREIGN KEY (reference_id) REFERENCES tokens(id)
);

-- Indizes für bessere Performance
CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_sessions_client_id ON sessions(client_id);
CREATE INDEX idx_tokens_session_id ON tokens(session_id);
CREATE INDEX idx_tokens_token ON tokens(token);
CREATE INDEX idx_tokens_reference_id ON tokens(reference_id);