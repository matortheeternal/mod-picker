/* These foreign key symbols may be different for you. Use 
   SHOW CREATE TABLE users; to verify these are the foreign key 
   symbols associated with the bio_id, rep_id, and set_id columns */
ALTER TABLE users DROP FOREIGN KEY users_ibfk_4;
ALTER TABLE users DROP FOREIGN KEY users_ibfk_5;
ALTER TABLE users DROP FOREIGN KEY users_ibfk_6;
ALTER TABLE users DROP COLUMN bio_id;
ALTER TABLE users DROP COLUMN rep_id;
ALTER TABLE users DROP COLUMN set_id;
ALTER TABLE user_bios ADD COLUMN user_id INT UNSIGNED;
ALTER TABLE user_reputations ADD COLUMN user_id INT UNSIGNED;
ALTER TABLE user_settings ADD COLUMN user_id INT UNSIGNED;
ALTER TABLE user_bios ADD FOREIGN KEY(user_id) REFERENCES users(user_id);
ALTER TABLE user_reputations ADD FOREIGN KEY(user_id) REFERENCES users(user_id);
ALTER TABLE user_settings ADD FOREIGN KEY(user_id) REFERENCES users(user_id);