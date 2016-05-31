app.service('columnsFactory', function (sliderFactory) {
    this.modColumns = function() {
        return [
            {
                visibility: true,
                required: true,
                label: "Mod Name",
                data: "name",
                link: function(mod) {
                    return "#/mod/" + mod.id
                }
            },
            {
                visibility: true,
                label: "Authors",
                data: "authors"
            },
            {
                visibility: true,
                label: "Released",
                data: "released",
                filter: "date"
            },
            {
                visibility: true,
                label: "Updated",
                data: "updated",
                filter: "date"
            },
            {
                visibility: true,
                label: "Stars",
                data: "stars_count",
                filter: "number"
            },
            {
                visibility: true,
                label: "Reputation",
                data: "reputation",
                filter: "number"
            },
            {
                visibility: false,
                label: "Avg Rating",
                data: "average_rating",
                filter: "number"
            },
            {
                visibility: false,
                label: "Plugins",
                data: "plugins_count",
                filter: "number"
            },
            {
                visibility: false,
                label: "Assets",
                data: "assets_count",
                filter: "number"
            },
            {
                visibility: false,
                label: "Mod Lists",
                data: "mod_lists_count",
                filter: "number"
            },
            {
                visibility: false,
                label: "Required Mods",
                data: "required_mods_count",
                filter: "number"
            },
            {
                visibility: false,
                label: "Required By",
                data: "required_by_count",
                filter: "number"
            },
            {
                visibility: false,
                label: "Tags",
                data: "tags_count",
                filter: "number"
            },
            {
                visibility: false,
                label: "Reviews",
                data: "reviews_count",
                filter: "number"
            },
            {
                visibility: false,
                label: "Compatibility Notes",
                data: "compatibility_notes_count",
                filter: "number"
            },
            {
                visibility: false,
                label: "Install Order Notes",
                data: "install_order_notes_count",
                filter: "number"
            },
            {
                visibility: false,
                label: "Load Order Notes",
                data: "load_order_notes_count",
                filter: "number"
            },
            {
                source: "nexus",
                visibility: false,
                label: "Endorsements",
                data: "nexus_infos.endorsements",
                filter: "number"
            },
            {
                source: "nexus",
                visibility: false,
                label: "Unique DLs",
                data: "nexus_infos.unique_downloads",
                filter: "number"
            },
            {
                source: "nexus",
                visibility: false,
                label: "Total DLs",
                data: "nexus_infos.total_downloads",
                filter: "number"
            },
            {
                source: "nexus",
                visibility: false,
                label: "Views",
                data: "nexus_infos.views",
                filter: "number"
            },
            {
                source: "nexus",
                visibility: false,
                label: "Posts",
                data: "nexus_infos.posts_count",
                filter: "number"
            },
            {
                source: "nexus",
                visibility: false,
                label: "Videos",
                data: "nexus_infos.videos_count",
                filter: "number"
            },
            {
                source: "nexus",
                visibility: false,
                label: "Images",
                data: "nexus_infos.images_count",
                filter: "number"
            },
            {
                source: "nexus",
                visibility: false,
                label: "Files",
                data: "nexus_infos.files_count",
                filter: "number"
            }
        ];
    }
});
