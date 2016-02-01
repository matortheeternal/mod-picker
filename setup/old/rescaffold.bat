:: ------------------------------------------------------
:: static data tables
:: ------------------------------------------------------

call rails g scaffold categories id:integer parent_id:integer name:text description:text --force --skip-migration

call rails g scaffold category_priorities dominant_id:integer recessive_id:integer --force --skip-migration

call rails g scaffold games id:integer short_name:text long_name:text abbr_name:text exe_name:text steam_app_ids:text --force --skip-migration

:: ------------------------------------------------------
:: site mod info tables
:: ------------------------------------------------------

call rails g scaffold nexus_infos id:integer mod_id:integer uploaded_by:text authors:text:datetime_released:datetime:datetime_updated:datetime endorsements:integer total_downloads:integer unique_downloads:integer views:integer posts_count:integer videos_count:integer images_count:integer files_count:integer articles_count:integer nexus_category:integer changelog:text --force --skip-migration

call rails g scaffold workshop_infos id:integer mod_id:integer --force --skip-migration

call rails g scaffold lover_infos id:integer mod_id:integer --force --skip-migration


:: ------------------------------------------------------
:: mod tables
:: ------------------------------------------------------

:: mods available on the site
call rails g scaffold mods id:integer game_id:integer name:text aliases:text is_utility:boolean has_adult_content:boolean primary_category_id:integer secondary_category_id:integer --force --skip-migration

:: versions of mods available on the site
call rails g scaffold mod_versions id:integer mod_id:integer nxm_file_id:integer released:datetime obsolete:boolean dangerous:boolean --force --skip-migration

:: all mod asset files we ever encounter, no duplicate file paths
call rails g scaffold mod_asset_files id:integer filepath:string --force --skip-migration

:: maps asset files to mod versions
call rails g scaffold mod_version_files mod_version_id:integer mod_asset_file_id:integer --force --skip-migration

:: plugins that we have informaton on
call rails g scaffold plugins id:integer mod_version_id:integer filename:text author:text description:text hash:string --force --skip-migration

:: plugins that serve as masters for other plugins
call rails g scaffold masters id:integer plugin_id:integer --force --skip-migration

:: override records associated with a plugin
call rails g scaffold override_records plugin_id:integer master_id:integer form_id:integer --force --skip-migration

:: record groups associated with a plugin
call rails g scaffold plugin_record_groups plugin_id:integer sig:string name:text new_records:integer override_records:integer --force --skip-migration

:: mod lists created by users
call rails g scaffold mod_lists id:integer game:text created_by:integer is_collection:boolean is_public:boolean has_adult_content:boolean status:integer created:datetime completed:datetime description:text --force --skip-migration

:: plugins in mod lists
call rails g scaffold mod_list_plugins mod_list_id:integer plugin_id:integer active:boolean load_order:integer --force --skip-migration

:: custom plugins in mod lists
call rails g scaffold mod_list_custom_plugins mod_list_id:integer active:boolean load_order:integer title:string description:text --force --skip-migration

:: mods in mod lists
call rails g scaffold mod_list_mods mod_list_id:integer mod_id:integer active:boolean install_order:integer --force --skip-migration


:: ------------------------------------------------------
:: user tables
:: ------------------------------------------------------

:: users registered on the site
call rails g scaffold users id:integer username:string email:string user_level:integer title:string avatar:text joined:datetime active_ml_id:integer active_mc_id:integer  --force --skip-migration

:: user biographies - connections to other sites
call rails g scaffold user_bios id:integer user_id:integer nexus_username:string nexus_verified:boolean lover_username:string lover_verified:boolean steam_username:string steam_verified:boolean  --force --skip-migration

:: the settings associated with a particular user
call rails g scaffold user_settings id:integer user_id:integer show_notifications:boolean show_tooltips:boolean email_notifications:boolean email_public:boolean allow_adult_content:boolean allow_nexus_mods:boolean allow_lovers_lab:boolean allow_steam_workshop:boolean timezone:text udate_format:text utime_format:text  --force --skip-migration

:: the reputation associated with a particular user
call rails g scaffold user_reputations id:integer user_id:integer overall:float offset:float audiovisual_design:float plugin_design:float utility_design:float script_design:float  --force --skip-migration

:: reputation that's been given
call rails g scaffold reputation_links from_rep_id:integer to_rep_id:integer  --force --skip-migration


:: ------------------------------------------------------
:: many to many mappings between users and mods
:: ------------------------------------------------------

:: stars users have given to mods
call rails g scaffold mod_stars mod_id:integer user_id:integer --force --skip-migration

:: stars users have given to mod lists
call rails g scaffold mod_list_stars mod_list_id:integer user_id:integer --force --skip-migration

:: users that have authored mods
call rails g scaffold mod_authors mod_id:integer user_id:integer --force --skip-migration

:: ------------------------------------------------------
:: user submission tables
:: ------------------------------------------------------

:: comments submitted by users
call rails g scaffold comments id:integer parent_comment:integer submitted_by:integer hidden:boolean submitted:datetime edited:datetime text_body:text --force --skip-migration

:: mod reviews submitted by users
call rails g scaffold reviews id:integer submitted_by:integer mod_id:integer hidden:boolean rating1:TINYINT rating2:TINYINT rating3:TINYINT rating4:TINYINT:rating5 TINYINT submitted:datetime edited:datetime text_body:text --force --skip-migration

:: installation notes submitted by users
call rails g scaffold installation_notes id:integer submitted_by:integer mod_version_id:integer always:boolean note_type:integer submitted:datetime edited:datetime text_body:text --force --skip-migration

:: compatibility notes submitted by users
call rails g scaffold compatibility_notes id:integer submitted_by:integer mod_mode:integer compatibility_patch:integer compatibility_status:integer --force --skip-migration

:: comments on mods
call rails g scaffold mod_comments mod_id:integer comment_id:integer --force --skip-migration

:: comments on mod_lists
call rails g scaffold mod_list_comments mod_list_id:integer comment_id:integer --force --skip-migration

:: comments on user profiles
call rails g scaffold user_comments user_id:integer comment_id:integer --force --skip-migration

:: review, compatibility note, and installation note
call rails g scaffold helpful_marks review_id:integer compatibility_note_id:integer installation_note_id:integer submitted_by:integer helpful:boolean --force --skip-migration

:: incorrect notes for reviews, compatibility notes, and installation notes
call rails g scaffold incorrect_notes id:integer review_id:integer compatibility_note_id:integer installation_note_id:integer submitted_by:integer reason:text --force --skip-migration

:: agreement marks for incorrect notes
call rails g scaffold agreement_marks incorrect_note_id:integer submitted_by:integer agree:boolean --force --skip-migration

:: installation notes that have been resolved or ignored by the user for a particular mod list
call rails g scaffold mod_list_installation_notes mod_list_id:integer installation_note_id:integer status:integer --force --skip-migration

:: compatibility notes that have been resolved or ignored by the user for a particular mod list
call rails g scaffold mod_list_compatibility_notes mod_list_id:integer compatibility_note_id:integer status:integer --force --skip-migration

:: compatibility notes associated with mod versions
call rails g scaffold mod_version_compatibility_notes mod_version_id:integer compatibility_note_id:integer --force --skip-migration