app.service('columnsFactory', function() {
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
                }
            },
            {
                group: "General",
                visibility: true,
                label: "Authors",
                data: "authors"
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
                visibility: true,
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
                data: "assets_count",
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
                    labe: "lover_infos.followers_count",
                    workshop: "workshop_infos.favorites"
                }
            },
            {
                group: "Site Statistics",
                source: "nexus",
                visibility: false,
                label: "Downloads",
                data: {
                    nexus: "nexus_infos.total_downloads",
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
                link: function(user) {
                    return "#/user/" + user.id
                }
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
                data: "title"
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

    this.commentColumns = function() {
        return [
            {
                group: "General",
                visibility: true,
                required: true,
                label: "Submitter",
                data: "submitter.username",
                link: function(comment) {
                    return "#/user/" + comment.submitter.id
                }
            },
            {
                group: "General",
                visibility: true,
                label: "Commentable",
                data: "commentable_type",
                link: function (comment) {
                    return comment.commentable_link
                }
            },
            {
                group: "General",
                visibility: true,
                label: "Submitted",
                data: "submitted",
                filter: "date"
            },
            {
                group: "General",
                visibility: true,
                label: "Edited",
                data: "edited",
                filter: "date"
            },
            //{
            //    group: "General",
            //    visibility: true,
            //    label: "Parent",
            //    data: "parent_id",
            //    link: function(comment) {
            //        return comment.parent_link
            //    }
            //},
            {
                group: "General",
                visibility: true,
                label: "Replies",
                data: "children_count"
            }
        ];
    };

    this.commentColumnGroups = function() {
        return ["General"]
    };

    // TODO
    this.modListToolColumns = function() {
        return [];
    };

    // TODO
    this.modListModColumns = function() {
        return [];
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
                class: "index-column"
            },
            {
                group: "General",
                visibility: true,
                required: true,
                label: "Filename",
                data: "plugin.filename",
                link: function (modListPlugin) {
                    return "#/mod/" + modListPlugin.mod.id + "/analysis?plugin=" + modListPlugin.plugin.id;
                },
                note: function($scope, item) {
                    return item.cleaned ? '(cleaned)' : '';
                },
                class: "primary-column"
            },
            {
                group: "General",
                visibility: false,
                label: "Mod",
                data: "mod.name",
                link: function (modListPlugin) {
                    return "#/mod/" + modListPlugin.mod.id;
                }
            },
            {
                group: "General",
                visibility: true,
                label: "Primary Category",
                data: "mod.primary_category.name"
            },
            {
                group: "General",
                visibility: false,
                label: "Secondary Category",
                data: "mod.secondary_category.name"
            },
            {
                group: "General",
                visibility: false,
                label: "CRC",
                data: "plugin.crc_hash",
                class: "crc-column"
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
                class: "author-column"
            },
            {
                group: "General",
                visibility: true,
                label: "Record Count",
                data: "plugin.record_count",
                filter: "number"
            },
            {
                group: "General",
                visibility: true,
                label: "Override Count",
                data: "plugin.override_count",
                filter: "number"
            },
            {
                group: "General",
                visibility: true,
                label: "Errors Count",
                data: "plugin.errors_count",
                filter: "number"
            }
        ];
    };

    this.modListPluginColumnGroups = function() {
        return ["General"];
    };
});
