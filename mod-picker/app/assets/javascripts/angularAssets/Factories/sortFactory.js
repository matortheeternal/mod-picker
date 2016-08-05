app.factory("sortFactory", function() {
    var factory = this;

    // helper function to build a sort option prototype from a label
    this.buildSortOption = function(label) {
        return {
            label: label,
            value: label.toLowerCase().replace(/ /g, "_")
        };
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

    /* modQueue sort options */
    this.modQueueSortOptions = function() {
        return [
            {
                label: "Date First Reported",
                value: "submitted"
            },
            {
                label: "Date Last Reported",
                value: "edited"
            },
            {
                label: "Total Reports",
                value: "reports_count"
            }
        ];
    };

    return factory;
});
