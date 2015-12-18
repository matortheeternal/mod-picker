:: ------------------------------------------------------
:: site mod info tables
:: ------------------------------------------------------

call rails g scaffold nexus_infos nm_id:integer uploaded_by:text authors:text:datetime_released:datetime:datetime_updated:datetime endorsements:integer total_downloads:integer unique_downloads:integer views:integer posts_count:integer videos_count:integer images_count:integer files_count:integer articles_count:integer nexus_category:integer changelog:text

call rails g scaffold workshop_infos ws_id:integer

call rails g scaffold lover_infos ll_id:integer


:: ------------------------------------------------------
:: mod tables
:: ------------------------------------------------------

:: mods available on the site
call rails g scaffold mods mod_id:integer game:text name:text aliases:text is_utility:boolean category:integer has_adult_content:boolean nm_id:integer ws_id:integer ll_id:integer

:: versions of mods available on the site
call rails g scaffold mod_versions mv_id:integer mod_id:integer released:datetime obsolete:boolean dangerous:boolean

:: all mod asset files we ever encounter, no duplicate file paths
call rails g scaffold mod_asset_files maf_id:integer filepath:string

:: maps asset files to mod versions
call rails g scaffold mod_version_file_map mv_id:integer maf_id:integer

:: plugins that we have informaton on
call rails g scaffold plugins pl_id:integer mv_id:integer filename:text author:text description:text hash:string
:: plugins that serve as masters for other plugins
call rails g scaffold masters mst_id:integer pl_id:integer

:: override records associated with a plugin
call rails g scaffold plugin_override_map pl_id:integer mst_id:integer form_id:integer sig:string name:text is_itm:boolean is_itpo:boolean is_udr:boolean

:: record groups associated with a plugin
call rails g scaffold plugin_record_groups pl_id:integer sig:string name:text new_records:integer override_records:integer

:: mod lists created by users
call rails g scaffold mod_lists ml_id:integer game:text created_by:integer is_collection:boolean is_public:boolean has_adult_content:boolean status:integer created:datetime completed:datetime description:text

:: plugins in mod lists
call rails g scaffold mod_list_plugins ml_id:integer pl_id:integer active:boolean load_order:integer

:: custom plugins in mod lists
call rails g scaffold mod_list_custom_plugins ml_id:integer active:boolean load_order:integer title:string description:text

:: mods in mod lists
call rails g scaffold mod_list_mods ml_id:integer mod_id:integer active:boolean install_order:integer


:: ------------------------------------------------------
:: user tables
:: ------------------------------------------------------

:: user biographies - connections to other sites
call rails g scaffold user_bios  bio_id:integer nexus_username:string nexus_verified:boolean lover_username:string lover_verified:boolean steam_username:string steam_verified:boolean

:: the settings associated with a particular user
call rails g scaffold user_settings set_id:integer show_notifications:boolean show_tooltips:boolean email_notifications:boolean email_public:boolean allow_adult_content:boolean allow_nexus_mods:boolean allow_lovers_lab:boolean allow_steam_workshop:boolean

:: the reputation associated with a particular user
call rails g scaffold user_reputations rep_id:integer overall:float offset:float audiovisual_design:float plugin_design:float utilty_design:float script_design:float

:: users registered on the site
call rails g scaffold users user_id:integer username:string email:string hash:string user_level:integer title:string avatar:text joined:datetime last_seen:datetime bio_id:integer set_id:integer rep_id:integer active_ml_id:integer active_mc_id:integer

:: reputation that's been given
call rails g scaffold reputation_map from_rep_id:integer to_rep_id:integer


:: ------------------------------------------------------
:: many to many mappings between users and mods
:: ------------------------------------------------------

:: stars users have given to mods
call rails g scaffold user_mod_star_map mod_id:integer user_id:integer

:: stars users have given to mod lists
call rails g scaffold user_mod_list_star_map ml_id:integer user_id:integer

:: users that have authored mods
call rails g scaffold user_mod_author_map mod_id:integer user_id:integer

:: ------------------------------------------------------
:: user submission tables
:: ------------------------------------------------------

:: comments submitted by users
call rails g scaffold comments c_id:integer parent_comment:integer submitted_by:integer hidden:boolean submitted:datetime edited:datetime:text_body:text

:: mod reviews submitted by users
call rails g scaffold reviews r_id:integer submitted_by:integer mod_id:integer hidden:boolean rating1 TINYINT rating2 TINYINT rating3 TINYINT rating4 TINYINT rating5 TINYINT submitted:datetime edited:datetime:text_body:text

:: installation notes submitted by users
call rails g scaffold installation_notes in_id:integer submitted_by:integer mv_id:integer always:boolean note_type:integer submitted:datetime edited:datetime:text_body:text

:: compatibility notes submitted by users
call rails g scaffold compatibility_notes cn_id:integer submitted_by:integer mod_mode:integer compatibility_patch:integer compatibility_status:integer

:: comments on mods
call rails g scaffold mod_comments mod_id:integer c_id:integer

:: comments on mod_lists
call rails g scaffold mod_list_comments ml_id:integer c_id:integer

:: comments on user profiles
call rails g scaffold user_comments user_id:integer c_id:integer

:: review, compatibility note, and installation note
call rails g scaffold helpful_marks r_id:integer cn_id:integer in_id:integer submitted_by:integer helpful:boolean

:: incorrect notes for reviews, compatibility notes, and installation notes
call rails g scaffold incorrect_notes inc_id:integer r_id:integer cn_id:integer in_id:integer submitted_by:integer reason:text

:: agreement marks for incorrect notes
call rails g scaffold agreement_marks inc_id:integer submitted_by:integer agree:boolean

:: installation notes that have been resolved or ignored by the user for a particular mod list
call rails g scaffold mod_list_installation_notes ml_id:integer in_id:integer status:integer

:: compatibility notes that have been resolved or ignored by the user for a particular mod list
call rails g scaffold mod_list_compatibility_notes ml_id:integer cn_id:integer status:integer