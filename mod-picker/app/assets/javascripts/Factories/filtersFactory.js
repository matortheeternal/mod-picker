app.service("filtersFactory", function() {
    var factory = this;

    /* shared filter prototypes */
    this.searchFilter = function(terms) {
        return {
            data: "search",
            param: "q",
            terms: terms
        };
    };

    this.searchTerm = function(name, matchTarget, noThe) {
        return {
            name: name,
            description: "Matches against " + (noThe ? "" : "the ") + matchTarget + "."
        }
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

    this.enumFilters = function(enumName, values, numEnabled, type) {
        var maxIndex = numEnabled || 100;
        return Object.keys(values).map(function(key, index) {
            var obj = {
                data: enumName + "." + key,
                param: values[key],
                type: type || "Boolean"
            };
            if (!type) {
                obj.default = index < maxIndex;
            }
            return obj;
        });
    };

    this.modSearchFilter = factory.searchFilter([
        factory.searchTerm("name", "name of the mod"),
        factory.searchTerm("aliases", "mod's aliases"),
        factory.searchTerm("description", "mod's description"),
        factory.searchTerm("author", "mod's authors and uploaders"),
        factory.searchTerm("mp_author", "mod's authors on Mod Picker")
    ]);

    this.modSourceFilters = factory.enumFilters("sources", {
        nexus: "nm",
        lab: "ll",
        workshop: "sw",
        other: "ot"
    });

    this.pageFilter = {
        data: "page",
        param: "page",
        default: 1
    };
    this.tagsFilter = {
        data: "tags",
        param: "t",
        type: "List"
    };
    this.excludedTagsFilter = {
        data: "excluded_tags",
        param: "x",
        type: "List"
    };
    this.categoriesFilter = {
        data: "categories",
        param: "c",
        type: "List",
        subtype: "Integer"
    };
    this.showAdultFilter = {
        data: "adult.1",
        param: "adc",
        type: "Boolean",
        default: false
    };
    this.showNonAdultFilter = {
        data: "adult.0",
        param: "nac",
        type: "Boolean",
        default: true
    };
    this.hiddenFilter = {
        data: "hidden.1",
        param: "hdn",
        type: "Boolean",
        default: true
    };
    this.unhiddenFilter = {
        data: "hidden.0",
        param: "unh",
        type: "Boolean",
        default: true
    };
    this.approvedFilter = {
        data: "approved.1",
        param: "apr",
        type: "Boolean",
        default: true
    };
    this.unapprovedFilter = {
        data: "approved.0",
        param: "una",
        type: "Boolean",
        default: true
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

    /* mods index filters */
    this.modGeneralFilters = function() {
        return [
            factory.modSearchFilter,
            factory.pageFilter,
            factory.tagsFilter,
            factory.excludedTagsFilter,
            factory.categoriesFilter,
            factory.showAdultFilter,
            factory.showNonAdultFilter,
            factory.hiddenFilter,
            factory.unhiddenFilter,
            factory.approvedFilter,
            factory.unapprovedFilter
        ].concat(
            factory.modSourceFilters,
            factory.enumFilters("terms", {
                credit: "tcr",
                commercial: "tco",
                redistribution: "tre",
                modification: "tmo",
                private_use: "tpu",
                include: "tin"
            }, 0, "Integer")
        )
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
                label: "Mod Options Count",
                common: false,
                data: "mod_options",
                type: "Range",
                max: 600,
                param: "moc"
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
                max: 100,
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
            }),
            factory.modDateSlider({
                label: "Date Submitted",
                data: "submitted",
                param: "ds"
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

    this.modTagGroupFilter = function() {
        return [
            {
                label: "Tag Groups",
                data: "tag_groups",
                param: "tg",
                type: "TagGroup"
            }
        ];
    };

    this.modCategoryGeneralFilters = function() {
        return [
            factory.pageFilter,
            factory.modSearchFilter,
            factory.categoriesFilter,
            factory.showAdultFilter,
            factory.showNonAdultFilter,
            factory.hiddenFilter,
            factory.unhiddenFilter,
            factory.approvedFilter,
            factory.unapprovedFilter
        ].concat(
            factory.modSourceFilters
        );
    };

    this.modCategoryFilters = function() {
        return Array.prototype.concat(
            factory.modCategoryGeneralFilters(),
            factory.modDateFilters(),
            factory.modTagGroupFilter()
        );
    };

    /* users index filters */
    this.userGeneralFilters = function() {
        return [
            factory.searchFilter([
                factory.searchTerm("username", "user's username"),
                factory.searchTerm("linked", "user's linked account usernames")
            ]),
            factory.pageFilter
        ].concat(
            factory.enumFilters("roles", {
                admin: "adm",
                moderator: "mod",
                helper: "hlp",
                author: "ma",
                user: "usr",
                restricted: "rsr",
                banned: "bnd"
            }, 5)
        )
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

    this.contributionSearchFilter = function(includeEditor) {
        var terms = [
            factory.searchTerm("text", "contribution text"),
            factory.searchTerm("submitter", "contribution submitter's username")
        ];
        if (includeEditor) {
            terms.push(factory.searchTerm("editor", "contribution editor usernames", true));
        }
        return [factory.searchFilter(terms)];
    };

    /* contribution index filters */
    this.contributionGeneralFilters = function() {
        return [
            factory.pageFilter,
            factory.showAdultFilter,
            factory.showNonAdultFilter,
            factory.hiddenFilter,
            factory.unhiddenFilter,
            factory.approvedFilter,
            factory.unapprovedFilter
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
        return factory.enumFilters("standing", {
            good: "stg",
            unknown: "stu",
            bad: "stb"
        });
    };

    /* comments index filters */
    this.commentGeneralFilters = function() {
        return [
            factory.searchFilter([
                factory.searchTerm("text", "comment text"),
                factory.searchTerm("text", "comment submitter's username")
            ]),
            factory.pageFilter,
            factory.showAdultFilter,
            factory.showNonAdultFilter,
            factory.hiddenFilter,
            factory.unhiddenFilter,
            {
                data: "include_replies",
                param: "c",
                type: "Boolean",
                default: true
            }
        ].concat(
            factory.enumFilters("commentable", {
                "ModList": "ml",
                "Correction": "cor",
                "User": "usr",
                "Article": "art",
                "HelpPage": "hlp"
            })
        )
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
            factory.contributionSearchFilter(),
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
        return factory.enumFilters("status", {
            incompatible: "inc",
            partially_incompatible: "pc",
            compatibility_mod: "cm",
            compatibility_option: "co",
            make_custom_patch: "mcp"
        });
    };

    this.compatibilityNoteFilters = function() {
        return Array.prototype.concat(
            factory.contributionSearchFilter(true),
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
            factory.contributionSearchFilter(true),
            factory.contributionGeneralFilters(),
            factory.contributionStandingFilters(),
            factory.contributionDateFilters(),
            factory.noteStatisticFilters()
        );
    };

    /* load order notes index filters */
    this.loadOrderNoteGeneralFilters = function() {
        return [
            factory.pageFilter,
            {
                data: "plugin_filename",
                param: "p"
            },
            factory.showAdultFilter,
            factory.showNonAdultFilter,
            factory.hiddenFilter,
            factory.unhiddenFilter,
            factory.approvedFilter,
            factory.unapprovedFilter
        ];
    };

    this.loadOrderNoteFilters = function() {
        return Array.prototype.concat(
            factory.contributionSearchFilter(true),
            factory.loadOrderNoteGeneralFilters(),
            factory.contributionStandingFilters(),
            factory.contributionDateFilters(),
            factory.noteStatisticFilters()
        );
    };

    /* related mod note index filters */
    this.relatedModNoteTypeFilters = function() {
        return  factory.enumFilters("status", {
            alternative_mod: "alt",
            recommended_mod: "rec"
        });
    };

    this.relatedModNoteStatisticFilters = function() {
        return [
            factory.contributionHelpfulnessFilter,
            factory.submitterReputationFilter,
            factory.helpfulFilter,
            factory.notHelpfulFilter
        ]
    };

    this.relatedModNoteFilters = function() {
        return Array.prototype.concat(
            factory.contributionSearchFilter(),
            factory.contributionGeneralFilters(),
            factory.relatedModNoteTypeFilters(),
            factory.contributionDateFilters(),
            factory.noteStatisticFilters()
        );
    };

    /* corrections index filters */
    this.correctionGeneralFilters = function() {
        return [
            factory.searchFilter([
                factory.searchTerm("text", "correction text"),
                factory.searchTerm("text", "correction submitter's username")
            ]),
            factory.pageFilter,
            factory.showAdultFilter,
            factory.showNonAdultFilter,
            factory.hiddenFilter,
            factory.unhiddenFilter
        ];
    };

    this.correctionTypeFilters = function() {
        return factory.enumFilters("correctable", {
            "Mod": "tmo",
            "CompatibilityNote": "tcn",
            "InstallOrderNote": "tio",
            "LoadOrderNote": "tlo"
        });
    };

    this.correctionStatusFilters = function() {
        return factory.enumFilters("status", {
            open: "sto",
            passed: "stp",
            failed: "stf",
            closed: "stc"
        });
    };

    this.correctionModStatusFilters = function() {
        return factory.enumFilters("mod_status", {
            nil: "msn",
            good: "msg",
            outdated: "mso",
            unstable: "msu"
        })
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
            factory.correctionGeneralFilters(),
            factory.correctionTypeFilters(),
            factory.correctionStatusFilters(),
            factory.correctionModStatusFilters(),
            factory.contributionDateFilters(),
            factory.correctionStatisticFilters()
        )
    };

    this.articleGeneralFilters = function() {
        return [
            factory.searchFilter([
                factory.searchTerm("title", "article title"),
                factory.searchTerm("text", "article text"),
                factory.searchTerm("submitter", "article submitter's username")
            ]),
            factory.pageFilter
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
            factory.articleGeneralFilters(),
            factory.articleDateFilters()
        );
    };

    this.modListGeneralFilters = function() {
        return [
            factory.searchFilter([
                factory.searchTerm("name", "mod list name"),
                factory.searchTerm("description", "mod list description"),
                factory.searchTerm("submitter", "mod list submitter's username")
            ]),
            factory.pageFilter,
            factory.showAdultFilter,
            factory.showNonAdultFilter,
            factory.hiddenFilter,
            factory.unhiddenFilter,
            factory.tagsFilter,
            factory.excludedTagsFilter,
        ].concat(
            factory.enumFilters("status", {
                complete: "sco",
                testing: "ste",
                under_construction: "sun"
            }),
            factory.enumFilters("kind", {
                normal: "kn",
                collection: "kc"
            })
        );
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

    this.pluginGeneralFilters = function() {
        return [
            factory.searchFilter([
                factory.searchTerm("filename", "plugin's filename"),
                factory.searchTerm("author", "plugin's author field"),
                factory.searchTerm("description", "plugin's description field")
            ]),
            factory.pageFilter,
            factory.showAdultFilter,
            factory.showNonAdultFilter,
            factory.hiddenFilter,
            factory.unhiddenFilter,
            factory.approvedFilter,
            factory.unapprovedFilter
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
            factory.pluginGeneralFilters(),
            factory.pluginStatisticFilters()
        )
    };

    this.reportGeneralFilters = function() {
        return [
            factory.searchFilter([
                factory.searchTerm("text", "report note text", true),
                factory.searchTerm("submitter", "report submitter's username")
            ]),
            factory.pageFilter
        ].concat(
            factory.enumFilters("resolved", {
                "0": "unr",
                "1": "res"
            }, 1),
            factory.enumFilters("reportable", {
                "Review": "rr",
                "CompatibilityNote": "rcn",
                "InstallOrderNote": "rin",
                "LoadOrderNote": "rln",
                "Comment": "rco",
                "Correction": "rcr",
                "Mod": "rm",
                "Tag": "rt",
                "User": "ru"
            }),
            factory.enumFilters("reason", {
                be_respectful: "sbr",
                be_trustworthy: "sbt",
                be_constructive: "sbc",
                spam: "sns",
                piracy: "snp",
                adult_content: "sac",
                other: "sot"
            })
        )
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
            factory.reportGeneralFilters(),
            factory.reportDateFilters(),
            factory.reportStatisticFilters()
        );
    };

    this.curatorRequestGeneralFilters = function() {
        return [
            factory.searchFilter([
                factory.searchTerm("text", "curator request's text body"),
                factory.searchTerm("submitter", "curator request submitter's username")
            ]),
            factory.pageFilter,
            {
                label: "Mod Name",
                data: "mod_name"
            }
        ].concat(
            factory.enumFilters("state", {
                open: "sop",
                approved: "sap",
                denied: "sde"
            }, 1)
        )
    };

    this.curatorRequestDateFilters = function() {
        return [
            factory.userDateSlider({
                label: "Created",
                data: "submitted",
                param: "dc"
            }),
            factory.userDateSlider({
                label: "Updated",
                data: "updated",
                param: "du"
            })
        ];
    };

    this.curatorRequestStatisticFilters = function() {
        return [
            {
                label: "User Reputation",
                common: true,
                data: "user_reputation",
                type: "Range",
                max: 5000,
                param: "rep"
            }
        ]
    };

    this.curatorRequestFilters = function() {
        return Array.prototype.concat(
            factory.curatorRequestGeneralFilters(),
            factory.curatorRequestDateFilters(),
            factory.curatorRequestStatisticFilters()
        );
    };

    this.tagGeneralFilters = function() {
        return [
            factory.searchFilter([
                factory.searchTerm("text", "tag_text", true),
                factory.searchTerm("submitter", "tag submitter's username")
            ]),
            factory.pageFilter,
            factory.hiddenFilter,
            factory.unhiddenFilter
        ]
    };

    this.tagStatisticFilters = function() {
        return [
            {
                label: "Mods Count",
                common: true,
                data: "mods_count",
                type: "Range",
                max: 100,
                param: "mc"
            },
            {
                label: "Mod Lists Count",
                common: true,
                data: "mod_lists_count",
                type: "Range",
                max: 100,
                param: "mlc"
            }
        ]
    };

    this.tagFilters = function() {
        return Array.prototype.concat(
            factory.tagGeneralFilters(),
            factory.tagStatisticFilters()
        );
    };

    return factory;
});
