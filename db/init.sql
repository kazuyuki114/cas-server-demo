-- Create the users table
CREATE TABLE IF NOT EXISTS users (
                                     id SERIAL PRIMARY KEY,
                                     username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    enabled BOOLEAN DEFAULT TRUE,
    expired BOOLEAN DEFAULT FALSE,
    locked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
CREATE INDEX IF NOT EXISTS idx_users_enabled ON users(enabled);

-- Insert sample users with BCrypt encoded passwords
-- Password for 'admin' is 'admin123'
-- Password for 'testuser' is 'password123'
INSERT INTO users (username, password, email, enabled) VALUES
                                                           ('admin', '$2a$10$8K1p/a0dURXvmv5c1wAemu.MvZq8QMI8F5U4I8G5z7WQ.SmNy', 'admin@example.com', true),
                                                           ('testuser', '$2y$10$ohXwkzyCZ2U6B9/J7ZmU0egEm76tJnWKI3flHpYrY8J/h.W46DH2W', 'test@example.com', true),
                                                           ('john.doe', '$2a$10$GRLdNijSQMUvl/au9ofL.eDwmoohzzS7.rmNSJZ.0FxO/BTk76klW', 'john.doe@example.com', true)
    ON CONFLICT (username) DO NOTHING;

-- Create a table for user attributes (optional)
CREATE TABLE IF NOT EXISTS user_attributes (
                                               id SERIAL PRIMARY KEY,
                                               username VARCHAR(50) NOT NULL,
    attribute_name VARCHAR(100) NOT NULL,
    attribute_value TEXT,
    FOREIGN KEY (username) REFERENCES users(username) ON DELETE CASCADE
    );

-- Insert sample attributes
INSERT INTO user_attributes (username, attribute_name, attribute_value) VALUES
                                                                            ('admin', 'cn', 'Administrator'),
                                                                            ('admin', 'givenName', 'Admin'),
                                                                            ('admin', 'sn', 'User'),
                                                                            ('admin', 'mail', 'admin@example.com'),
                                                                            ('admin', 'department', 'IT'),
                                                                            ('testuser', 'cn', 'Test User'),
                                                                            ('testuser', 'givenName', 'Test'),
                                                                            ('testuser', 'sn', 'User'),
                                                                            ('testuser', 'mail', 'test@example.com'),
                                                                            ('testuser', 'department', 'Development'),
                                                                            ('john.doe', 'cn', 'John Doe'),
                                                                            ('john.doe', 'givenName', 'John'),
                                                                            ('john.doe', 'sn', 'Doe'),
                                                                            ('john.doe', 'mail', 'john.doe@example.com'),
                                                                            ('john.doe', 'department', 'Sales')
    ON CONFLICT DO NOTHING;