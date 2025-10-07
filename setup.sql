DROP DATABASE IF EXISTS passwords;

CREATE DATABASE passwords DEFAULT CHARACTER SET utf8mb4;

USE passwords;

SET block_encryption_mode = 'aes-256-cbc';
SET @key_str = UNHEX(SHA2('secret password', 512));
SET @init_vector = RANDOM_BYTES(16);

CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  username VARCHAR(50) NOT NULL UNIQUE,
  email VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE sites (
  site_id INT AUTO_INCREMENT PRIMARY KEY,
  site_name VARCHAR(100) NOT NULL,
  url VARCHAR(255) NOT NULL,
  user_id INT NOT NULL,
  encrypted_password VARBINARY(512) NOT NULL,
  comment VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  init_vector VARBINARY(16) NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

INSERT INTO users(first_name, last_name, username, email) VALUES
('Jake', 'Balula', 'jakebalula', 'jakebalula@gmail.com');

INSERT INTO sites(site_name, url, user_id, encrypted_password, comment, init_vector)
VALUES
('Gmail', 'https://mail.google.com', 1,
 AES_ENCRYPT('password123', @key_str, @init_vector),
 'Personal email', @init_vector);






