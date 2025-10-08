USE passwords;

SET block_encryption_mode = 'aes-256-cbc';
SET @key_str = UNHEX(SHA2('secret password', 512));
SET @init_vector = RANDOM_BYTES(16);


INSERT INTO sites(site_name, url, user_id, comment, init_vector)
VALUES('MySQL', 'https://www.mysql.com', 1, 'MySQL account', @init_vector);

SET @new_site_id = LAST_INSERT_ID();

INSERT INTO credentials(user_id, site_id, email, username, encrypted_password)
SELECT 1, @new_site_id, 'mysqluser@example.com', 'jakeMysql',
       AES_ENCRYPT('MySQLpassword!', @key_str, s.@init_vector)
FROM sites s where s.site_id = new_site_id;


SELECT
  s.site_name,
  s.url,
  c.username,
  AES_DECRYPT(c.encrypted_password, @key_str, s.init_vector) AS decrypted_password
FROM credenitals c
JOIN sites s ON c.site_id = s.site_id
WHERE s.url = 'https://mail.google.com';


SELECT
  s.site_name, s.url, c.email, c.username, c.created_as AS password_created_at,
  AES_DECRYPT(c.encrypted_password, @key_str, s.init_vector) AS decrypted_password
FROM credentials c
JOIN sites s ON c.site_id = s.site_id
WHERE s.url LIKE 'https://%';



