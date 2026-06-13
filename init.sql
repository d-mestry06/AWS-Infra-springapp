CREATE DATABASE IF NOT EXISTS taskmanager CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'taskmanager'@'%' IDENTIFIED BY 'taskmanager';

GRANT ALL PRIVILEGES ON taskmanager.* TO 'taskmanager'@'%';

FLUSH PRIVILEGES;