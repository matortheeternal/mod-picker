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
                filter: "number"
            },
            {
                group: "Mod Picker",
                visibility: false,
                label: "Avg Rating",
                data: "average_rating",
                filter: "number"
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
                }
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
});
