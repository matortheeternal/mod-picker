app.service('detailsFactory', function() {
    var factory = this;

    this.modDetails = function() {
        return [
            {
                group: "General",
                visibility: false,
                label: "Authors",
                data: "authors",
                icon: "fa-pencil-square-o"
            },
            {
                group: "General",
                visibility: false,
                label: "Primary Category",
                data: "primary_category.name",
                icon: "fa-folder-open"
            },
            {
                group: "General",
                visibility: false,
                label: "Secondary Category",
                data: "secondary_category.name",
                icon: "fa-folder-open-o"
            },
            {
                group: "General",
                visibility: false,
                label: "Submitted",
                data: "submitted",
                filter: "date",
                icon: "fa-calendar-plus-o"
            },
            {
                group: "General",
                visibility: true,
                label: "Released",
                data: "released",
                filter: "date",
                icon: "fa-calendar-o"
            },
            {
                group: "General",
                visibility: false,
                label: "Updated",
                data: "updated",
                filter: "date",
                icon: "fa-history"
            },
            {
                group: "Mod Picker",
                visibility: false,
                label: "Stars",
                data: "stars_count",
                filter: "number",
                icon: "fa-star"
            },
            {
                group: "Mod Picker",
                visibility: true,
                label: "Reputation",
                data: "reputation",
                filter: "number:0",
                icon: "fa-trophy"
            },
            {
                group: "Mod Picker",
                visibility: false,
                label: "Avg Rating",
                data: "average_rating",
                filter: "number:0",
                icon: "fa-percent"
            },
            {
                group: "Mod Picker",
                visibility: false,
                label: "Plugins",
                data: "plugins_count",
                filter: "number",
                icon: "fa-plug"
            },
            {
                group: "Mod Picker",
                visibility: false,
                label: "Assets",
                data: "asset_files_count",
                filter: "number",
                icon: "fa-files-o"
            },
            {
                group: "Mod Picker",
                visibility: false,
                label: "Mod Lists",
                data: "mod_lists_count",
                filter: "number",
                icon: "fa-list-ul"
            },
            {
                group: "Mod Picker",
                visibility: false,
                label: "Required Mods",
                data: "required_mods_count",
                filter: "number",
                icon: "fa-chain"
            },
            {
                group: "Mod Picker",
                visibility: false,
                label: "Required By",
                data: "required_by_count",
                filter: "number",
                icon: "fa-chain"
            },
            {
                group: "Mod Picker",
                visibility: false,
                label: "Tags",
                data: "tags_count",
                filter: "number",
                icon: "fa-tags"
            },
            {
                group: "Site Statistics",
                visibility: false,
                label: "Endorsements",
                data: {
                    nexus: "nexus_infos.endorsements"
                },
                filter: "number",
                icon: "fa-thumbs-o-up"
            },
            {
                group: "Site Statistics",
                visibility: false,
                label: "Subscribers",
                data: {
                    workshop: "workshop_infos.subscribers"
                },
                filter: "number",
                icon: "fa-feed"
            },
            {
                group: "Site Statistics",
                visibility: false,
                label: "Unique DLs",
                data: {
                    nexus: "nexus_infos.unique_downloads"
                },
                filter: "number",
                icon: "fa-arrow-circle-down"
            },
            {
                group: "Site Statistics",
                visibility: false,
                label: "Favorites",
                data: {
                    lab: "lover_infos.followers_count",
                    workshop: "workshop_infos.favorites"
                },
                icon: "fa-thumbs-up"
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
                filter: "number",
                icon: "fa-arrow-down"
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
                filter: "number",
                icon: "fa-eye"
            },
            {
                group: "Site Statistics",
                visibility: false,
                label: "Posts",
                data: {
                    nexus: "nexus_infos.posts_count",
                    workshop: "workshop_infos.comments_count"
                },
                filter: "number",
                icon: "fa-comments-o"
            },
            {
                group: "Site Statistics",
                visibility: false,
                label: "Images",
                data: {
                    nexus: "nexus_infos.images_count",
                    workshop: "workshop_infos.images_count"
                },
                filter: "number",
                icon: "fa-image"
            },
            {
                group: "Site Statistics",
                visibility: false,
                label: "Videos",
                data: {
                    nexus: "nexus_infos.videos_count",
                    workshop: "workshop_infos.videos_count"
                },
                filter: "number",
                icon: "fa-film"
            },
            {
                group: "Site Statistics",
                visibility: false,
                label: "Files",
                data: {
                    nexus: "nexus_infos.files_count"
                },
                filter: "number",
                icon: "fa-files-o"
            },
            {
                group: "Site Statistics",
                visibility: false,
                label: "Bugs",
                data: {
                    nexus: "nexus_infos.bugs_count"
                },
                filter: "number",
                icon: "fa-bug"
            },
            {
                group: "Site Statistics",
                visibility: false,
                label: "Discussions",
                data: {
                    nexus: "nexus_infos.discussions_count",
                    workshop: "workshop_infos.discussions_count"
                },
                filter: "number",
                icon: "fa-commenting-o"
            },
            {
                group: "Site Statistics",
                visibility: false,
                label: "Articles",
                data: {
                    nexus: "nexus_infos.articles_count"
                },
                filter: "number",
                icon: "fa-file-word-o"
            }
        ];
    };

    this.modDetailGroups = function() {
        return ["General", "Mod Picker", "Site Statistics"];
    };
});
