app.service("filtersFactory", function() {
    var factory = this;

    /* shared filter prototypes */
    this.searchFilter = {
        data: "search",
        param: "q"
    };
    this.submitterFilter = {
        data: "submitter",
        param: "s"
    };
    this.editorFilter = {
        data: "editor",
        param: "e"
    };
    this.contributionHelpfulnessFilter = {
        label: "Helpfulness",
        common: true,
        data: "helpfulness",
        type: "Range",
        min: -40,
        max: 40,
        param: "h"
    };
    this.submitterReputationFilter = {
        label: "Submitter Reputation",
        common: true,
        data: "reputation",
        type: "Range",
        min: 0,
        max: 1280,
        param: "rep"
    };
    this.helpfulFilter = {
        label: "Helpful Count",
        common: true,
        data: "helpful_count",
        type: "Range",
        max: 100,
        param: "hc"
    };
    this.notHelpfulFilter = {
        label: "Not Helpful Count",
        common: true,
        data: "not_helpful_count",
        type: "Range",
        max: 100,
        param: "nhc"
    };
    this.correctionsFilter = {
        label: "Corrections Count",
        common: false,
        data: "corrections_count",
        type: "Range",
        max: 100,
        param: "crc"
    };
    this.historyEntriesFilter = {
        label: "History Entries Count",
        common: false,
        data: "history_entries_count",
        type: "Range",
        max: 100,
        param: "hec"
    };

    this.userDateSlider = function(options) {
        options.type = "Range";
        options.subtype = "Date";
        options.start = new Date(2016,0,1);
        return options;
    };

    this.modDateSlider = function(options) {
        options.type = "Range";
        options.subtype = "Date";
        options.start = new Date(2011,10,11);
        return options;
    };

    /* mods index filters */
    this.modGeneralFilters = function() {
        return [
            factory.searchFilter,
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
                type: "List",
                subtype: "Integer"
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
                param: "poc"
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
                label: "File Size",
                common: false,
                sites: { lab: true, workshop: true },
                data: "file_size",
                type: "Range",
                subtype: "Bytes",
                max: 4294967296 // 4GB
             },*/
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
                label: "Mod Lists Count",
                common: false,
                data: "mod_lists",
                type: "Range",
                max: 1000,
                param: "mlc"
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
                label: "Asset Files Count",
                common: false,
                data: "asset_files",
                type: "Range",
                max: 50000,
                param: "afc"
            },
            {
                label: "Plugins Count",
                common: false,
                data: "plugins",
                type: "Range",
                max: 50,
                param: "pc"
            },
            {
                label: "Required Mods Count",
                common: false,
                data: "required_mods",
                type: "Range",
                max: 50,
                param: "rmc"
            },
            {
                label: "Required By Count",
                common: false,
                data: "required_by",
                type: "Range",
                max: 1000,
                param: "rbc"
            },
            {
                label: "Tags Count",
                common: false,
                data: "tags_count",
                type: "Range",
                max: 10,
                param: "tc"
            }
        ];
    };

    this.modDateFilters = function() {
        return [
            factory.modDateSlider({
                label: "Date Updated",
                data: "updated",
                param: "du"
            }),
            factory.modDateSlider({
                label: "Date Released",
                data: "released",
                param: "dr"
            })
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

    /* users index filters */
    this.userGeneralFilters = function() {
        return [
            factory.searchFilter,
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
            },
            {
                data: "roles.restricted",
                param: "rsr",
                type: "Boolean",
                default: false
            },
            {
                data: "roles.banned",
                param: "bnd",
                type: "Boolean",
                default: false
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
                label: "Mod Lists Count",
                common: true,
                data: "mod_lists",
                type: "Range",
                max: 50,
                param: "mlc"
            },
            {
                label: "Profile Comments Count",
                common: false,
                data: "comments",
                type: "Range",
                max: 200,
                param: "pcc"
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
                label: "Comments Count",
                common: false,
                data: "submitted_comments",
                type: "Range",
                max: 200,
                param: "cmc"
            }
        ];
    };

    this.userDateFilters = function() {
        return [
            factory.userDateSlider({
                label: "Date Joined",
                data: "joined",
                param: "dj"
            }),
            factory.userDateSlider({
                label: "Date Last Seen",
                data: "last_seen",
                param: "ls"
            })
        ];
    };

    this.userFilters = function() {
        return Array.prototype.concat(
            factory.userGeneralFilters(),
            factory.userStatisticFilters(),
            factory.userDateFilters()
        );
    };

    /* contribution index filters */
    this.contributionGeneralFilters = function() {
        return [
            factory.searchFilter,
            factory.submitterFilter
            //factory.editorFilter
        ]
    };
    
    this.contributionDateFilters = function() {
        return [
            factory.userDateSlider({
                label: "Date Submitted",
                data: "submitted",
                param: "ds"
            }),
            factory.userDateSlider({
                label: "Date Edited",
                data: "edited",
                param: "de"
            })
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

    /* comments index filters */
    this.commentGeneralFilters = function() {
        return [
            factory.searchFilter,
            factory.submitterFilter,
            {
                data: "include_replies",
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
            },
            {
                data: "commentable.Article",
                param: "art",
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

    /* reviews index filters */
    this.reviewStatisticFilters = function() {
        return [
            factory.contributionHelpfulnessFilter,
            factory.submitterReputationFilter,
            factory.helpfulFilter,
            factory.notHelpfulFilter,
            {
                label: "Overall Rating",
                common: false,
                data: "overall_rating",
                type: "Range",
                max: 100,
                param: "ovr"
            },
            {
                label: "Rating Sections Count",
                common: false,
                data: "ratings_count",
                type: "Range",
                max: 10,
                param: "rsc"
            }
        ]
    };

    this.reviewFilters = function() {
        return Array.prototype.concat(
            factory.contributionGeneralFilters(),
            factory.contributionDateFilters(),
            factory.reviewStatisticFilters()
        );
    };

    /* note index filters */
    this.noteStatisticFilters = function() {
        return [
            factory.contributionHelpfulnessFilter,
            factory.submitterReputationFilter,
            factory.helpfulFilter,
            factory.notHelpfulFilter,
            factory.correctionsFilter,
            factory.historyEntriesFilter
        ]
    };

    /* compatibility notes index filters */
    this.compatibilityNoteTypeFilters = function() {
        return [
            {
                data: "status.incompatible",
                param: "inc",
                type: "Boolean",
                default: true
            },
            {
                data: "status.partially_compatible",
                param: "pc",
                type: "Boolean",
                default: true
            },
            {
                data: "status.compatibility_mod",
                param: "cm",
                type: "Boolean",
                default: true
            },
            {
                data: "status.compatibility_option",
                param: "co",
                type: "Boolean",
                default: true
            },
            {
                data: "status.make_custom_patch",
                param: "mcp",
                type: "Boolean",
                default: true
            }
        ]
    };

    this.compatibilityNoteFilters = function() {
        return Array.prototype.concat(
            factory.contributionGeneralFilters(),
            factory.compatibilityNoteTypeFilters(),
            factory.contributionStandingFilters(),
            factory.contributionDateFilters(),
            factory.noteStatisticFilters()
        );
    };

    /* install order notes index filters */
    this.installOrderNoteFilters = function() {
        return Array.prototype.concat(
            factory.contributionGeneralFilters(),
            factory.contributionStandingFilters(),
            factory.contributionDateFilters(),
            factory.noteStatisticFilters()
        );
    };

    /* load order notes index filters */
    this.loadOrderNoteGeneralFilters = function() {
        return [
                factory.searchFilter,
                factory.submitterFilter,
                //factory.editorFilter,
                {
                    data: "plugin_filename",
                    param: "p"
                }
        ];
    };

    this.loadOrderNoteFilters = function() {
        return Array.prototype.concat(
            factory.loadOrderNoteGeneralFilters(),
            factory.contributionStandingFilters(),
            factory.contributionDateFilters(),
            factory.noteStatisticFilters()
        );
    };

    /* corrections index filters */
    this.correctionTypeFilters = function() {
        return [
            {
                data: "correctable.Mod",
                param: "tmo",
                type: "Boolean",
                default: true
            },
            {
                data: "correctable.CompatibilityNote",
                param: "tcn",
                type: "Boolean",
                default: true
            },
            {
                data: "correctable.InstallOrderNote",
                param: "tio",
                type: "Boolean",
                default: true
            },
            {
                data: "correctable.LoadOrderNote",
                param: "tlo",
                type: "Boolean",
                default: true
            }
        ];
    };

    this.correctionStatusFilters = function() {
        return [
            {
                data: "status.open",
                param: "sto",
                type: "Boolean",
                default: true
            },
            {
                data: "status.passed",
                param: "stp",
                type: "Boolean",
                default: true
            },
            {
                data: "status.failed",
                param: "stf",
                type: "Boolean",
                default: true
            },
            {
                data: "status.closed",
                param: "stc",
                type: "Boolean",
                default: true
            }
        ];
    };

    this.correctionModStatusFilters = function() {
        return [
            {
                data: "mod_status.nil",
                param: "msn",
                type: "Boolean",
                default: true
            },
            {
                data: "mod_status.good",
                param: "msg",
                type: "Boolean",
                default: true
            },
            {
                data: "mod_status.outdated",
                param: "mso",
                type: "Boolean",
                default: true
            },
            {
                data: "mod_status.unstable",
                param: "msu",
                type: "Boolean",
                default: true
            }
        ];
    };

    this.correctionStatisticFilters = function() {
        return [
            factory.submitterReputationFilter,
            {
                label: "Agree Count",
                common: true,
                data: "agree_count",
                type: "Range",
                max: 100,
                param: "ac"
            },
            {
                label: "Disagree Count",
                common: true,
                data: "disagree_count",
                type: "Range",
                max: 100,
                param: "dc"
            },
            {
                label: "Comments Count",
                common: true,
                data: "comments",
                type: "Range",
                max: 100,
                param: "cmc"
            }
        ];
    };

    this.correctionFilters = function() {
        return Array.prototype.concat(
            factory.contributionGeneralFilters(),
            factory.correctionTypeFilters(),
            factory.correctionStatusFilters(),
            factory.correctionModStatusFilters(),
            factory.contributionDateFilters(),
            factory.correctionStatisticFilters()
        )
    };

    this.articleSearchFilters = function() {
        return [
            factory.searchFilter,
            {
                data: "text",
                param: "t"
            },
            factory.submitterFilter
        ];
    };

    this.articleDateFilters = function() {
        return [
            factory.userDateSlider({
                label: "Created",
                data: "submitted",
                param: "dc"
            })
        ];
    };

    // TODO: Article Game Filters
    this.articleFilters = function() {
        return Array.prototype.concat(
            factory.articleSearchFilters(),
            factory.articleDateFilters()
        );
    };

    this.modListGeneralFilters = function() {
        return [
            factory.searchFilter,
            {
                data: "description",
                param: "t"
            },
            factory.submitterFilter,
            {
                data: "tags",
                param: "t",
                type: "List"
            },
            {
                data: "status.complete",
                param: "sco",
                type: "Boolean",
                default: true
            },
            {
                data: "status.testing",
                param: "ste",
                type: "Boolean",
                default: true
            },
            {
                data: "status.under_construction",
                param: "sun",
                type: "Boolean",
                default: true
            },
            {
                data: "kind.normal",
                param: "cln",
                type: "Boolean",
                default: true
            },
            {
                data: "kind.collection",
                param: "clc",
                type: "Boolean",
                default: true
            }
        ];
    };

    this.modListDateFilters = function() {
        return [
            factory.userDateSlider({
                label: "Date Started",
                data: "submitted",
                param: "ds"
            }),
            factory.userDateSlider({
                label: "Date Updated",
                data: "updated",
                param: "du"
            }),
            factory.userDateSlider({
                label: "Date Completed",
                data: "completed",
                param: "dcom"
            })
        ];
    };

    this.modListStatisticFilters = function() {
        return [
            {
                label: "Tools Count",
                common: true,
                data: "tools",
                type: "Range",
                max: 100,
                param: "tc"
            },
            {
                label: "Mods Count",
                common: true,
                data: "mods",
                type: "Range",
                max: 2000,
                param: "mc"
            },
            {
                label: "Plugins Count",
                common: true,
                data: "plugins",
                type: "Range",
                max: 2000,
                param: "pc"
            },
            {
                label: "Config Files Count",
                common: true,
                data: "config_files",
                type: "Range",
                max: 100,
                param: "cfc"
            },
            {
                label: "Ignored Notes Count",
                common: true,
                data: "ignored_notes",
                type: "Range",
                max: 2000,
                param: "inc"
            },
            {
                label: "Stars Count",
                common: true,
                data: "stars",
                type: "Range",
                max: 10000,
                param: "sc"
            },
            {
                label: "Custom Tools Count",
                common: false,
                data: "custom_tools",
                type: "Range",
                max: 100,
                param: "ctc"
            },
            {
                label: "Custom Mods Count",
                common: false,
                data: "custom_mods",
                type: "Range",
                max: 200,
                param: "cmc"
            },
            {
                label: "Custom Plugins Count",
                common: false,
                data: "custom_plugins",
                type: "Range",
                max: 200,
                param: "cpc"
            },
            {
                label: "Custom Config Files Count",
                common: false,
                data: "custom_config_files",
                type: "Range",
                max: 100,
                param: "ccfc"
            },
            {
                label: "Compatibility Notes Count",
                common: false,
                data: "compatibility_notes",
                type: "Range",
                max: 1000,
                param: "cnc"
            },
            {
                label: "Install Order Notes Count",
                common: false,
                data: "install_order_notes",
                type: "Range",
                max: 1000,
                param: "ioc"
            },
            {
                label: "Load Order Notes Count",
                common: false,
                data: "load_order_notes",
                type: "Range",
                max: 1000,
                param: "loc"
            },
            {
                label: "BSA Files Count",
                common: false,
                data: "bsa_files",
                type: "Range",
                max: 1000,
                param: "bfc"
            },
            {
                label: "Asset Files Count",
                common: false,
                data: "asset_files",
                type: "Range",
                max: 1000000,
                param: "afc"
            },
            {
                label: "Records Count",
                common: false,
                data: "records",
                type: "Range",
                max: 20000000,
                param: "rec"
            },
            {
                label: "Override Records Count",
                common: false,
                data: "override_records",
                type: "Range",
                max: 1000000,
                param: "orc"
            },
            {
                label: "Plugin Errors Count",
                common: false,
                data: "plugin_errors",
                type: "Range",
                max: 2000,
                param: "pec"
            },
            {
                label: "Comments Count",
                common: false,
                data: "comments",
                type: "Range",
                max: 500,
                param: "cc"
            }
        ];
    };

    this.modListFilters = function() {
        return Array.prototype.concat(
            factory.modListGeneralFilters(),
            factory.modListDateFilters(),
            factory.modListStatisticFilters()
        )
    };

    this.pluginSearchFilters = function() {
        return [
            factory.searchFilter,
            {
                data: "author",
                param: "a"
            },
            {
                data: "description",
                param: "d"
            }
        ]
    };

    this.pluginStatisticFilters = function() {
        return [
            {
                label: "File Size",
                common: true,
                data: "file_size",
                type: "Range",
                subtype: "Bytes",
                max: 536870912, // 512MB
                param: "fsz"
            },
            {
                label: "Records Count",
                common: true,
                data: "records",
                type: "Range",
                max: 2000000,
                param: "rc"
            },
            {
                label: "Override Records Count",
                common: true,
                data: "overrides",
                type: "Range",
                max: 100000,
                param: "oc"
            },
            {
                label: "Errors Count",
                common: true,
                data: "errors",
                type: "Range",
                max: 5000,
                param: "ec"
            },
            {
                label: "Mod Lists Count",
                common: true,
                data: "mod_lists",
                type: "Range",
                max: 1000,
                param: "mlc"
            },
            {
                label: "Load Order Notes Count",
                common: true,
                data: "load_order_notes",
                type: "Range",
                max: 100,
                param: "loc"
            }
        ]
    };

    this.pluginFilters = function() {
        return Array.prototype.concat(
            factory.pluginSearchFilters(),
            factory.pluginStatisticFilters()
        )
    };

    this.reportSearchFilters = function() {
        return [
            factory.submitterFilter
        ];
    };

    this.reportGeneralFilters = function() {
        return [
            {
                data: "reportable.Review",
                param: "rr",
                type: "Boolean",
                default: true
            },
            {
                data: "reportable.CompatibilityNote",
                param: "rcn",
                type: "Boolean",
                default: true
            },
            {
                data: "reportable.InstallOrderNote",
                param: "rin",
                type: "Boolean",
                default: true
            },
            {
                data: "reportable.LoadOrderNote",
                param: "rln",
                type: "Boolean",
                default: true
            },
            {
                data: "reportable.Comment",
                param: "rco",
                type: "Boolean",
                default: true
            },
            {
                data: "reportable.Correction",
                param: "rcr",
                type: "Boolean",
                default: true
            },
            {
                data: "reportable.Mod",
                param: "rm",
                type: "Boolean",
                default: true
            },
            {
                data: "reportable.ModList",
                param: "rml",
                type: "Boolean",
                default: true
            },
            {
                data: "reportable.Tag",
                param: "rt",
                type: "Boolean",
                default: true
            },
            {
                data: "reportable.User",
                param: "ru",
                type: "Boolean",
                default: true
            },
            {
                data: "reason.be_respectful",
                param: "sbr",
                type: "Boolean",
                default: true
            },
            {
                data: "reason.be_trustworthy",
                param: "sbt",
                type: "Boolean",
                default: true
            },
            {
                data: "reason.be_constructive",
                param: "sbc",
                type: "Boolean",
                default: true
            },
            {
                data: "reason.spam",
                param: "sns",
                type: "Boolean",
                default: true
            },
            {
                data: "reason.piracy",
                param: "snp",
                type: "Boolean",
                default: true
            },
            {
                data: "reason.adult_content",
                param: "sac",
                type: "Boolean",
                default: true
            },
            {
                data: "reason.other",
                param: "sot",
                type: "Boolean",
                default: true
            }
        ]
    };

    this.reportDateFilters = function() {
        return [
            factory.userDateSlider({
                label: "Created",
                data: "submitted",
                param: "dc"
            })
        ];
    };

    this.reportStatisticFilters = function() {
        return [
            {
                label: "Reports Count",
                common: true,
                data: "reports_count",
                type: "Range",
                max: 50,
                param: "rc"
            }
        ]
    };

    this.reportFilters = function() {
        return Array.prototype.concat(
            factory.reportSearchFilters(),
            factory.reportGeneralFilters(),
            factory.reportDateFilters(),
            factory.reportStatisticFilters()
        );
    };

    return factory;
});
