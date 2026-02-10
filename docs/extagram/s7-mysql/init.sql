-- Crear base de datos y usuario
CREATE DATABASE IF NOT EXISTS extagram_db;
CREATE USER IF NOT EXISTS 'extagram_admin'@'%' IDENTIFIED BY 'pass123';
GRANT ALL PRIVILEGES ON extagram_db.* TO 'extagram_admin'@'%';
FLUSH PRIVILEGES;

USE extagram_db;

-- Tabla posts
CREATE TABLE IF NOT EXISTS posts (
    post TEXT,
    photourl TEXT
);

-- Tabla users (para login)
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Crear usuario admin con contraseña 'password'
INSERT INTO users (username, password_hash) 
VALUES ('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi')
ON DUPLICATE KEY UPDATE username=username;
