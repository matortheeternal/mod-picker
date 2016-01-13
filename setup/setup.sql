/* TEXT TYPE REFERENCE (max length)
 * ------------------------------------------------------
 * TINYTEXT     = 2^8 bytes     = 255 char (ascii)
 * TEXT         = 2^16 bytes    = 65,535 char (ascii)
 * MEDIUMTEXT   = 2^24 bytes    = 16,777,215 char (ascii)
 * LONGTEXT     = 2^32 bytes    = 4 gigabytes (wtf)
 *
 * NUMERIC TYPE REFERENCE
 * ------------------------------------------------------
 * TINYINT UNSIGNED MAX     = 255
 * SMALLINT UNSIGNED MAX    = 65,535
 * MEDIUMINT UNSIGNED MAX   = 16,777,215
 * INT UNSIGNED MAX         = 4,294,967,295
 * BIGINT UNSIGNED MAX      = 18,446,744,073,709,551,615
 * ------------------------------------------------------
 */

/* ------------------------------------------------------ */
/* site mod info tables */ 
/* ------------------------------------------------------ */

CREATE TABLE nexus_infos
(
nm_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
uploaded_by TINYTEXT,
authors TINYTEXT,
date_released DATE,
date_updated DATE,
endorsements INT UNSIGNED,
total_downloads INT UNSIGNED,
unique_downloads INT UNSIGNED,
views BIGINT UNSIGNED, /* bigint because 4 billion views isn't entirely implausible */
posts_count INT UNSIGNED,
videos_count SMALLINT UNSIGNED,
images_count SMALLINT UNSIGNED,
files_count SMALLINT UNSIGNED,
articles_count SMALLINT UNSIGNED,
nexus_category SMALLINT,
changelog TEXT,
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


/* ------------------------------------------------------ */
/* mod tables */
/* ------------------------------------------------------ */

/* mods available on the site */
CREATE TABLE mods 
(
mod_id INT UNSIGNED NOT NULL AUTO_INCREMENT, /* max ~4 billion */
game TINYTEXT,
name TINYTEXT,
aliases TINYTEXT,
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

/* versions of mods available on the site */
CREATE TABLE mod_versions
(
mv_id INT UNSIGNED NOT NULL AUTO_INCREMENT, /* max ~4 billion */
mod_id INT UNSIGNED,
nxm_file_id INT UNSIGNED, /* max ~4 billion, should be big enough */
released DATE, /* override date from site infos, may be unused */
obsolete BOOLEAN,
dangerous BOOLEAN,
PRIMARY KEY(mv_id),
FOREIGN KEY(mod_id) REFERENCES mods(mod_id)
);

/* all mod asset files we ever encounter, no duplicate file paths */
CREATE TABLE mod_asset_files
(
maf_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
filepath VARCHAR(128) NOT NULL UNIQUE,
PRIMARY KEY(maf_id)
);

/* maps asset files to mod versions */
CREATE TABLE mod_version_file_map
(
mv_id INT UNSIGNED,
maf_id INT UNSIGNED,
FOREIGN KEY(mv_id) REFERENCES mod_versions(mv_id),
FOREIGN KEY(maf_id) REFERENCES mod_asset_files(maf_id)
);

/* plugins that we have informaton on */
CREATE TABLE plugins
(
pl_id INT UNSIGNED NOT NULL AUTO_INCREMENT, /* max ~4 billion */
mv_id INT UNSIGNED,
filename TINYTEXT,
author TINYTEXT,
description TEXT,
hash VARCHAR(8), /* crc32 hash */
PRIMARY KEY(pl_id),
FOREIGN KEY(mv_id) REFERENCES mod_versions(mv_id)
);

CREATE TABLE masters
(
mst_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
pl_id INT UNSIGNED, /* 4 bytes */
PRIMARY KEY(mst_id),
FOREIGN KEY(pl_id) REFERENCES plugins(pl_id)
);

/* override records associated with a plugin */
/* By my estimation, there will be >100,000 override records total 
   for all skyrim plugins.  */
/* Depending on the average name length, the size of a record in this 
   table could be between 35 bytes (16 character name), and 83 bytes 
   (64 character name).  I think the average name length will be around
   30 characters, making the average record size 49 bytes.*/
/* == SCALING NOTES ==
   Table of 100,000 records     = 4.67 MB 
   Table of 1,000,000 records   = 46.73 MB
   Table of 10,000,000 records  = 467.3 MB */
CREATE TABLE plugin_override_map
(
pl_id INT UNSIGNED, /* 4 bytes */
mst_id INT UNSIGNED, /* 4 bytes */
form_id INT UNSIGNED, /* 4 bytes -- FormID max is 2^(32) = $FFFFFFFF */
sig VARCHAR(4), /* 4 bytes */
name TINYTEXT, /* UP TO 255 CHARACTERS */
is_itm BOOLEAN, /* 1 bit */
is_itpo BOOLEAN, /* 1 bit */
is_udr BOOLEAN, /* 1 bit */
FOREIGN KEY(pl_id) REFERENCES plugins(pl_id), 
FOREIGN KEY(mst_id) REFERENCES masters(mst_id)
);

/* record groups associated with a plugin */
CREATE TABLE plugin_record_groups
(
pl_id INT UNSIGNED, /* 4 bytes */
sig VARCHAR(4),
name TINYTEXT,
new_records INT UNSIGNED,
override_records INT UNSIGNED,
FOREIGN KEY(pl_id) REFERENCES plugins(pl_id)
);

/* mod lists created by users */
CREATE TABLE mod_lists
(
ml_id INT UNSIGNED NOT NULL AUTO_INCREMENT, /* max ~4 billion */
game TINYTEXT,
created_by INT UNSIGNED,
is_collection BOOLEAN,
is_public BOOLEAN,
has_adult_content BOOLEAN,
status ENUM('Planned', 'Under Construction', 'Testing', 'Complete'),
created DATE,
completed DATE,
description TEXT, /* bbcode description */ /* frontend restriction: 0 <= length <= 20,000 */
PRIMARY KEY(ml_id)
);

/* plugins in mod lists */
CREATE TABLE mod_list_plugins
(
ml_id INT UNSIGNED,
pl_id INT UNSIGNED,
active BOOLEAN,
load_order SMALLINT UNSIGNED, /* max ~65,535 */
FOREIGN KEY(ml_id) REFERENCES mod_lists(ml_id),
FOREIGN KEY(pl_id) REFERENCES plugins(pl_id)
);

/* custom plugins in mod lists */
CREATE TABLE mod_list_custom_plugins
(
ml_id INT UNSIGNED,
active BOOLEAN,
load_order SMALLINT UNSIGNED, /* max ~65,535 */
title VARCHAR(64),
description TEXT, /* restrict user from entering more than 1,024 characters here */
FOREIGN KEY(ml_id) REFERENCES mod_lists(ml_id)
);

/* mods in mod lists */
CREATE TABLE mod_list_mods
(
ml_id INT UNSIGNED,
mod_id INT UNSIGNED,
active BOOLEAN,
install_order SMALLINT UNSIGNED, /* max ~65,535 */
FOREIGN KEY(ml_id) REFERENCES mod_lists(ml_id),
FOREIGN KEY(mod_id) REFERENCES mods(mod_id)
);


/* ------------------------------------------------------ */
/* user tables */
/* ------------------------------------------------------ */

/* users registered on the site */
CREATE TABLE users
(
user_id INT UNSIGNED NOT NULL AUTO_INCREMENT, /* max ~4 billion */
username VARCHAR(32),
user_level ENUM('guest', 'banned', 'user', 'author', 'vip', 'moderator', 'admin'),
title VARCHAR(32),
avatar TINYTEXT, /* max 255 ascii characters */
joined DATE,
active_ml_id INT UNSIGNED,
active_mc_id INT UNSIGNED,
PRIMARY KEY(user_id),
FOREIGN KEY(active_ml_id) REFERENCES mod_lists(ml_id),
FOREIGN KEY(active_mc_id) REFERENCES mod_lists(ml_id)
);

/* user biographies - connections to other sites */
CREATE TABLE user_bios 
(
bio_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
user_id INT UNSIGNED,
nexus_username VARCHAR(32),
nexus_verified BOOLEAN,
lover_username VARCHAR(32),
lover_verified BOOLEAN,
steam_username VARCHAR(32),
steam_verified BOOLEAN,
PRIMARY KEY(bio_id),
FOREIGN KEY(user_id) REFERENCES users(user_id)
);

/* the settings associated with a particular user */
CREATE TABLE user_settings
(
set_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
user_id INT UNSIGNED,
show_notifications BOOLEAN,
show_tooltips BOOLEAN,
email_notifications BOOLEAN,
email_public BOOLEAN,
allow_adult_content BOOLEAN,
allow_nexus_mods BOOLEAN,
allow_lovers_lab BOOLEAN,
allow_steam_workshop BOOLEAN,
PRIMARY KEY(set_id),
FOREIGN KEY(user_id) REFERENCES users(user_id)
);

/* the reputation associated with a particular user */
CREATE TABLE user_reputations
(
rep_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
user_id INT UNSIGNED,
overall FLOAT,
offset FLOAT,
audiovisual_design FLOAT,
plugin_design FLOAT,
utility_design FLOAT,
script_design FLOAT,
PRIMARY KEY(rep_id),
FOREIGN KEY(user_id) REFERENCES users(user_id)
);

/* reputation that's been given  */
CREATE TABLE reputation_map
(
from_rep_id INT UNSIGNED,
to_rep_id INT UNSIGNED,
FOREIGN KEY(from_rep_id) REFERENCES user_reputations(rep_id),
FOREIGN KEY(to_rep_id) REFERENCES user_reputations(rep_id)
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
FOREIGN KEY(user_id) REFERENCES users(user_id)
);

/* stars users have given to mod lists */ 
CREATE TABLE user_mod_list_star_map
(
ml_id INT UNSIGNED,
user_id INT UNSIGNED,
FOREIGN KEY(ml_id) REFERENCES mod_lists(ml_id),
FOREIGN KEY(user_id) REFERENCES users(user_id)
);

/* users that have authored mods */
CREATE TABLE user_mod_author_map
(
mod_id INT UNSIGNED,
user_id INT UNSIGNED,
FOREIGN KEY(mod_id) REFERENCES mods(mod_id),
FOREIGN KEY(user_id) REFERENCES users(user_id)
);

/* need to update mod_lists to reference users as a foreign
   key for the created_by column */
ALTER TABLE mod_lists 
ADD FOREIGN KEY(created_by) REFERENCES users(user_id);


/* ------------------------------------------------------ */
/* user submission tables */
/* ------------------------------------------------------ */

/* comments submitted by users */
CREATE TABLE comments
(
c_id INT UNSIGNED NOT NULL AUTO_INCREMENT, /* max ~4 billion */
parent_comment INT UNSIGNED,
submitted_by INT UNSIGNED,
hidden BOOLEAN,
submitted DATE,
edited DATE,
text_body TEXT, /* restriction 2 <= length <= 5,000 */
PRIMARY KEY(c_id),
FOREIGN KEY(parent_comment) REFERENCES comments(c_id),
FOREIGN KEY(submitted_by) REFERENCES users(user_id)
);

/* mod reviews submitted by users */
CREATE TABLE reviews
(
r_id INT UNSIGNED NOT NULL AUTO_INCREMENT, /* max ~4 billion */
submitted_by INT UNSIGNED,
mod_id INT UNSIGNED,
hidden BOOLEAN,
rating1 TINYINT,
rating2 TINYINT,
rating3 TINYINT,
rating4 TINYINT,
rating5 TINYINT,
submitted DATE,
edited DATE,
text_body TEXT, /* frontend restriction: 150 <= length <= 10,000 */
PRIMARY KEY(r_id),
FOREIGN KEY(submitted_by) REFERENCES users(user_id),
FOREIGN KEY(mod_id) REFERENCES mods(mod_id)
);

/* installation notes submitted by users */
CREATE TABLE installation_notes
(
in_id INT UNSIGNED NOT NULL AUTO_INCREMENT, /* max ~4 billion */
submitted_by INT UNSIGNED,
mv_id INT UNSIGNED,
always BOOLEAN, /* if true, this installation note will always be shown */
note_type ENUM('Download Option', 'FOMOD Option'),
submitted DATE,
edited DATE,
text_body TEXT, /* frontend restriction: 50 <= length <= 1,000 */
PRIMARY KEY(in_id),
FOREIGN KEY(submitted_by) REFERENCES users(user_id),
FOREIGN KEY(mv_id) REFERENCES mod_versions(mv_id)
);

/* compatibility notes submitted by users */
CREATE TABLE compatibility_notes
(
cn_id INT UNSIGNED NOT NULL AUTO_INCREMENT, /* max ~4 billion */
submitted_by INT UNSIGNED,
mod_mode ENUM('Any', 'All'),
compatibility_patch INT UNSIGNED,
compatibility_status ENUM('Incompatible', 'Partially Compatible', 
	'Patch Available', 'Make Custom Patch', 
	'Soft Incompatibility', 'Installation Note'),
in_id INT UNSIGNED,
submitted DATE,
edited DATE,
text_body TEXT, /* frontend restriction: 50 <= length <= 1,000 */
PRIMARY KEY(cn_id),
FOREIGN KEY(submitted_by) REFERENCES users(user_id),
FOREIGN KEY(compatibility_patch) REFERENCES plugins(pl_id),
FOREIGN KEY(in_id) REFERENCES installation_notes(in_id)
);

/* comments on mods */
CREATE TABLE mod_comments
(
mod_id INT UNSIGNED,
c_id INT UNSIGNED,
FOREIGN KEY(mod_id) REFERENCES mods(mod_id),
FOREIGN KEY(c_id) REFERENCES comments(c_id)
);

/* comments on mod_lists */
CREATE TABLE mod_list_comments
(
ml_id INT UNSIGNED,
c_id INT UNSIGNED,
FOREIGN KEY(ml_id) REFERENCES mod_lists(ml_id),
FOREIGN KEY(c_id) REFERENCES comments(c_id)
);

/* comments on user profiles */
CREATE TABLE user_comments
(
user_id INT UNSIGNED,
c_id INT UNSIGNED,
FOREIGN KEY(user_id) REFERENCES users(user_id),
FOREIGN KEY(c_id) REFERENCES comments(c_id)
);

/* review, compatibility note, and installation note 
   helpful/unhelpful marks */
/* see stackoverflow on polymorphic associations
   http://stackoverflow.com/questions/441001/ */
CREATE TABLE helpful_marks
(
r_id INT UNSIGNED,
cn_id INT UNSIGNED,
in_id INT UNSIGNED,
submitted_by INT UNSIGNED,
helpful BOOLEAN,
FOREIGN KEY(r_id) REFERENCES reviews(r_id),
FOREIGN KEY(cn_id) REFERENCES compatibility_notes(cn_id),
FOREIGN KEY(in_id) REFERENCES installation_notes(in_id),
FOREIGN KEY(submitted_by) REFERENCES users(user_id)
);

/* incorrect notes for reviews, compatibility notes,
   and installation notes */
/* see stackoverflow on polymorphic associations
   http://stackoverflow.com/questions/441001/ */
CREATE TABLE incorrect_notes
(
inc_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
r_id INT UNSIGNED,
cn_id INT UNSIGNED,
in_id INT UNSIGNED,
submitted_by INT UNSIGNED,
reason TEXT, /* frontend restriction: 50 <= length <= 1,000 */
PRIMARY KEY(inc_id),
FOREIGN KEY(r_id) REFERENCES reviews(r_id),
FOREIGN KEY(cn_id) REFERENCES compatibility_notes(cn_id),
FOREIGN KEY(in_id) REFERENCES installation_notes(in_id),
FOREIGN KEY(submitted_by) REFERENCES users(user_id)
);

/* agreement marks for incorrect notes */
CREATE TABLE agreement_marks
(
inc_id INT UNSIGNED,
submitted_by INT UNSIGNED,
agree BOOLEAN,
FOREIGN KEY(inc_id) REFERENCES incorrect_notes(inc_id),
FOREIGN KEY(submitted_by) REFERENCES users(user_id)
);

/* installation notes that have been resolved or
   ignored by the user for a particular mod list */
/* Total record size: 9 bytes. */
/* == SCALING NOTES ==
   With 200,000 mod lists, an average of 255 mods per
   modlist, and an average of 1 installation note per 
   mod, all of which are resolved or ignored:
      Number of records = 51 million
      Table size = 437.74 MB
 */
CREATE TABLE mod_list_installation_notes
(
ml_id INT UNSIGNED, /* 4 bytes */
in_id INT UNSIGNED, /* 4 bytes */
status ENUM('Resolved', 'Ignored'), /* 1 byte */
FOREIGN KEY(ml_id) REFERENCES mod_lists(ml_id),
FOREIGN KEY(in_id) REFERENCES installation_notes(in_id)
);

/* compatibility notes that have been resolved or
   ignored by the user for a particular mod list */
/* Total record size: 9 bytes. */
/* == SCALING NOTES ==
   With 200,000 mod lists, an average of 255 mods per
   modlist, and an average of 1 compatibility note per 
   mod, all of which are resolved or ignored:
      Number of records = 51 million
      Table size = 437.74 MB
 */
CREATE TABLE mod_list_compatibility_notes
(
ml_id INT UNSIGNED, /* 4 bytes */
cn_id INT UNSIGNED, /* 4 bytes */
status ENUM('Resolved', 'Ignored'), /* 1 byte */
FOREIGN KEY(ml_id) REFERENCES mod_lists(ml_id),
FOREIGN KEY(cn_id) REFERENCES compatibility_notes(cn_id)
);