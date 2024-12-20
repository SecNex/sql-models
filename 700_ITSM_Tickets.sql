-- CONTACTS
CREATE TABLE contacts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    phone VARCHAR(20),
    mobile VARCHAR(20),
    company VARCHAR(100),
    title VARCHAR(100),
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    zip VARCHAR(20),
    country VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- QUEUES
CREATE TABLE queues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    prefix VARCHAR(10) NOT NULL UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ENUM for ticket status
CREATE TYPE ticket_status AS ENUM ('Open', 'Doing', 'Waiting', 'Closed');

-- STATUS DEFINITIONS
CREATE TABLE status_definitions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    base_status ticket_status NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- DEFAULT STATUS DEFINITIONS
INSERT INTO status_definitions (name, base_status, description) VALUES
    ('New', 'Open', 'New ticket'),
    ('Doing', 'Doing', 'Ticket is being worked on'),
    ('Waiting for customer', 'Waiting', 'Waiting for Customer'),
    ('Waiting for external', 'Waiting', 'Waiting for external'),
    ('Waiting for internal', 'Waiting', 'Waiting for internal'),
    ('Waiting for response', 'Waiting', 'Waiting for response'),
    ('Waiting for information', 'Waiting', 'Waiting for information'),
    ('Closed', 'Closed', 'Ticket is closed');

-- TICKETS
CREATE TABLE tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_number VARCHAR(20) NOT NULL UNIQUE,
    queue_id UUID REFERENCES queues(id),
    subject VARCHAR(255) NOT NULL,
    status_name VARCHAR(100) REFERENCES status_definitions(name),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- EMAILS
CREATE TABLE emails (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_id UUID REFERENCES tickets(id),
    message_id VARCHAR(255) NOT NULL UNIQUE,
    from_address VARCHAR(255) NOT NULL,
    to_address VARCHAR(255) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    body TEXT,
    received_at TIMESTAMP WITH TIME ZONE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    in_reply_to VARCHAR(255),
    references_list TEXT[]
);

-- SUPPORTERS
CREATE TABLE supporters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- TICKET ASSIGNMENTS
CREATE TABLE ticket_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_id UUID REFERENCES tickets(id),
    supporter_id UUID REFERENCES supporters(id),
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(ticket_id, supporter_id)
);

-- TICKET REQUESTOR ASSIGNMENT
CREATE TABLE ticket_requestor_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_id UUID REFERENCES tickets(id),
    contact_id UUID REFERENCES contacts(id),
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(ticket_id, contact_id)
);

-- ASSIGNED SUPPORTER in TICKETS
ALTER TABLE tickets 
ADD COLUMN assigned_supporter_id UUID REFERENCES supporters(id); 

-- ASSIGNED REQUESTOR in TICKETS
ALTER TABLE tickets 
ADD COLUMN assigned_requestor_id UUID REFERENCES contacts(id); 

-- DEFAULT QUEUE
INSERT INTO queues (id, name, prefix) VALUES
    (gen_random_uuid(), 'Default Queue', 'DEF');

-- E-MAIL THREADS
CREATE TABLE email_threads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_email_id UUID REFERENCES emails(id),
    child_email_id UUID REFERENCES emails(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(parent_email_id, child_email_id)
);