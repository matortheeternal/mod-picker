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
                data: "nexus_infos.authors"
            },
            {
                visibility: true,
                label: "Endorsements",
                data: "nexus_infos.endorsements",
                filter: "number"
            },
            {
                visibility: true,
                label: "Unique DLs",
                data: "nexus_infos.unique_downloads",
                filter: "number"
            },
            {
                visibility: false,
                label: "Total DLs",
                data: "nexus_infos.total_downloads",
                filter: "number"
            },
            {
                visibility: false,
                label: "Views",
                data: "nexus_infos.views",
                filter: "number"
            },
            {
                visibility: false,
                label: "Posts",
                data: "nexus_infos.posts_count",
                filter: "number"
            },
            {
                visibility: false,
                label: "Videos",
                data: "nexus_infos.videos_count",
                filter: "number"
            },
            {
                visibility: false,
                label: "Images",
                data: "nexus_infos.images_count",
                filter: "number"
            },
            {
                visibility: false,
                label: "Files",
                data: "nexus_infos.files_count",
                filter: "number"
            },
            {
                visibility: false,
                label: "Released",
                data: "nexus_infos.date_added",
                filter: "date"
            },
            {
                visibility: true,
                label: "Updated",
                data: "nexus_infos.date_updated",
                filter: "date"
            }
        ];
    }
});