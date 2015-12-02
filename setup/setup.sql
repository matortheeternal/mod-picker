/* NUMERIC TYPE REFERENCE
 * ------------------------------------------------------
 * TINYINT UNSIGNED MAX 	= 255
 * SMALLINT UNSIGNED MAX 	= 65,535
 * MEDIUMINT UNSIGNED MAX 	= 16,777,215
 * INT UNSIGNED MAX 		= 4,294,967,295
 * BIGINT UNSIGNED MAX 		= 18,446,744,073,709,551,615
 * ------------------------------------------------------
 */

/* ------------------------------------------------------ */
/* site mod info tables */ 
/* ------------------------------------------------------ */

CREATE TABLE nexus_infos
(
nm_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
uploaded_by VARCHAR(128),
authors VARCHAR(128),
date_released DATE,
date_updated DATE,
endorsements INT UNSIGNED,
total_downloads INT UNSIGNED,
unique_downloads INT UNSIGNED,
views BIGINT UNSIGNED, /* bigint because 4 billion views isn't impossible */
posts_count INT UNSIGNED,
videos_count SMALLINT UNSIGNED,
images_count SMALLINT UNSIGNED,
files_count SMALLINT UNSIGNED,
articles_count SMALLINT UNSIGNED,
nexus_category SMALLINT,
changelog VARCHAR(8192), /* pretty big, hopefully big enough */
PRIMARY KEY(nm_id)
);

CREATE TABLE workshop_infos
(
ws_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
PRIMARY KEY(ws_id)
);

CREATE TABLE lover_infos
(
ll_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
PRIMARY KEY(ll_id)
);

/* mods available on the site */
CREATE TABLE mods 
(
mod_id INT UNSIGNED NOT NULL AUTO_INCREMENT, /* max ~4 billion */
game VARCHAR(64),
name VARCHAR(128),
is_utility BOOLEAN,
category SMALLINT,
has_adult_content BOOLEAN,
nm_id INT UNSIGNED,
ws_id INT UNSIGNED,
ll_id INT UNSIGNED,
PRIMARY KEY(mod_id),
FOREIGN KEY(nm_id) REFERENCES nexus_infos(nm_id),
FOREIGN KEY(ws_id) REFERENCES workshop_infos(ws_id),
FOREIGN KEY(ll_id) REFERENCES lover_infos(ll_id)
);

/* user biographies - connections to other sites */
CREATE TABLE user_bios 
(
bio_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
nexus_username VARCHAR(32),
nexus_verified BOOLEAN,
lover_username VARCHAR(32),
lover_verified BOOLEAN,
steam_username VARCHAR(32),
steam_verified BOOLEAN,
PRIMARY KEY(bio_id)
);

/* the settings associated with a particular user */
CREATE TABLE user_settings
(
set_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
show_notifications BOOLEAN,
show_tooltips BOOLEAN,
email_notifications BOOLEAN,
email_public BOOLEAN,
allow_adult_content BOOLEAN,
allow_nexus_mods BOOLEAN,
allow_lovers_lab BOOLEAN,
allow_steam_workshop BOOLEAN,
PRIMARY KEY(set_id)
);

/* the reputation associated with a particular user */
CREATE TABLE user_reputations
(
rep_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
overall FLOAT,
offset FLOAT,
audiovisual_design FLOAT,
plugin_design FLOAT,
utilty_design FLOAT,
script_design FLOAT,
PRIMARY KEY(rep_id)
)

/* reputation that's been given  */
CREATE TABLE reputation_map
(
from_rep_id INT UNSIGNED,
to_rep_id INT UNSIGNED,
FOREIGN KEY(from_rep_id) REFERENCES user_reputations(from_rep_id),
FOREIGN KEY(to_rep_id) REFERENCES user_reputations(to_rep_id)
)

/* users registered on the site */
CREATE TABLE users
(
user_id INT UNSIGNED NOT NULL AUTO_INCREMENT, /* max ~4 billion */
username VARCHAR(32), /* too short? */
email VARCHAR(64), /* this should be long enough */
hash VARCHAR(53), /* bcrypt 22 character salt and 31 character hash */
user_level TINYINT,
title VARCHAR(32),
avatar VARCHAR(32),
joined DATE,
last_seen DATE,
bio_id INT UNSIGNED,
set_id INT UNSIGNED,
rep_id INT UNSIGNED,
active_ml_id INT UNSIGNED,
active_cl_id INT UNSIGNED,
FOREIGN KEY(bio_id) REFERENCES user_bios(bio_id),
FOREIGN KEY(set_id) REFERENCES user_settings(set_id),
FOREIGN KEY(rep_id) REFERENCES user_reputations(rep_id),
FOREIGN KEY(active_ml_id) REFERENCES mod_lists(active_ml_id),
FOREIGN KEY(active_cl_id) REFERENCES mod_collections(active_cl_id),
PRIMARY KEY(user_id)
);

/* ------------------------------------------------------ */
/* many to many mappings between users and mods */
/* ------------------------------------------------------ */

/* stars users have given to mods */ 
CREATE TABLE user_mod_star_map
(
mod_id INT UNSIGNED,
user_id INT UNSIGNED,
FOREIGN KEY(mod_id) REFERENCES mods(mod_id),
FOREIGN KEY(user_id) REFERENCES users(user_id),
);

/* mods that users have authored */
CREATE TABLE user_mod_author_map
(
mod_id INT UNSIGNED,
user_id INT UNSIGNED
FOREIGN KEY(mod_id) REFERENCES mods(mod_id),
FOREIGN KEY(user_id) REFERENCES users(user_id),
);

