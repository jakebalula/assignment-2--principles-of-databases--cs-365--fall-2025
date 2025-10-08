USE passwords;

SET block_encryption_mode = 'aes-256-cbc';
SET @key_str = UNHEX(SHA2('secret password', 512));
SET @init_vector = RANDOM_BYTES(16);

-- 1. Create a new entry into the database, which already has your ten initial entries
INSERT INTO sites(site_name, url, user_id, comment, init_vector)
VALUES('MySQL', 'https://www.mysql.com', 1, 'MySQL account', @init_vector);

SET @new_site_id = LAST_INSERT_ID();

INSERT INTO credentials(user_id, site_id, email, username, encrypted_password)
SELECT 1, @new_site_id, 'mysqluser@example.com', 'jakeMysql',
       AES_ENCRYPT('MySQLpassword!', @key_str, s.init_vector)
FROM sites s where s.site_id = @new_site_id;

--Get the password associated with the URL of one of your ten entries
SELECT
  s.site_name, s.url, c.username,
  AES_DECRYPT(c.encrypted_password, @key_str, s.init_vector) AS decrypted_password
FROM credentials c
JOIN sites s ON c.site_id = s.site_id
WHERE s.url = 'https://mail.google.com';

-- Get all the password-related data, including the decrypted password, associated with URLs that have https in two of your ten entries.
SELECT
  s.site_name, s.url, c.email, c.username, c.created_at AS password_created_at,
  AES_DECRYPT(c.encrypted_password, @key_str, s.init_vector) AS decrypted_password
FROM credentials c
JOIN sites s ON c.site_id = s.site_id
WHERE s.url LIKE 'https://%';

--Change a URL associated with one of the passwords in your ten entries.
UPDATE sites
SET url = 'https://github.com/jakebalula'
WHERE site_name = 'GitHub' AND user_id = 1;

-- Change the password to any entry.
UPDATE credentials c
JOIN sites s ON c.site_id = s.site_id
SET c.encrypted_password = AES_ENCRYPT('MyNewGitHubPassword123', @key_str, s.init_vector),
    c.created_at = CURRENT_TIMESTAMP
WHERE s.site_name = 'GitHub' AND c.user_id = 1;

-- Remove a tuple based on a URL.
DELETE c
FROM credentials c
JOIN sites s ON c.site_id = s.site_id
WHERE s.url = 'https://www.reddit.com';

DELETE FROM sites WHERE url = 'https://www.reddit.com';

-- Remove a tuple based on a password.
DELETE c
FROM credentials c
JOIN sites s ON c.site_id = s.site_id
WHERE AES_DECRYPT(c.encrypted_password, @key_str, s.init_vector) = 'PasswordToPlaySomeGames';
