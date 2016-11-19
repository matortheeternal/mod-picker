app.service('columnsFactory', function() {
    var factory = this;

    this.modColumns = function() {
        return [
            {
                group: "General",
                visibility: true,
                required: true,
                label: "Mod Name",
                data: "name",
                link: function(mod) {
                    return "#/mod/" + mod.id
                },
                invertSort: true
            },
            {
                group: "General",
                visibility: true,
                label: "Authors",
                data: "authors",
                invertSort: true
            },
            {
                group: "General",
                visibility: false,
                label: "Primary Category",
                data: "primary_category.name",
                unsortable: true
            },
            {
                group: "General",
                visibility: false,
                label: "Secondary Category",
                data: "secondary_category.name",
                unsortable: true
            },
            {
                group: "General",
                visibility: false,
                label: "Submitted",
                data: "submitted",
                filter: "date"
            },
            {
                group: "General",
                visibility: true,
                label: "Released",
                data: "released",
                filter: "date"
            },
            {
                group: "General",
                visibility: false,
                label: "Updated",
                data: "updated",
                filter: "date"
            },
            {
                group: "Mod Picker",
                visibility: true,
                label: "Stars",
                data: "stars_count",
                filter: "number"
            },
            {
                group: "Mod Picker",
                visibility: true,
                label: "Reputation",
                data: "reputation",
                filter: "number:0"
            },
            {
                group: "Mod Picker",
                visibility: false,
                label: "Avg Rating",
                data: "average_rating",
                filter: "number:0"
            },
            {
                group: "Mod Picker",
                visibility: false,
                label: "Plugins",
                data: "plugins_count",
                filter: "number"
            },
            {
                group: "Mod Picker",
                visibility: false,
                label: "Assets",
                data: "asset_files_count",
                filter: "number"
            },
            {
                group: "Mod Picker",
                visibility: false,
                label: "Mod Lists",
                data: "mod_lists_count",
                filter: "number"
            },
            {
                group: "Mod Picker",
                visibility: false,
                label: "Required Mods",
                data: "required_mods_count",
                filter: "number"
            },
            {
                group: "Mod Picker",
                visibility: false,
                label: "Required By",
                data: "required_by_count",
                filter: "number"
            },
            {
                group: "Mod Picker",
                visibility: false,
                label: "Tags",
                data: "tags_count",
                filter: "number"
            },
            {
                group: "Mod Picker",
                visibility: false,
                label: "Reviews",
                data: "reviews_count",
                filter: "number"
            },
            {
                group: "Mod Picker",
                visibility: false,
                label: "Compatibility Notes",
                data: "compatibility_notes_count",
                filter: "number"
            },
            {
                group: "Mod Picker",
                visibility: false,
                label: "Install Order Notes",
                data: "install_order_notes_count",
                filter: "number"
            },
            {
                group: "Mod Picker",
                visibility: false,
                label: "Load Order Notes",
                data: "load_order_notes_count",
                filter: "number"
            },
            {
                group: "Site Statistics",
                visibility: false,
                label: "Endorsements",
                data: {
                    nexus: "nexus_infos.endorsements"
                },
                filter: "number"
            },
            {
                group: "Site Statistics",
                visibility: false,
                label: "Subscribers",
                data: {
                    workshop: "workshop_infos.subscribers"
                },
                filter: "number"
            },
            {
                group: "Site Statistics",
                visibility: false,
                label: "Unique DLs",
                data: {
                    nexus: "nexus_infos.unique_downloads"
                },
                filter: "number"
            },
            {
                group: "Site Statistics",
                visibility: false,
                label: "Favorites",
                data: {
                    lab: "lover_infos.followers_count",
                    workshop: "workshop_infos.favorites"
                }
            },
            {
                group: "Site Statistics",
                source: "nexus",
                visibility: false,
                label: "Downloads",
                data: {
                    nexus: "nexus_infos.downloads",
                    lab: "lover_infos.downloads"
                },
                filter: "number"
            },
            {
                group: "Site Statistics",
                visibility: false,
                label: "Views",
                data: {
                    nexus: "nexus_infos.views",
                    lab: "lover_infos.views",
                    workshop: "workshop_infos.views"
                },
                filter: "number"
            },
            {
                group: "Site Statistics",
                visibility: false,
                label: "Posts",
                data: {
                    nexus: "nexus_infos.posts_count",
                    workshop: "workshop_infos.comments_count"
                },
                filter: "number"
            },
            {
                group: "Site Statistics",
                visibility: false,
                label: "Images",
                data: {
                    nexus: "nexus_infos.images_count",
                    workshop: "workshop_infos.images_count"
                },
                filter: "number"
            },
            {
                group: "Site Statistics",
                visibility: false,
                label: "Videos",
                data: {
                    nexus: "nexus_infos.videos_count",
                    workshop: "workshop_infos.videos_count"
                },
                filter: "number"
            },
            {
                group: "Site Statistics",
                visibility: false,
                label: "Files",
                data: {
                    nexus: "nexus_infos.files_count"
                },
                filter: "number"
            },
            {
                group: "Site Statistics",
                visibility: false,
                label: "Bugs",
                data: {
                    nexus: "nexus_infos.bugs_count"
                },
                filter: "number"
            },
            {
                group: "Site Statistics",
                visibility: false,
                label: "Discussions",
                data: {
                    nexus: "nexus_infos.discussions_count",
                    workshop: "workshop_infos.discussions_count"
                },
                filter: "number"
            },
            {
                group: "Site Statistics",
                visibility: false,
                label: "Articles",
                data: {
                    nexus: "nexus_infos.articles_count"
                },
                filter: "number"
            }
        ];
    };

    this.modColumnGroups = function() {
        return ["General", "Mod Picker", "Site Statistics"];
    };

    this.userColumns = function() {
        return [
            {
                group: "General",
                visibility: true,
                required: true,
                label: "Username",
                data: "username",
                image: function(user) {
                    return user.avatars && user.avatars.small
                },
                imageClass: "avatar-small",
                link: function(user) {
                    return "#/user/" + user.id
                },
                invertSort: true
            },
            {
                group: "General",
                visibility: true,
                label: "Role",
                data: "role",
                filter: "humanize:1"
            },
            {
                group: "General",
                visibility: true,
                label: "Title",
                data: "title",
                unsortable: true
            },
            {
                group: "General",
                visibility: true,
                label: "Joined",
                data: "joined",
                filter: "date"
            },
            {
                group: "General",
                visibility: true,
                label: "Last Seen",
                data: "last_sign_in_at",
                filter: "date"
            },
            {
                group: "General",
                visibility: true,
                label: "Reputation",
                data: "reputation.overall",
                sortData: "user_reputations.overall",
                filter: "number:0"
            },
            {
                group: "Content Statistics",
                visibility: false,
                label: "Comments",
                data: "submitted_comments_count",
                filter: "number"
            },
            {
                group: "Content Statistics",
                visibility: false,
                label: "Profile Comments",
                data: "comments_count",
                filter: "number"
            },
            {
                group: "Content Statistics",
                visibility: false,
                label: "Authored Mods",
                data: "authored_mods_count",
                filter: "number"
            },
            {
                group: "Content Statistics",
                visibility: false,
                label: "Mod Lists",
                data: "mod_lists_count",
                filter: "number"
            },
            {
                group: "Content Statistics",
                visibility: false,
                label: "Mod Collections",
                data: "mod_collections_count",
                filter: "number"
            },
            {
                group: "Content Statistics",
                visibility: false,
                label: "Submitted Mods",
                data: "submitted_mods_count",
                filter: "number"
            },
            {
                group: "Contribution Statistics",
                visibility: false,
                label: "Reviews",
                data: "reviews_count",
                filter: "number"
            },
            {
                group: "Contribution Statistics",
                visibility: false,
                label: "Compatibility Notes",
                data: "compatibility_notes_count",
                filter: "number"
            },
            {
                group: "Contribution Statistics",
                visibility: false,
                label: "Install Order Notes",
                data: "install_order_notes_count",
                filter: "number"
            },
            {
                group: "Contribution Statistics",
                visibility: false,
                label: "Load Order Notes",
                data: "load_order_notes_count",
                filter: "number"
            },
            {
                group: "Contribution Statistics",
                visibility: false,
                label: "Corrections",
                data: "corrections_count",
                filter: "number"
            },
            {
                group: "Contribution Statistics",
                visibility: false,
                label: "Tags",
                data: "tags_count",
                filter: "number"
            },
            {
                group: "Extended Statistics",
                visibility: false,
                label: "Mod Tags",
                data: "mod_tags_count",
                filter: "number"
            },
            {
                group: "Extended Statistics",
                visibility: false,
                label: "Mod List Tags",
                data: "mod_list_tags_count",
                filter: "number"
            },
            {
                group: "Extended Statistics",
                visibility: false,
                label: "Helpful Marks",
                data: "helpful_marks_count",
                filter: "number"
            },
            {
                group: "Extended Statistics",
                visibility: false,
                label: "Agreement Marks",
                data: "agreement_marks_count",
                filter: "number"
            },
            {
                group: "Extended Statistics",
                visibility: false,
                label: "Starred Mods",
                data: "starred_mods_count",
                filter: "number"
            },
            {
                group: "Extended Statistics",
                visibility: false,
                label: "Starred Mod Lists",
                data: "starred_mod_lists_count",
                filter: "number"
            }
        ];
    };

    this.userColumnGroups = function() {
        return ["General", "Content Statistics", "Contribution Statistics", "Extended Statistics"];
    };

    this.modListModColumns = function() {
        return [
            {
                group: "General",
                visibility: true,
                required: true,
                label: "Index",
                data: "index",
                filter: "number",
                class: "index-column",
                dynamic: true
            },
            {
                group: "General",
                visibility: true,
                required: true,
                label: "Name",
                data: function(item) {
                    return item.name || item.mod.name;
                },
                link: function(item) {
                    if (item.mod) {
                        return "#/mod/" + item.mod.id;
                    } else if (item.url) {
                        return item.url;
                    }
                },
                class: "primary-column",
                dynamic: true
            },
            {
                group: "General",
                visibility: false,
                label: "Aliases",
                data: "mod.aliases",
                class: "aliases-column"
            },
            {
                group: "General",
                visibility: true,
                label: "Authors",
                data: "mod.authors",
                class: "author-column"
            },
            {
                group: "General",
                visibility: true,
                label: "Primary Category",
                data: "mod.primary_category.name",
                class: "category-column"
            },
            {
                group: "General",
                visibility: false,
                label: "Secondary Category",
                data: "mod.secondary_category.name",
                class: "category-column"
            },
            {
                group: "General",
                visibility: false,
                label: "Status",
                data: "mod.status",
                class: "status-column"
            },
            {
                group: "General",
                visibility: false,
                label: "Avg Rating",
                data: "mod.average_rating",
                filter: "number:0"
            },
            {
                group: "General",
                visibility: false,
                label: "Reputation",
                data: "mod.reputation",
                filter: "number:0"
            },
            {
                group: "General",
                visibility: false,
                label: "Stars",
                data: "mod.stars_count",
                filter: "number"
            },
            {
                group: "General",
                visibility: false,
                label: "Asset Files",
                data: "mod.asset_files_count",
                filter: "number"
            },
            {
                group: "General",
                visibility: false,
                label: "Plugins",
                data: "mod.plugins_count",
                filter: "number"
            },
            {
                group: "General",
                visibility: true,
                label: "Released",
                data: "mod.released",
                filter: "date"
            },
            {
                group: "General",
                visibility: true,
                label: "Updated",
                data: "mod.updated",
                filter: "date"
            }
        ];
    };

    this.modListModColumnGroups = function() {
        return ["General"];
    };

    this.modListPluginColumns = function() {
        return [
            {
                group: "General",
                visibility: true,
                required: true,
                label: "Index",
                data: function(item) {
                    if (!item.merged) return item.index;
                },
                note: function($scope, item) {
                    if (item.merged) return 'merged';
                },
                filter: "number",
                class: "index-column",
                dynamic: true
            },
            {
                group: "General",
                visibility: false,
                required: true,
                label: "Load Order",
                data: function(item) {
                    if (!item.merged) return item.index;
                },
                note: function($scope, item) {
                    if (item.merged) return 'merged';
                },
                filter: "hex",
                class: "load-order-column",
                dynamic: true
            },
            {
                group: "General",
                visibility: true,
                required: true,
                label: "Filename",
                data: function(item) {
                    return item.filename || item.plugin.filename;
                },
                link: function(item) {
                    if (item.mod && item.plugin) {
                        return "#/mod/" + item.mod.id + "/analysis?plugin=" + item.plugin.id;
                    }
                },
                note: function($scope, item) {
                    return item.cleaned ? '(cleaned)' : '';
                },
                class: "primary-column",
                invertSort: true,
                dynamic: true
            },
            {
                group: "General",
                visibility: false,
                label: "Mod",
                data: "mod.name",
                link: function(item) {
                    if (item.mod) {
                        return "#/mod/" + item.mod.id;
                    }
                },
                sortData: "mods.name",
                invertSort: true
            },
            {
                group: "General",
                visibility: true,
                label: "Primary Category",
                data: "mod.primary_category.name",
                class: 'category-column',
                unsortable: true
            },
            {
                group: "General",
                visibility: false,
                label: "Secondary Category",
                data: "mod.secondary_category.name",
                class: 'category-column',
                unsortable: true
            },
            {
                group: "General",
                visibility: false,
                label: "CRC",
                data: "plugin.crc_hash",
                class: "crc-column",
                invertSort: true
            },
            {
                group: "General",
                visibility: false,
                label: "File Size",
                data: "plugin.file_size",
                filter: "bytes"
            },
            {
                group: "General",
                visibility: false,
                label: "Author",
                data: "plugin.author",
                class: "author-column",
                invertSort: true
            },
            {
                group: "General",
                visibility: true,
                label: "Records",
                data: "plugin.record_count",
                filter: "number"
            },
            {
                group: "General",
                visibility: true,
                label: "Overrides",
                data: "plugin.override_count",
                filter: "number"
            },
            {
                group: "General",
                visibility: true,
                label: "Errors",
                data: "plugin.errors_count",
                filter: "number"
            }
        ];
    };

    this.modListPluginColumnGroups = function() {
        return ["General"];
    };

    this.modListColumns = function(onIndex) {
        return [
            {
                group: "General",
                visibility: true,
                required: true,
                label: "Name",
                data: "name",
                class: "primary-column",
                link: function(item) {
                    return "#/mod-list/" + item.id;
                },
                invertSort: true
            },
            {
                group: "General",
                visibility: false,
                label: "Submitter",
                data: "submitter.username",
                link: function(item) {
                    return "#/user/" + item.submitter.id;
                },
                sortData: "users.username",
                invertSort: true
            },
            {
                group: "General",
                visibility: true,
                label: "Status",
                data: "status",
                filter: "humanize:1"
            },
            {
                group: "General",
                visibility: !onIndex,
                label: "Visibility",
                data: function(item) {
                    switch(item.visibility) {
                        case 'visibility_private': return 'Private';
                        case 'visibility_unlisted': return 'Unlisted';
                        case 'visibility_public': return 'Public';
                    }
                },
                filter: "humanize:1",
                unsortable: true
            },
            {
                group: "General",
                visibility: !!onIndex,
                label: "Tools",
                data: "tools_count",
                filter: "number"
            },
            {
                group: "General",
                visibility: true,
                label: "Mods",
                data: "mods_count",
                filter: "number"
            },
            {
                group: "General",
                visibility: true,
                label: "Plugins",
                data: "plugins_count",
                filter: "number"
            },
            {
                group: "General",
                visibility: !!onIndex,
                label: "Config Files",
                data: "config_files_count",
                filter: "number"
            },
            {
                group: "Extended",
                visibility: false,
                label: "Custom Tools",
                data: "custom_tools_count",
                filter: "number"
            },
            {
                group: "Extended",
                visibility: false,
                label: "Custom Mods",
                data: "custom_mods_count",
                filter: "number"
            },
            {
                group: "Extended",
                visibility: false,
                label: "Custom Plugins",
                data: "custom_plugins_count",
                filter: "number"
            },
            {
                group: "Extended",
                visibility: false,
                label: "Custom Config Files",
                data: "custom_config_files_count",
                filter: "number"
            },
            {
                group: "Extended",
                visibility: false,
                label: "Compatibility Notes",
                data: "compatibility_notes_count",
                filter: "number"
            },
            {
                group: "Extended",
                visibility: false,
                label: "Install Order Notes",
                data: "install_order_notes_count",
                filter: "number"
            },
            {
                group: "Extended",
                visibility: false,
                label: "Load Order Notes",
                data: "load_order_notes_count",
                filter: "number"
            },
            {
                group: "Extended",
                visibility: false,
                label: "Ignored Notes",
                data: "ignored_notes_count",
                filter: "number"
            },
            {
                group: "Extended",
                visibility: false,
                label: "BSA Files",
                data: "bsa_files_count",
                filter: "number"
            },
            {
                group: "Extended",
                visibility: false,
                label: "Asset Files",
                data: "asset_files_count",
                filter: "number"
            },
            {
                group: "Extended",
                visibility: false,
                label: "Records",
                data: "records_count",
                filter: "number"
            },
            {
                group: "Extended",
                visibility: false,
                label: "Override Records",
                data: "override_records_count",
                filter: "number"
            },
            {
                group: "Extended",
                visibility: false,
                label: "Plugin Errors",
                data: "plugin_errors_count",
                filter: "number"
            },
            {
                group: "General",
                visibility: false,
                label: "Tags",
                data: "tags_count",
                filter: "number"
            },
            {
                group: "General",
                visibility: !onIndex,
                label: "Stars",
                data: "stars_count",
                filter: "number"
            },
            {
                group: "General",
                visibility: false,
                label: "Comments",
                data: "comments_count",
                filter: "number"
            },
            {
                group: "General",
                visibility: false,
                label: "Started",
                data: "submitted",
                filter: "date"
            },
            {
                group: "General",
                visibility: false,
                label: "Completed",
                data: "completed",
                filter: "date"
            },
            {
                group: "General",
                visibility: false,
                label: "Updated",
                data: "updated",
                filter: "date"
            }
        ]
    };

    this.modListColumnGroups = function() {
        return ["General", "Extended"];
    };

    this.pluginColumns = function() {
        return [
            {
                group: "General",
                visibility: true,
                required: true,
                label: "Filename",
                data: "filename",
                class: "primary-column",
                link: function(item) {
                    return "#/mod/" + item.mod.id + "/analysis?plugin=" + item.id;
                },
                invertSort: true
            },
            {
                group: "General",
                visibility: true,
                label: "Mod",
                data: "mod.name",
                link: function(item) {
                    return "#/mod/" + item.mod.id;
                },
                sortData: "mods.name",
                invertSort: true
            },
            {
                group: "General",
                visibility: false,
                label: "CRC",
                data: "crc_hash",
                invertSort: true
            },
            {
                group: "General",
                visibility: false,
                label: "Author",
                data: "author",
                invertSort: true
            },
            {
                group: "General",
                visibility: true,
                label: "File Size",
                data: "file_size",
                filter: "bytes"
            },
            {
                group: "General",
                visibility: true,
                label: "Records",
                data: "record_count",
                filter: "number"
            },
            {
                group: "General",
                visibility: true,
                label: "Overrides",
                data: "override_count",
                filter: "number"
            },
            {
                group: "General",
                visibility: false,
                label: "Errors",
                data: "errors_count",
                filter: "number"
            },
            {
                group: "General",
                visibility: false,
                label: "Mod Lists",
                data: "mod_lists_count",
                filter: "number"
            },
            {
                group: "General",
                visibility: false,
                label: "Load Order Notes",
                data: "load_order_notes_count",
                filter: "number"
            }
        ]
    };

    this.pluginColumnGroups = function() {
        return ["General"];
    };
    
    this.modListPluginStoreColumns = function() {
        return [
            {
                label: "Active",
                data: "active",
                class: "short-column"
            },
            {
                label: "Filename",
                data: "filename",
                invertSort: true
            },
            {
                label: "Mod Index",
                data: "mod_index",
                class: "short-column",
                invertSort: true
            },
            {
                label: "Mod",
                data: "mod.name",
                invertSort: true
            },
            {
                label: "Mod Option",
                data: "mod_option.name",
                invertSort: true
            }

        ];
    };

    this.modListModDetailsColumns = function() {
        return [
            {
                label: "Active",
                data: "active",
                class: "short-column"
            },
            {
                label: "Name",
                data: "display_name",
                title: "name"
            },
            {
                label: "Default",
                data: "default",
                class: "short-column"
            },
            {
                label: "File Size",
                data: "size",
                class: "short-column"
            },
            {
                label: "Asset Files",
                data: "asset_files_count",
                class: "short-column"
            },
            {
                label: "Plugins",
                data: "plugins",
                sortData: "plugins.length"
            }
            
        ];
    };

    this.tagColumns = function() {
        return [
            {
                group: "General",
                visibility: true,
                required: true,
                label: "Text",
                data: "text",
                invertSort: true,
                dynamic: true
            },
            {
                group: "General",
                visibility: true,
                label: "Submitter",
                data: "submitter.username",
                link: function(item) {
                    return "#/user/" + item.submitter.id;
                },
                invertSort: true
            },
            {
                group: "General",
                visibility: true,
                label: "Mods Count",
                data: "mods_count",
                filter: "number"
            },
            {
                group: "General",
                visibility: true,
                label: "Mod Lists Count",
                data: "mod_lists_count",
                filter: "number"
            }
        ]
    };

    this.tagColumnGroups = function() {
        return ["General"];
    };
});
