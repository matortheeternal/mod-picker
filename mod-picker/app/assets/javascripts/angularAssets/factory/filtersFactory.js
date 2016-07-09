app.service("filtersFactory", function() {
    var service = this;

    this.modStatisticFilters = function() {
        return [{
                label: "Endorsements",
                common: true,
                sites: { nexus: true },
                data: "endorsements",
                max: 500000,
                param: "end"
            },
            {
                label: "Subscribers",
                common: true,
                sites: { workshop: true },
                data: "subscribers",
                max: 1250000,
                param: "su"
            },
            {
                label: "Unique Downloads",
                common: true,
                sites: { nexus: true },
                data: "unique_downloads",
                max: 10000000,
                param: "ud"
            },
            {
                label: "Favorites",
                common: true,
                sites: { workshop: true, lab: true },
                data: "favorites",
                max: 20000,
                param: "fa"
            },
            {
                label: "Downloads",
                common: true,
                sites: { nexus: true, lab: true },
                data: "downloads",
                max: 50000000,
                param: "dl"
            },
            {
                label: "Views",
                common: true,
                sites: { nexus: true, workshop: true, lab: true },
                data: "views",
                max: 50000000,
                param: "vw"
            },
            {
                label: "Posts Count",
                common: false,
                sites: { nexus: true, workshop: true },
                data: "posts",
                max: 500000,
                param: "pc"
            },
            {
                label: "Images Count",
                common: false,
                sites: { nexus: true, workshop: true },
                data: "images",
                max: 200,
                param: "ic"
            },
            {
                label: "Videos Count",
                common: false,
                sites: { nexus: true, workshop: true },
                data: "videos",
                max: 50,
                param: "vc"
            },
            {
                label: "Files Count",
                common: false,
                sites: { nexus: true },
                data: "files",
                max: 200,
                param: "fc"
            },
            /*{ TODO: Unimplemented on backend
                label: "Bugs Count",
                common: false,
                sites: {nexus: true},
                data: "bugs",
                max: 200
            },*/
            {
                label: "Discussions Count",
                common: false,
                sites: { /*nexus: true, TODO: Unimplemented on backend */ workshop: true },
                data: "discussions",
                max: 50,
                param: "dc"
            },
            {
                label: "Articles Count",
                common: false,
                sites: { nexus: true },
                data: "articles",
                max: 50,
                param: "ac"
            }
        ];
    };

    this.modPickerFilters = function() {
        return [{
                label: "Reputation",
                common: true,
                data: "reputation",
                max: 450,
                param: "rep"
            },
            {
                label: "Average Rating",
                common: true,
                data: "rating",
                max: 100,
                param: "avg"
            },
            {
                label: "Reviews Count",
                common: true,
                data: "reviews",
                max: 200,
                param: "rev"
            },
            {
                label: "Number of Stars",
                common: false,
                data: "stars",
                max: 1000,
                param: "str"
            },
            {
                label: "Compatibility Notes Count",
                common: false,
                data: "compatibility_notes",
                max: 100,
                param: "cnc"
            },
            {
                label: "Install Order Notes Count",
                common: false,
                data: "install_order_notes",
                max: 100,
                param: "ioc"
            },
            {
                label: "Load Order Notes Count",
                common: false,
                data: "load_order_notes",
                max: 100,
                param: "loc"
            }
        ];
    };

    this.modDateFilters = function() {
        return [{
                label: "Date Updated",
                data: "updated",
                type: "Date",
                param: "du"
            },
            {
                label: "Date Released",
                data: "released",
                type: "Date",
                param: "dr"
            }
        ];
    };

    this.modFilters = function() {
        return Array.prototype.concat(
            service.modStatisticFilters(),
            service.modPickerFilters(),
            service.modDateFilters()
        );
    };

    this.userStatisticFilters = function() {
        return [{
                label: "Reputation",
                common: true,
                data: "reputation",
                max: 5000,
                param: "rep"
            },
            {
                label: "Authored Mods",
                common: true,
                data: "authored_mods",
                max: 100,
                param: "mods"
            },
            {
                label: "Comments Count",
                common: true,
                data: "comments",
                max: 1000,
                param: "cmc"
            },
            {
                label: "Reviews Count",
                common: false,
                data: "reviews",
                max: 100,
                param: "rev"
            },
            {
                label: "Compatibility Notes Count",
                common: false,
                data: "compatibility_notes",
                max: 100,
                param: "cnc"
            },
            {
                label: "Install Order Notes Count",
                common: false,
                data: "install_order_notes",
                max: 100,
                param: "ioc"
            },
            {
                label: "Load Order Notes Count",
                common: false,
                data: "load_order_notes",
                max: 100,
                param: "loc"
            },
            {
                label: "Corrections Count",
                common: false,
                data: "corrections",
                max: 50,
                param: "crc"
            },
            {
                label: "Mod Lists Count",
                common: false,
                data: "mod_lists",
                max: 50,
                param: "mlc"
            }
        ];
    };

    this.userDateFilters = function() {
        return [{
                label: "Date Joined",
                data: "joined",
                type: "Date",
                param: "dj"
            },
            {
                label: "Date Last Seen",
                data: "last_seen",
                type: "Date",
                param: "ls"
            }
        ];
    };

    this.userFilters = function() {
        return Array.prototype.concat(
            service.userStatisticFilters(),
            service.userDateFilters()
        );
    };

    this.contributionDateFilters = function() {
        return [{
                label: "Date Submitted",
                data: "submitted",
                type: "Date",
                param: "ds"
            },
            {
                label: "Date Edited",
                data: "edited",
                type: "Date",
                param: "de"
            }
        ];
    };

    this.commentStatisticFilters = function() {
        return [
            {
                label: "Replies Count",
                common: true,
                data: "replies",
                max: 100,
                param: "rc"
            }
        ]
    };

    this.commentFilters = function() {
        return Array.prototype.concat(
            service.contributionDateFilters(),
            service.commentStatisticFilters()
        );
    };

    this.reviewStatisticFilters = function() {
        return [
            {
                label: "Overall Rating",
                common: true,
                data: "overall_rating",
                max: 100,
                param: "ovr"
            },
            {
                label: "Reputatation",
                common: true,
                data: "reputation",
                min: -20,
                max: 40,
                param: "rep"
            },
            {
                label: "Helpful Count",
                common: true,
                data: "helpful_count",
                min: 0,
                max: 100,
                param: "hc"
            },
            {
                label: "Not Helpful Count",
                common: true,
                data: "not_helpful_count",
                min: 0,
                max: 100,
                param: "nhc"
            },
            {
                label: "Rating Sections Count",
                common: false,
                data: "ratings_count",
                min: 0,
                max: 10,
                param: "rsc"
            },
            {
                label: "Corrections Count",
                common: false,
                data: "corrections_count",
                min: 0,
                max: 100,
                param: "crc"
            },
            {
                label: "History Entries Count",
                common: false,
                data: "history_entries_count",
                min: 0,
                max: 100,
                param: "hec"
            }
        ]
    };

    this.reviewFilters = function() {
        return Array.prototype.concat(
            service.contributionDateFilters(),
            service.reviewStatisticFilters()
        );
    };
});
