app.factory("filtersFactory", function() {
    var factory = this;

    this.modGeneralFilters = function() {
        return [
            {
                data: "search",
                param: "q"
            },
            {
                data: "author",
                param: "a"
            },
            {
                data: "tags",
                param: "t",
                type: "List"
            },
            {
                data: "categories",
                param: "c",
                type: "List"
            },
            {
                data: "sources.nexus",
                param: "nm",
                type: "Boolean",
                default: true
            },
            {
                data: "sources.lab",
                param: "ll",
                type: "Boolean",
                default: true
            },
            {
                data: "sources.workshop",
                param: "sw",
                type: "Boolean",
                default: true
            },
            {
                data: "sources.other",
                param: "ot",
                type: "Boolean",
                default: true
            }
        ]
    };

    this.modStatisticFilters = function() {
        return [
            {
                label: "Endorsements",
                common: true,
                sites: { nexus: true },
                data: "endorsements",
                type: "Range",
                max: 500000,
                param: "end"
            },
            {
                label: "Subscribers",
                common: true,
                sites: { workshop: true },
                data: "subscribers",
                type: "Range",
                max: 1250000,
                param: "su"
            },
            {
                label: "Unique Downloads",
                common: true,
                sites: { nexus: true },
                data: "unique_downloads",
                type: "Range",
                max: 10000000,
                param: "ud"
            },
            {
                label: "Favorites",
                common: true,
                sites: { workshop: true, lab: true },
                data: "favorites",
                type: "Range",
                max: 20000,
                param: "fa"
            },
            {
                label: "Downloads",
                common: true,
                sites: { nexus: true, lab: true },
                data: "downloads",
                type: "Range",
                max: 50000000,
                param: "dl"
            },
            {
                label: "Views",
                common: true,
                sites: { nexus: true, workshop: true, lab: true },
                data: "views",
                type: "Range",
                max: 50000000,
                param: "vw"
            },
            {
                label: "Posts Count",
                common: false,
                sites: { nexus: true, workshop: true },
                data: "posts",
                type: "Range",
                max: 500000,
                param: "pc"
            },
            {
                label: "Images Count",
                common: false,
                sites: { nexus: true, workshop: true },
                data: "images",
                type: "Range",
                max: 200,
                param: "ic"
            },
            {
                label: "Videos Count",
                common: false,
                sites: { nexus: true, workshop: true },
                data: "videos",
                type: "Range",
                max: 50,
                param: "vc"
            },
            {
                label: "Files Count",
                common: false,
                sites: { nexus: true },
                data: "files",
                type: "Range",
                max: 200,
                param: "fc"
            },
            /*{ TODO: Unimplemented on backend
                label: "Bugs Count",
                common: false,
                sites: {nexus: true},
                data: "bugs",
                type: "Range",
                max: 200
            },*/
            {
                label: "Discussions Count",
                common: false,
                sites: { /*nexus: true, TODO: Unimplemented on backend */ workshop: true },
                data: "discussions",
                type: "Range",
                max: 50,
                param: "dc"
            },
            {
                label: "Articles Count",
                common: false,
                sites: { nexus: true },
                data: "articles",
                type: "Range",
                max: 50,
                param: "ac"
            }
        ];
    };

    this.modPickerFilters = function() {
        return [
            {
                label: "Reputation",
                common: true,
                data: "reputation",
                type: "Range",
                max: 450,
                param: "rep"
            },
            {
                label: "Average Rating",
                common: true,
                data: "rating",
                type: "Range",
                max: 100,
                param: "avg"
            },
            {
                label: "Reviews Count",
                common: true,
                data: "reviews",
                type: "Range",
                max: 200,
                param: "rev"
            },
            {
                label: "Number of Stars",
                common: false,
                data: "stars",
                type: "Range",
                max: 1000,
                param: "str"
            },
            {
                label: "Compatibility Notes Count",
                common: false,
                data: "compatibility_notes",
                type: "Range",
                max: 100,
                param: "cnc"
            },
            {
                label: "Install Order Notes Count",
                common: false,
                data: "install_order_notes",
                type: "Range",
                max: 100,
                param: "ioc"
            },
            {
                label: "Load Order Notes Count",
                common: false,
                data: "load_order_notes",
                type: "Range",
                max: 100,
                param: "loc"
            }
        ];
    };

    this.modDateFilters = function() {
        return [
            {
                label: "Date Updated",
                data: "updated",
                type: "Range",
                subtype: "Date",
                param: "du"
            },
            {
                label: "Date Released",
                data: "released",
                type: "Range",
                subtype: "Date",
                param: "dr"
            }
        ];
    };

    this.modFilters = function() {
        return Array.prototype.concat(
            factory.modGeneralFilters(),
            factory.modStatisticFilters(),
            factory.modPickerFilters(),
            factory.modDateFilters()
        );
    };

    this.userGeneralFilters = function() {
        return [
            {
                data: "search",
                param: "q"
            },
            {
                data: "linked",
                param: "l"
            },
            {
                data: "roles.admin",
                param: "adm",
                type: "Boolean",
                default: true
            },
            {
                data: "roles.moderator",
                param: "mod",
                type: "Boolean",
                default: true
            },
            {
                data: "roles.author",
                param: "ma",
                type: "Boolean",
                default: true
            },
            {
                data: "roles.user",
                param: "usr",
                type: "Boolean",
                default: true
            }
        ]
    };

    this.userStatisticFilters = function() {
        return [
            {
                label: "Reputation",
                common: true,
                data: "reputation",
                type: "Range",
                max: 5000,
                param: "rep"
            },
            {
                label: "Authored Mods",
                common: true,
                data: "authored_mods",
                type: "Range",
                max: 100,
                param: "mods"
            },
            {
                label: "Comments Count",
                common: true,
                data: "comments",
                type: "Range",
                max: 1000,
                param: "cmc"
            },
            {
                label: "Reviews Count",
                common: false,
                data: "reviews",
                type: "Range",
                max: 100,
                param: "rev"
            },
            {
                label: "Compatibility Notes Count",
                common: false,
                data: "compatibility_notes",
                type: "Range",
                max: 100,
                param: "cnc"
            },
            {
                label: "Install Order Notes Count",
                common: false,
                data: "install_order_notes",
                type: "Range",
                max: 100,
                param: "ioc"
            },
            {
                label: "Load Order Notes Count",
                common: false,
                data: "load_order_notes",
                type: "Range",
                max: 100,
                param: "loc"
            },
            {
                label: "Corrections Count",
                common: false,
                data: "corrections",
                type: "Range",
                max: 50,
                param: "crc"
            },
            {
                label: "Mod Lists Count",
                common: false,
                data: "mod_lists",
                type: "Range",
                max: 50,
                param: "mlc"
            }
        ];
    };

    this.userDateFilters = function() {
        return [
            {
                label: "Date Joined",
                data: "joined",
                type: "Range",
                subtype: "Date",
                param: "dj"
            },
            {
                label: "Date Last Seen",
                data: "last_seen",
                type: "Range",
                subtype: "Date",
                param: "ls"
            }
        ];
    };

    this.userFilters = function() {
        return Array.prototype.concat(
            factory.userGeneralFilters(),
            factory.userStatisticFilters(),
            factory.userDateFilters()
        );
    };

    this.contributionDateFilters = function() {
        return [
            {
                label: "Date Submitted",
                data: "submitted",
                type: "Range",
                subtype: "Date",
                param: "ds"
            },
            {
                label: "Date Edited",
                data: "edited",
                type: "Range",
                subtype: "Date",
                param: "de"
            }
        ];
    };

    this.contributionStandingFilters = function() {
        return [
            {
                data: "standing.good",
                type: "Boolean",
                default: true,
                param: "stg"
            },
            {
                data: "standing.unknown",
                type: "Boolean",
                default: true,
                param: "stu"
            },
            {
                data: "standing.bad",
                type: "Boolean",
                default: true,
                param: "stb"
            }
        ];
    };

    this.commentGeneralFilters = function() {
        return [
            {
                data: "search",
                param: "q"
            },
            {
                data: "submitter",
                param: "s"
            },
            {
                data: "is_child",
                param: "c",
                type: "Boolean",
                default: true
            },
            {
                data: "commentable.ModList",
                param: "ml",
                type: "Boolean",
                default: true
            },
            {
                data: "commentable.Correction",
                param: "cor",
                type: "Boolean",
                default: true
            },
            {
                data: "commentable.User",
                param: "usr",
                type: "Boolean",
                default: true
            }
        ]
    };

    this.commentStatisticFilters = function() {
        return [
            {
                label: "Replies Count",
                common: true,
                data: "replies",
                type: "Range",
                max: 100,
                param: "rc"
            }
        ]
    };

    this.commentFilters = function() {
        return Array.prototype.concat(
            factory.commentGeneralFilters(),
            factory.contributionDateFilters(),
            factory.commentStatisticFilters()
        );
    };

    this.reviewGeneralFilters = function() {
        return [
            {
                data: "search",
                param: "q"
            },
            {
                data: "submitter",
                param: "s"
            },
            {
                data: "editor",
                param: "e"
            }
        ]
    };

    this.reviewStatisticFilters = function() {
        return [
            {
                label: "Overall Rating",
                common: true,
                data: "overall_rating",
                type: "Range",
                max: 100,
                param: "ovr"
            },
            {
                label: "Reputatation",
                common: true,
                data: "reputation",
                type: "Range",
                min: -40,
                max: 40,
                param: "rep"
            },
            {
                label: "Helpful Count",
                common: true,
                data: "helpful_count",
                type: "Range",
                max: 100,
                param: "hc"
            },
            {
                label: "Not Helpful Count",
                common: true,
                data: "not_helpful_count",
                type: "Range",
                max: 100,
                param: "nhc"
            },
            {
                label: "Rating Sections Count",
                common: false,
                data: "ratings_count",
                type: "Range",
                max: 10,
                param: "rsc"
            },
            {
                label: "Corrections Count",
                common: false,
                data: "corrections_count",
                type: "Range",
                max: 100,
                param: "crc"
            },
            {
                label: "History Entries Count",
                common: false,
                data: "history_entries_count",
                type: "Range",
                max: 100,
                param: "hec"
            }
        ]
    };

    this.reviewFilters = function() {
        return Array.prototype.concat(
            factory.reviewGeneralFilters(),
            factory.contributionDateFilters(),
            factory.reviewStatisticFilters()
        );
    };
});
