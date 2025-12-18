-- Sample schema for testing automatic import

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Sample data
INSERT INTO users (username, email, password_hash) VALUES
    ('john_doe', 'john@example.com', 'hashed_password_1'),
    ('jane_smith', 'jane@example.com', 'hashed_password_2'),
    ('bob_wilson', 'bob@example.com', 'hashed_password_3'),
    ('alice_jones', 'alice@example.com', 'hashed_password_4'),
    ('charlie_brown', 'charlie@example.com', 'hashed_password_5');

INSERT INTO posts (user_id, title, content, published) VALUES
    (1, 'First Post', 'This is the content of the first post.', TRUE),
    (1, 'Draft Post', 'This is a draft.', FALSE),
    (1, 'Learning Docker', 'Docker makes development easier by containerizing applications.', TRUE),
    (2, 'Hello World', 'Jane says hello!', TRUE),
    (2, 'Web Development Tips', 'Always validate user input and use prepared statements.', TRUE),
    (3, 'My Journey', 'Started learning programming last month.', TRUE),
    (3, 'PHP Best Practices', 'Use PSR standards and follow SOLID principles.', FALSE),
    (4, 'Database Design', 'Normalization helps reduce data redundancy.', TRUE),
    (4, 'REST API Basics', 'Use proper HTTP methods: GET, POST, PUT, DELETE.', TRUE),
    (5, 'Code Review', 'Always review code before merging to main branch.', FALSE);
