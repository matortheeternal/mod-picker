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

    return factory;
});
