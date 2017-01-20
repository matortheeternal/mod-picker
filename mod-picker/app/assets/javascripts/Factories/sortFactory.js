app.service("sortFactory", function() {
    var factory = this;

    // helper function to convert a label to a value data string
    this.labelToValue = function(label) {
        return label.toLowerCase().replace(/ /g, "_");
    };

    // helper function to build a sort option prototype from a label
    this.buildSortOption = function(label, value) {
        if (!value) value = factory.labelToValue(label);
        return { label: label, value: value };
    };

    // helper function to build a sort option prototype from a count label
    this.buildCountSortOption = function(label) {
        var value = factory.labelToValue(label) + "_count";
        return { label: label, value: value };
    };

    /* shared sort option prototypes */
    this.helpfulnessSort = {
        label: "Helpfulness",
        value: "reputation"
    };
    this.submitterReputationSort = {
        label: "Submitter Reputation",
        value: "user_reputations.overall"
    };
    this.submittedSort = {
        label: "Date Submitted",
        value: "submitted"
    };
    this.editedSort = {
        label: "Date Edited",
        value: "edited"
    };
    this.correctionsSort = factory.buildSortOption("Corrections Count");
    this.commentsSort = factory.buildSortOption("Comments Count");
    this.indexSort = {
        label: "Index",
        value: "index"
    };
    this.modNameSort = {
        label: "Mod Name",
        value: "mods.name"
    };
    this.modStatusSort = {
        label: "Mod Status",
        value: "mods.status"
    };
    this.modReputationSort = {
        label: "Mod Reputation",
        value: "mods.reputation"
    };
    this.modAverageRatingSort = {
        label: "Mod Average Rating",
        value: "mods.average_rating"
    };

    /* mods index sort options (for grid view */
    this.modSortOptions = function() {
        return [
            factory.buildSortOption("Mod ID", "id"),
            factory.buildSortOption("Mod Name", "name"),
            factory.buildSortOption("Authors"),
            factory.buildSortOption("Primary Category", "primary_category.name"),
            factory.buildSortOption("Secondary Category", "secondary_category.name"),
            factory.buildSortOption("Submitted"),
            factory.buildSortOption("Released"),
            factory.buildSortOption("Updated"),
            factory.buildCountSortOption("Stars"),
            factory.buildSortOption("Reputation"),
            factory.buildSortOption("Avg Rating", "average_rating"),
            factory.buildCountSortOption("Mod Options"),
            factory.buildCountSortOption("Plugins"),
            factory.buildCountSortOption("Mod Lists"),
            factory.buildCountSortOption("Required Mods"),
            factory.buildCountSortOption("Required By"),
            factory.buildCountSortOption("Tags"),
            factory.buildCountSortOption("Compatibility Notes"),
            factory.buildCountSortOption("Install Order Notes"),
            factory.buildCountSortOption("Load Order Notes"),
            factory.buildSortOption("Endorsements", {
                nexus: "nexus_infos.endorsements"
            }),
            factory.buildSortOption("Subscribers", {
                workshop: "workshop_infos.subscribers"
            }),
            factory.buildSortOption("Unique DLs", {
                nexus: "nexus_infos.unique_downloads"
            }),
            factory.buildSortOption("Favorites", {
                lab: "lover_infos.followers_count",
                workshop: "workshop_infos.favorites"
            }),
            factory.buildSortOption("Downloads", {
                nexus: "nexus_infos.downloads",
                lab: "lover_infos.downloads"
            }),
            factory.buildSortOption("Views", {
                nexus: "nexus_infos.views",
                lab: "lover_infos.views",
                workshop: "workshop_infos.views"
            }),
            factory.buildSortOption("Posts", {
                nexus: "nexus_infos.posts_count",
                workshop: "workshop_infos.comments_count"
            }),
            factory.buildSortOption("Images", {
                nexus: "nexus_infos.images_count",
                workshop: "workshop_infos.images_count"
            }),
            factory.buildSortOption("Videos", {
                nexus: "nexus_infos.videos_count",
                workshop: "workshop_infos.videos_count"
            }),
            factory.buildSortOption("Files", {
                nexus: "nexus_infos.files_count"
            }),
            factory.buildSortOption("Bugs", {
                nexus: "nexus_infos.bugs_count"
            }),
            factory.buildSortOption("Discussions", {
                nexus: "nexus_infos.discussions_count",
                workshop: "workshop_infos.discussions_count"
            }),
            factory.buildSortOption("Articles", {
                nexus: "nexus_infos.articles_count"
            })
        ];
    };

    /* comments index sort options */
    this.commentSortOptions = function() {
        return [
            factory.submittedSort,
            factory.editedSort
        ];
    };

    /* corrections index sort options */
    this.correctionSortOptions = function() {
        return [
            factory.buildSortOption("Agree Count"),
            factory.buildSortOption("Disagree Count"),
            factory.submitterReputationSort,
            // TODO: Agree percentage or Agreement (flat)?
            factory.submittedSort,
            factory.editedSort,
            factory.commentsSort
        ];
    };

    /* reviews index sort options */
    this.reviewSortOptions = function() {
        return [
            factory.helpfulnessSort,
            factory.submitterReputationSort,
            factory.buildSortOption("Overall Rating"),
            // TODO: Ratings count?
            factory.submittedSort,
            factory.editedSort
        ];
    };

    /* compatibility notes index sort options */
    this.compatibilityNoteSortOptions = function() {
        return [
            factory.helpfulnessSort,
            factory.submitterReputationSort,
            {
                label: "Type",
                value: "status"
            },
            factory.submittedSort,
            factory.editedSort,
            factory.correctionsSort
        ];
    };

    /* install order notes index sort options */
    this.installOrderNoteSortOptions = function() {
        return [
            factory.helpfulnessSort,
            factory.submitterReputationSort,
            factory.submittedSort,
            factory.editedSort,
            factory.correctionsSort
        ];
    };

    /* load order notes index sort options */
    this.loadOrderNoteSortOptions = function() {
        return [
            factory.helpfulnessSort,
            factory.submitterReputationSort,
            factory.submittedSort,
            factory.editedSort,
            factory.correctionsSort
        ];
    };

    /* mod list tool sort options */
    this.modListToolSortOptions = function() {
        return [
            factory.indexSort,
            factory.modNameSort,
            factory.modStatusSort,
            factory.modReputationSort,
            factory.modAverageRatingSort
        ];
    };

    /* mod list mod sort options */
    this.modListModSortOptions = function() {
        return [
            factory.indexSort,
            factory.modNameSort,
            factory.modStatusSort,
            factory.modReputationSort,
            factory.modAverageRatingSort
        ];
    };

    /* articles sort options */
    this.articleSortOptions = function() {
        return [
            factory.submittedSort,
            factory.commentsSort,
            factory.editedSort
        ];
    };

    /* articles sort options */
    this.reportSortOptions = function() {
        return [
            factory.submittedSort,
            factory.editedSort,
            {
                label: "Reports Count",
                value: "reports_count"
            }
        ];
    };

    /* curator request sort options */
    this.curatorRequestSortOptions = function() {
        return [
            factory.submittedSort,
            factory.buildSortOption("Date Updated", "updated"),
            factory.buildSortOption("Mod Released", "mods.released"),
            factory.buildSortOption("Mod Updated", "mods.updated"),
            factory.buildSortOption("State"),
            factory.buildSortOption("User Reputation", "user_reputations.overall")
        ]
    };

    return factory;
});
