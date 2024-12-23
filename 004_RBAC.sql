-- RBAC Schema für bessere Organisation
CREATE SCHEMA rbac;

-- RBAC ROLES (Hauptrollen)
CREATE TABLE rbac.roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_system_role BOOLEAN DEFAULT FALSE,
    organization_id UUID,
    created_by UUID NOT NULL,
    updated_by UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    FOREIGN KEY (organization_id) REFERENCES organizations(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (updated_by) REFERENCES users(id)
);

-- RBAC PERMISSIONS (Berechtigungen)
CREATE TABLE rbac.permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    resource_type VARCHAR(50) NOT NULL, -- z.B. 'TICKET', 'POST', 'USER'
    action VARCHAR(50) NOT NULL, -- z.B. 'CREATE', 'READ', 'UPDATE', 'DELETE'
    conditions JSONB, -- Zusätzliche Bedingungen für die Berechtigung
    created_by UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- RBAC ROLE_PERMISSIONS (Verknüpfung)
CREATE TABLE rbac.role_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_id UUID NOT NULL,
    permission_id UUID NOT NULL,
    created_by UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (role_id) REFERENCES rbac.roles(id),
    FOREIGN KEY (permission_id) REFERENCES rbac.permissions(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    UNIQUE(role_id, permission_id)
);

-- RBAC USER_ROLES (Zuordnung von Rollen zu Benutzern)
CREATE TABLE rbac.user_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    role_id UUID NOT NULL,
    organization_id UUID,
    group_id UUID,
    granted_by UUID NOT NULL,
    valid_from TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    valid_until TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (role_id) REFERENCES rbac.roles(id),
    FOREIGN KEY (organization_id) REFERENCES organizations(id),
    FOREIGN KEY (group_id) REFERENCES groups(id),
    FOREIGN KEY (granted_by) REFERENCES users(id),
    UNIQUE(user_id, role_id, organization_id, group_id)
);

-- RBAC GROUP_ROLES (Zuordnung von Rollen zu Gruppen)
CREATE TABLE rbac.group_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL,
    role_id UUID NOT NULL,
    granted_by UUID NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (group_id) REFERENCES groups(id),
    FOREIGN KEY (role_id) REFERENCES rbac.roles(id),
    FOREIGN KEY (granted_by) REFERENCES users(id),
    UNIQUE(group_id, role_id)
);

-- Indizes für bessere Performance
CREATE INDEX idx_user_roles_user_id ON rbac.user_roles(user_id);
CREATE INDEX idx_user_roles_role_id ON rbac.user_roles(role_id);
CREATE INDEX idx_group_roles_group_id ON rbac.group_roles(group_id);
CREATE INDEX idx_role_permissions_role_id ON rbac.role_permissions(role_id);
CREATE INDEX idx_permissions_resource_action ON rbac.permissions(resource_type, action);

-- Standard-System-Rollen
INSERT INTO rbac.roles (name, description, is_system_role, created_by, updated_by)
VALUES 
    ('SUPER_ADMIN', 'Vollständige Systemadministration', TRUE, (SELECT id FROM users LIMIT 1), (SELECT id FROM users LIMIT 1)),
    ('ORG_ADMIN', 'Organisationsadministrator', TRUE, (SELECT id FROM users LIMIT 1), (SELECT id FROM users LIMIT 1)),
    ('GROUP_ADMIN', 'Gruppenadministrator', TRUE, (SELECT id FROM users LIMIT 1), (SELECT id FROM users LIMIT 1)),
    ('USER', 'Standardbenutzer', TRUE, (SELECT id FROM users LIMIT 1), (SELECT id FROM users LIMIT 1));
